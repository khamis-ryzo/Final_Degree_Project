package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.RegisterRequest;
import com.ryzo.Taxcompliance.dto.request.UpdateProfileRequest;
import com.ryzo.Taxcompliance.dto.response.DashboardSummaryResponse;
import com.ryzo.Taxcompliance.dto.response.NotificationResponse;
import com.ryzo.Taxcompliance.dto.response.TaxSummaryResponse;
import com.ryzo.Taxcompliance.dto.response.UserResponse;
import com.ryzo.Taxcompliance.entity.TaxReturn;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.exception.DuplicateResourceException;
import com.ryzo.Taxcompliance.exception.ResourceNotFoundException;
import com.ryzo.Taxcompliance.repository.TaxReturnRepository;
import com.ryzo.Taxcompliance.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private TaxReturnRepository taxReturnRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private EmailService emailService;

    private static final int OTP_TTL_MINUTES = 15;
    private final SecureRandom secureRandom = new SecureRandom();

    @Transactional
    public User registerUser(RegisterRequest request) {
        String username = request.getUsername().trim();
        String email = request.getEmail().trim().toLowerCase();
        String tinNumber = request.getTinNumber().trim().toUpperCase();

        if (userRepository.existsByUsername(username)) {
            throw new DuplicateResourceException("Username already exists");
        }
        if (userRepository.existsByEmail(email)) {
            throw new DuplicateResourceException("Email already registered");
        }
        if (userRepository.existsByTinNumber(tinNumber)) {
            throw new DuplicateResourceException("TIN number already registered");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setTinNumber(tinNumber);
        user.setFullName(request.getFullName().trim());
        user.setMobileNumber(request.getMobileNumber());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setAddress(request.getAddress());
        user.setRole("ROLE_USER");
        user.setIsActive(true);
        user.setEmailVerified(false);

        // generate OTP and set expiry to require email verification
        String otp = generateOtp();
        user.setOtp(otp);
        user.setOtpExpiry(LocalDateTime.now().plusMinutes(OTP_TTL_MINUTES));

        User saved = userRepository.save(user);
        notificationService.create(saved.getId(), "Welcome",
                "Welcome to Tax Compliance, " + saved.getFullName() + "!", "INFO");

        // send OTP email (will log OTP if SMTP not configured)
        try {
            emailService.sendOtpEmail(saved, otp);
        } catch (Exception ex) {
            // do not fail registration if email sending fails; log for investigation
            // EmailService already logs errors
        }

        return saved;
    }

    private String generateOtp() {
        return String.format("%06d", secureRandom.nextInt(1_000_000));
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findById(Long id) {
        Objects.requireNonNull(id, "User ID must not be null");
        return userRepository.findById(id);
    }

    @Transactional
    public User updateUser(Long id, User userDetails) {
        Objects.requireNonNull(id, "User ID must not be null");
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        user.setFullName(userDetails.getFullName());
        user.setMobileNumber(userDetails.getMobileNumber());
        user.setAddress(userDetails.getAddress());
        user.setDateOfBirth(userDetails.getDateOfBirth());

        return userRepository.save(user);
    }

    public UserResponse getUserProfile(String username) {
        User user = getUserByUsername(username);
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse updateUserProfile(String username, UpdateProfileRequest updateRequest) {
        User user = getUserByUsername(username);
        user.setFullName(updateRequest.getFullName());
        user.setMobileNumber(updateRequest.getMobileNumber());
        user.setAddress(updateRequest.getAddress());
        userRepository.save(user);
        return UserResponse.from(user);
    }

    public DashboardSummaryResponse getDashboardSummary(String username) {
        User user = getUserByUsername(username);

        List<TaxReturn> returns = taxReturnRepository.findByUserId(user.getId());
        String currentYear = currentAssessmentYear();

        DashboardSummaryResponse response = new DashboardSummaryResponse();
        response.setUserId(user.getId());
        response.setUsername(user.getUsername());
        response.setFullName(user.getFullName());
        response.setMessage("Dashboard summary");
        response.setCurrentAssessmentYear(currentYear);
        response.setTotalReturns(returns.size());

        TaxReturn current = returns.stream()
                .filter(r -> currentYear.equals(r.getAssessmentYear()))
                .findFirst()
                .orElse(null);
        if (current != null) {
            response.setTotalIncome(current.getTotalIncome());
            response.setDeductions(current.getDeductions());
            response.setTaxableIncome(current.getTaxableIncome());
            response.setTaxPayable(current.getTaxPayable());
            response.setTotalLiability(current.getTotalLiability());
            response.setFilingStatus(current.getStatus());
            response.setDueDate(computeDueDate(currentYear));
        } else {
            response.setFilingStatus("NOT_FILED");
            response.setDueDate(computeDueDate(currentYear));
        }

        response.setPendingActions(returns.stream()
                .filter(r -> !"SUBMITTED".equals(r.getStatus())
                        && !"ASSESSED".equals(r.getStatus())
                        && !"COMPLETED".equals(r.getStatus()))
                .count());
        response.setUnreadNotifications(notificationService.countUnread(user.getId()));
        response.setRecentNotifications(notificationService.getNotificationsForUser(user.getId(), 0, 5));

        return response;
    }

    public TaxSummaryResponse getTaxSummary(String username, String assessmentYear) {
        User user = getUserByUsername(username);

        TaxSummaryResponse response = new TaxSummaryResponse();
        response.setAssessmentYear(assessmentYear);
        response.setDueDate(computeDueDate(assessmentYear));

        TaxReturn taxReturn = taxReturnRepository
                .findByUserIdAndAssessmentYear(user.getId(), assessmentYear)
                .orElse(null);
        if (taxReturn == null) {
            response.setMessage("No tax return filed for assessment year " + assessmentYear);
            response.setFilingStatus("NOT_FILED");
            return response;
        }

        response.setTotalIncome(taxReturn.getTotalIncome());
        response.setDeductions(taxReturn.getDeductions());
        response.setTaxableIncome(taxReturn.getTaxableIncome());
        response.setTaxPayable(taxReturn.getTaxPayable());
        response.setTotalLiability(taxReturn.getTotalLiability());
        response.setFilingStatus(taxReturn.getStatus());
        response.setMessage("Tax summary for assessment year " + assessmentYear);
        return response;
    }

    public List<NotificationResponse> getUserNotifications(String username, int page, int size) {
        User user = getUserByUsername(username);
        return notificationService.getNotificationsForUser(user.getId(), page, size);
    }

    @Transactional
    public void markNotificationAsRead(String username, Long notificationId) {
        User user = getUserByUsername(username);
        notificationService.markAsRead(user.getId(), notificationId);
    }

    private User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private String currentAssessmentYear() {
        int current = LocalDate.now().getYear();
        return current + "/" + (current + 1);
    }

    private LocalDate computeDueDate(String assessmentYear) {
        if (assessmentYear == null || assessmentYear.isBlank()) {
            return LocalDate.now().plusMonths(6);
        }
        String digits = assessmentYear.trim();
        int dash = digits.indexOf('-');
        int slash = digits.indexOf('/');
        int separator = dash < 0 ? slash : (slash < 0 ? dash : Math.min(dash, slash));
        if (separator > 0) {
            digits = digits.substring(0, separator);
        }
        try {
            int year = Integer.parseInt(digits.trim());
            return LocalDate.of(year + 1, 7, 31);
        } catch (NumberFormatException e) {
            return LocalDate.now().plusMonths(6);
        }
    }
}
