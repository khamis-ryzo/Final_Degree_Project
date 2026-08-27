package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.SlabBreakdown;
import com.ryzo.Taxcompliance.dto.TaxBreakdownDTO;
import com.ryzo.Taxcompliance.dto.request.TaxCalculationRequest;
import com.ryzo.Taxcompliance.dto.request.TaxReturnRequest;
import com.ryzo.Taxcompliance.dto.response.DueDateResponse;
import com.ryzo.Taxcompliance.dto.response.TaxCalculationResponse;
import com.ryzo.Taxcompliance.dto.response.TaxReturnResponse;
import com.ryzo.Taxcompliance.entity.TaxReturn;
import com.ryzo.Taxcompliance.entity.TaxRule;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.exception.DuplicateResourceException;
import com.ryzo.Taxcompliance.exception.ResourceNotFoundException;
import com.ryzo.Taxcompliance.exception.SubscriptionRequiredException;
import com.ryzo.Taxcompliance.repository.TaxReturnRepository;
import com.ryzo.Taxcompliance.repository.UserRepository;
import com.ryzo.Taxcompliance.util.PdfBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class //package com.ryzo.Taxcompliance.service;
//
//import com.ryzo.Taxcompliance.dto.SubscriptionStats;
//import com.ryzo.Taxcompliance.dto.request.AssignSubscriptionRequest;
//import com.ryzo.Taxcompliance.dto.response.SubscriptionResponse;
//import com.ryzo.Taxcompliance.entity.Subscription;
//import com.ryzo.Taxcompliance.entity.User;
//import com.ryzo.Taxcompliance.exception.ResourceNotFoundException;
//import com.ryzo.Taxcompliance.repository.InMemorySubscriptionRepository;
//import com.ryzo.Taxcompliance.repository.UserRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//import org.springframework.transaction.annotation.Transactional;
//
//import java.math.BigDecimal;
//import java.time.LocalDate;
//import java.time.temporal.ChronoUnit;
//import java.util.List;
//import java.util.Objects;
//import java.util.Set;
//import java.util.stream.Collectors;
//
//@Service
//@RequiredArgsConstructor
//public class SubscriptionService {
//
//    private static final Set<String> PLANS = Set.of("FREE", "PREMIUM");
//    private static final Set<String> CYCLES = Set.of("MONTHLY", "YEARLY");
//    private static final BigDecimal PREMIUM_MONTHLY_FEE = new BigDecimal("5000");
//    private static final BigDecimal PREMIUM_YEARLY_FEE = new BigDecimal("50000");
//
//    private final InMemorySubscriptionRepository subscriptionRepository;
//    private final UserRepository userRepository;
//    private final NotificationService notificationService;
//
//    public SubscriptionResponse getMySubscription(String username) {
//        User user = getUserByUsername(username);
//        Subscription subscription = getOrCreateForUser(user);
//        return mapToResponse(subscription, user, "Subscription for " + user.getFullName());
//    }
//
//    public SubscriptionResponse getSubscriptionForUser(Long userId, String adminUsername) {
//        User user = findUser(userId);
//        Subscription subscription = getOrCreateForUser(user);
//        return mapToResponse(subscription, user, "Subscription for " + user.getFullName());
//    }
//
//    public List<SubscriptionResponse> getAllSubscriptions(String adminUsername) {
//        // Return empty by default when using in-memory stub
//        return List.of();
//    }
//
//    @Transactional
//    public SubscriptionResponse assignPlan(Long userId, AssignSubscriptionRequest request, String adminUsername) {
//        SubscriptionResponse response = applyPlan(userId, request, false);
//        notificationService.create(userId, "Subscription Updated",
//                "Your subscription plan is now " + response.getPlan() + ".", "SUCCESS");
//        return response;
//    }
//
//    @Transactional
//    public SubscriptionResponse subscribeSelf(String username, AssignSubscriptionRequest request) {
//        User user = getUserByUsername(username);
//        SubscriptionResponse response = applyPlan(user.getId(), request, true);
//        notificationService.create(user.getId(), "Subscription Updated",
//                "Your subscription plan is now " + response.getPlan() + ".", "SUCCESS");
//        return response;
//    }
//
//    @Transactional
//    public SubscriptionResponse cancelSubscription(Long userId, String adminUsername) {
//        SubscriptionResponse response = cancelForUser(userId);
//        notificationService.create(userId, "Subscription Cancelled",
//                "Your subscription has been cancelled by the administrator.", "WARNING");
//        return response;
//    }
//
//    @Transactional
//    public SubscriptionResponse cancelSelf(String username) {
//        User user = getUserByUsername(username);
//        SubscriptionResponse response = cancelForUser(user.getId());
//        notificationService.create(user.getId(), "Subscription Cancelled",
//                "Your subscription has been cancelled.", "WARNING");
//        return response;
//    }
//
//    private SubscriptionResponse applyPlan(Long userId, AssignSubscriptionRequest request, boolean selfServe) {
//        User user = findUser(userId);
//
//        String plan = request.getPlan() == null ? "PREMIUM" : request.getPlan().trim().toUpperCase();
//        if (!PLANS.contains(plan)) {
//            throw new IllegalArgumentException("Invalid plan. Must be FREE or PREMIUM");
//        }
//
//        Subscription subscription = new Subscription();
//        subscription.setUserId(userId);
//        subscription.setPlan(plan);
//        subscription.setStatus("ACTIVE");
//        subscription.setStartDate(LocalDate.now());
//        subscription.setAutoRenew(request.getAutoRenew() != null && request.getAutoRenew());
//
//        if ("PREMIUM".equals(plan)) {
//            String cycle = request.getBillingCycle() == null ? "MONTHLY" : request.getBillingCycle().trim().toUpperCase();
//            if (!CYCLES.contains(cycle)) {
//                throw new IllegalArgumentException("Invalid billing cycle. Must be MONTHLY or YEARLY");
//            }
//            subscription.setBillingCycle(cycle);
//            LocalDate expiry = request.getExpiryDate();
//            if (expiry == null) {
//                expiry = "MONTHLY".equals(cycle) ? LocalDate.now().plusMonths(1) : LocalDate.now().plusYears(1);
//            }
//            subscription.setExpiryDate(expiry);
//        } else {
//            subscription.setBillingCycle("NONE");
//            subscription.setExpiryDate(null);
//        }
//
//        expireActiveSubscriptions(userId);
//
//        Subscription saved = subscriptionRepository.save(subscription);
//        return mapToResponse(saved, user,
//                selfServe ? "Subscription activated successfully" : "Subscription assigned successfully");
//    }
//
//    private SubscriptionResponse cancelForUser(Long userId) {
//        User user = findUser(userId);
//        Subscription subscription = subscriptionRepository
//                .findFirstByUserIdOrderByIdDesc(userId)
//                .orElseGet(() -> {
//                    Subscription freeSubscription = createFreeSubscription(userId);
//                    return subscriptionRepository.save(freeSubscription);
//                });
//        if (!"ACTIVE".equals(effectiveStatus(subscription))) {
//            throw new IllegalStateException("No active subscription to cancel for user " + user.getUsername());
//        }
//        subscription.setStatus("CANCELLED");
//        Subscription saved = subscriptionRepository.save(subscription);
//        return mapToResponse(saved, user, "Subscription cancelled successfully");
//    }
//
//    public boolean hasActivePremium(Long userId) {
//        Subscription subscription = subscriptionRepository.findFirstByUserIdOrderByIdDesc(userId).orElse(null);
//        return subscription != null
//                && "PREMIUM".equals(subscription.getPlan())
//                && "ACTIVE".equals(effectiveStatus(subscription));
//    }
//
//    public SubscriptionStats getSubscriptionStats() {
//        List<Subscription> all = subscriptionRepository.findAll();
//        long active = all.stream().filter(s -> "ACTIVE".equals(effectiveStatus(s))).count();
//        long premium = all.stream()
//                .filter(s -> "PREMIUM".equals(s.getPlan()) && "ACTIVE".equals(effectiveStatus(s)))
//                .count();
//        long free = all.stream()
//                .filter(s -> "FREE".equals(s.getPlan()) && "ACTIVE".equals(effectiveStatus(s)))
//                .count();
//        long expired = all.stream().filter(s -> "EXPIRED".equals(effectiveStatus(s))).count();
//        LocalDate monthStart = LocalDate.now().withDayOfMonth(1);
//        LocalDate monthEnd = LocalDate.now().withDayOfMonth(LocalDate.now().lengthOfMonth());
//        long expiringThisMonth = all.stream()
//                .filter(s -> s.getExpiryDate() != null
//                        && !s.getExpiryDate().isBefore(monthStart)
//                        && !s.getExpiryDate().isAfter(monthEnd))
//                .count();
//
//        BigDecimal monthlyRevenue = all.stream()
//                .filter(s -> "PREMIUM".equals(s.getPlan()) && "ACTIVE".equals(effectiveStatus(s)))
//                .map(s -> "YEARLY".equals(s.getBillingCycle()) ? PREMIUM_YEARLY_FEE : PREMIUM_MONTHLY_FEE)
//                .reduce(BigDecimal.ZERO, (a, b) -> a.add(b));
//
//        return SubscriptionStats.builder()
//                .totalSubscriptions(all.size())
//                .activeSubscriptions(active)
//                .premiumSubscriptions(premium)
//                .freeSubscriptions(free)
//                .expiredSubscriptions(expired)
//                .expiringThisMonth(expiringThisMonth)
//                .estimatedMonthlyRevenue(monthlyRevenue)
//                .build();
//    }
//
//    private Subscription getOrCreateForUser(User user) {
//        return subscriptionRepository
//                .findFirstByUserIdOrderByIdDesc(user.getId())
//                .orElseGet(() -> subscriptionRepository.save(createFreeSubscription(user.getId())));
//    }
//
//    private Subscription createFreeSubscription(Long userId) {
//        Subscription subscription = new Subscription();
//        subscription.setUserId(userId);
//        subscription.setPlan("FREE");
//        subscription.setBillingCycle("NONE");
//        subscription.setStatus("ACTIVE");
//        subscription.setStartDate(LocalDate.now());
//        subscription.setExpiryDate(null);
//        subscription.setAutoRenew(false);
//        return subscription;
//    }
//
//    private void expireActiveSubscriptions(Long userId) {
//        subscriptionRepository.findByUserId(userId).forEach(existing -> {
//            if ("ACTIVE".equals(existing.getStatus())) {
//                existing.setStatus("CANCELLED");
//                subscriptionRepository.save(existing);
//            }
//        });
//    }
//
//    private String effectiveStatus(Subscription subscription) {
//        String status = subscription.getStatus();
//        if ("ACTIVE".equals(status)
//                && subscription.getExpiryDate() != null
//                && subscription.getExpiryDate().isBefore(LocalDate.now())) {
//            return "EXPIRED";
//        }
//        return status;
//    }
//
//    private User findUser(Long userId) {
//        return userRepository.findById(Objects.requireNonNull(userId))
//                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
//    }
//
//    private User getUserByUsername(String username) {
//        return userRepository.findByUsername(username)
//                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
//    }
//
//    private SubscriptionResponse mapToResponse(Subscription subscription, User user, String message) {
//        String effective = effectiveStatus(subscription);
//        long daysRemaining = -1L;
//        if (subscription.getExpiryDate() != null && "ACTIVE".equals(effective)) {
//            daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), subscription.getExpiryDate());
//        }
//        return SubscriptionResponse.builder()
//                .id(subscription.getId())
//                .userId(subscription.getUserId())
//                .username(user.getUsername())
//                .fullName(user.getFullName())
//                .plan(subscription.getPlan())
//                .billingCycle(subscription.getBillingCycle())
//                .status(effective)
//                .startDate(subscription.getStartDate())
//                .expiryDate(subscription.getExpiryDate())
//                .autoRenew(subscription.getAutoRenew())
//                .daysRemaining(daysRemaining)
//                .createdAt(subscription.getCreatedAt())
//                .message(message)
//                .build();
//    }
//}
TaxReturnService {

    @Autowired
    private TaxReturnRepository taxReturnRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TaxRuleService taxRuleService;

    @Autowired
    private NotificationService notificationService;


    @Transactional
    public TaxReturn createTaxReturn(User user, String assessmentYear) {
        List<TaxReturn> existing = taxReturnRepository.findByUserId(user.getId()).stream()
                .filter(r -> assessmentYear.equals(r.getAssessmentYear()))
                .toList();

        for (TaxReturn existingReturn : existing) {
            if ("DRAFT".equals(existingReturn.getStatus())) {
                return existingReturn;
            }
            if (!"REJECTED".equals(existingReturn.getStatus())) {
                throw new DuplicateResourceException(
                        "Tax return already filed for year " + assessmentYear);
            }
        }

        TaxReturn taxReturn = new TaxReturn();
        taxReturn.setUserId(user.getId());
        taxReturn.setAssessmentYear(assessmentYear);
        taxReturn.setFilingId(generateFilingId(user.getId(), assessmentYear));
        taxReturn.setStatus("DRAFT");
        taxReturn.setFilingType("ORIGINAL");
        taxReturn.setTotalIncome(BigDecimal.ZERO);
        taxReturn.setDeductions(BigDecimal.ZERO);
        taxReturn.setTaxableIncome(BigDecimal.ZERO);
        taxReturn.setTaxPayable(BigDecimal.ZERO);
        taxReturn.setTotalLiability(BigDecimal.ZERO);

        return taxReturnRepository.save(taxReturn);
    }

    @Transactional
    public TaxReturn calculateAndSaveReturn(Long returnId, BigDecimal totalIncome, BigDecimal deductions) {
        TaxReturn taxReturn = taxReturnRepository.findById(Objects.requireNonNull(returnId))
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found"));

        taxReturn.setTotalIncome(totalIncome);
        taxReturn.setDeductions(deductions);

        BigDecimal taxableIncome = totalIncome.subtract(deductions);
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }
        taxReturn.setTaxableIncome(taxableIncome);

        BigDecimal taxPayable = taxRuleService.calculateTax(taxableIncome, taxReturn.getAssessmentYear());
        taxReturn.setTaxPayable(taxPayable);
        taxReturn.setTotalLiability(taxPayable);

        return taxReturnRepository.save(taxReturn);
    }

    @Transactional
    public TaxReturn submitTaxReturn(Long returnId) {
        TaxReturn taxReturn = taxReturnRepository.findById(Objects.requireNonNull(returnId))
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found"));

//        requirePremium(taxReturn.getUserId());

        if (taxReturn.getTotalIncome() == null || taxReturn.getTotalIncome().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalStateException("Cannot submit return with zero income");
        }

        taxReturn.setStatus("SUBMITTED");
        taxReturn.setSubmissionDate(LocalDate.now());
        taxReturn.setAcknowledgmentNumber(generateAcknowledgmentNumber());

        return taxReturnRepository.save(taxReturn);
    }

    public List<TaxReturn> getUserReturns(Long userId) {
        return taxReturnRepository.findByUserId(userId);
    }

    public TaxReturn getReturnByFilingId(String filingId) {
        return taxReturnRepository.findByFilingId(filingId)
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found"));
    }

    public TaxCalculationResponse calculateTax(String username, TaxCalculationRequest request) {
        getUserByUsername(username);

        BigDecimal totalIncome = request.getTotalIncome();
        BigDecimal deductions = request.getDeductions() != null ? request.getDeductions() : BigDecimal.ZERO;

        BigDecimal taxableIncome = totalIncome.subtract(deductions);
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }

        String assessmentYear = currentAssessmentYear();
        BigDecimal taxPayable;
        Long returnId = request.getReturnId();
        if (returnId != null) {
            TaxReturn ownedReturn = getOwnedReturn(username, returnId);
            assessmentYear = ownedReturn.getAssessmentYear();
            TaxReturn savedReturn = calculateAndSaveReturn(returnId, totalIncome, deductions);
            taxPayable = savedReturn.getTaxPayable();
        } else {
            taxPayable = taxRuleService.calculateTax(taxableIncome, assessmentYear);
        }
        Integer year = parseYear(assessmentYear);

        TaxCalculationResponse response = new TaxCalculationResponse();
        response.setReturnId(returnId);
        response.setAssessmentYear(assessmentYear);
        response.setTotalIncome(totalIncome);
        response.setDeductions(deductions);
        response.setTaxableIncome(taxableIncome);
        response.setTaxPayable(taxPayable);
        response.setCess(BigDecimal.ZERO);
        response.setSurcharge(BigDecimal.ZERO);
        response.setInterest(BigDecimal.ZERO);
        response.setPenalty(BigDecimal.ZERO);
        response.setTotalLiability(taxPayable);
        response.setStatus("DRAFT");
        response.setMessage("Tax calculated successfully");
        response.setBreakdown(buildBreakdown(taxableIncome, year, taxPayable));
        return response;
    }

    private TaxBreakdownDTO buildBreakdown(BigDecimal taxableIncome, Integer year, BigDecimal totalTax) {
        List<TaxRule> slabs = taxRuleService.findActivePayeSlabs(year);
        List<SlabBreakdown> breakdowns = new ArrayList<>();

        for (TaxRule slab : slabs) {
            BigDecimal slabMin = slab.getMinIncome() != null ? slab.getMinIncome() : BigDecimal.ZERO;
            if (taxableIncome.compareTo(slabMin) <= 0) {
                break;
            }
            BigDecimal slabMax = slab.getMaxIncome();
            BigDecimal taxableInSlab;
            if (slabMax == null) {
                taxableInSlab = taxableIncome.subtract(slabMin);
            } else {
                taxableInSlab = taxableIncome.min(slabMax).subtract(slabMin);
                if (taxableInSlab.compareTo(BigDecimal.ZERO) < 0) {
                    taxableInSlab = BigDecimal.ZERO;
                }
            }
            BigDecimal rate = slab.getTaxRate() != null ? slab.getTaxRate() : BigDecimal.ZERO;
            BigDecimal taxAmount = taxableInSlab.multiply(rate)
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
            breakdowns.add(SlabBreakdown.builder()
                    .slabRange(slabMin + " - " + (slabMax != null ? slabMax : "& above"))
                    .taxableAmount(taxableInSlab)
                    .taxRate(rate)
                    .taxAmount(taxAmount)
                    .build());
        }

        return TaxBreakdownDTO.builder()
                .slabContributions(breakdowns)
                .totalTaxBeforeCess(totalTax)
                .healthAndEducationCess(BigDecimal.ZERO)
                .build();
    }

    private User getUserByUsername(String username) {
        return userRepository.findByUsernameOrEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
    }

//    private void requirePremium(Long userId) {
//        if (!subscriptionService.hasActivePremium(userId)) {
//            throw new SubscriptionRequiredException(
//                    "An active PREMIUM subscription is required to access this feature. Please upgrade from the Subscription page.");
//        }
//    }

    private TaxReturn getOwnedReturn(String username, Long returnId) {
        User user = getUserByUsername(username);
        TaxReturn taxReturn = taxReturnRepository.findById(Objects.requireNonNull(returnId))
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found"));
        if (!taxReturn.getUserId().equals(user.getId())) {
            throw new AccessDeniedException("You do not have access to this tax return");
        }
        return taxReturn;
    }

    private TaxReturnResponse mapToResponse(TaxReturn taxReturn) {
        TaxReturnResponse response = new TaxReturnResponse();
        response.setId(taxReturn.getId());
        response.setFilingId(taxReturn.getFilingId());
        response.setUserId(taxReturn.getUserId());
        response.setAssessmentYear(taxReturn.getAssessmentYear());
        response.setFilingType(taxReturn.getFilingType());
        response.setTotalIncome(taxReturn.getTotalIncome());
        response.setDeductions(taxReturn.getDeductions());
        response.setTaxableIncome(taxReturn.getTaxableIncome());
        response.setTaxPayable(taxReturn.getTaxPayable());
        response.setInterest(taxReturn.getInterest());
        response.setPenalty(taxReturn.getPenalty());
        response.setTotalLiability(taxReturn.getTotalLiability());
        response.setStatus(taxReturn.getStatus());
        response.setSubmissionDate(taxReturn.getSubmissionDate());
        response.setAcknowledgmentNumber(taxReturn.getAcknowledgmentNumber());
        return response;
    }

    @Transactional
    public TaxReturnResponse createTaxReturn(String username, String assessmentYear) {
        User user = getUserByUsername(username);
        boolean alreadyExists = hasDraftOrFiledReturn(user.getId(), assessmentYear);
        TaxReturn taxReturn = createTaxReturn(user, assessmentYear);
        if (!alreadyExists) {
            notificationService.create(user.getId(), "Return Draft Created",
                    "A draft tax return for assessment year " + assessmentYear + " has been created.", "INFO");
        }
        return mapToResponse(taxReturn);
    }

    private boolean hasDraftOrFiledReturn(Long userId, String assessmentYear) {
        return taxReturnRepository.findByUserId(userId).stream()
                .anyMatch(r -> assessmentYear.equals(r.getAssessmentYear())
                        && !"REJECTED".equals(r.getStatus()));
    }

    @Transactional
    public TaxReturnResponse updateTaxReturn(String username, Long returnId, TaxReturnRequest request) {
        TaxReturn taxReturn = getOwnedReturn(username, returnId);
        if (!"DRAFT".equals(taxReturn.getStatus())) {
            throw new IllegalStateException("Only draft returns can be edited");
        }
        if (request.getTotalIncome() != null) {
            taxReturn.setTotalIncome(request.getTotalIncome());
        }
        if (request.getDeductions() != null) {
            taxReturn.setDeductions(request.getDeductions());
        }
        if (request.getFilingType() != null) {
            taxReturn.setFilingType(request.getFilingType());
        }
        BigDecimal taxableIncome = taxReturn.getTotalIncome().subtract(taxReturn.getDeductions());
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }
        taxReturn.setTaxableIncome(taxableIncome);
        BigDecimal taxPayable = taxRuleService.calculateTax(taxableIncome, taxReturn.getAssessmentYear());
        taxReturn.setTaxPayable(taxPayable);
        taxReturn.setTotalLiability(taxPayable);
        taxReturnRepository.save(taxReturn);
        return mapToResponse(taxReturn);
    }

    @Transactional
    public TaxReturnResponse submitTaxReturn(String username, Long returnId) {
        TaxReturn taxReturn = getOwnedReturn(username, returnId);
//        requirePremium(taxReturn.getUserId());
        if (taxReturn.getTotalIncome() == null || taxReturn.getTotalIncome().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalStateException("Cannot submit return with zero income");
        }
        taxReturn.setStatus("SUBMITTED");
        taxReturn.setSubmissionDate(LocalDate.now());
        taxReturn.setAcknowledgmentNumber(generateAcknowledgmentNumber());
        taxReturnRepository.save(taxReturn);
        notificationService.create(taxReturn.getUserId(), "Return Submitted",
                "Your tax return for " + taxReturn.getAssessmentYear() + " was submitted successfully.", "SUCCESS");
        return mapToResponse(taxReturn);
    }

    public TaxReturnResponse getTaxReturnById(String username, Long returnId) {
        return mapToResponse(getOwnedReturn(username, returnId));
    }

    public TaxReturnResponse getTaxReturnByFilingId(String username, String filingId) {
        User user = getUserByUsername(username);
        TaxReturn taxReturn = taxReturnRepository.findByFilingId(filingId)
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found"));
        if (!taxReturn.getUserId().equals(user.getId())) {
            throw new AccessDeniedException("You do not have access to this tax return");
        }
        return mapToResponse(taxReturn);
    }

    public Page<TaxReturnResponse> getUserTaxReturns(String username, Pageable pageable) {
        User user = getUserByUsername(username);
        Page<TaxReturn> returns = taxReturnRepository.findByUserId(user.getId(), pageable);
        List<TaxReturnResponse> responses = returns.getContent().stream()
                .map(this::mapToResponse).collect(Collectors.toList());
        return new PageImpl<>(Objects.requireNonNull(responses),
                Objects.requireNonNull(pageable), returns.getTotalElements());
    }

    public TaxReturnResponse getTaxReturnByYear(String username, String assessmentYear) {
        User user = getUserByUsername(username);
        TaxReturn taxReturn = taxReturnRepository.findByUserIdAndAssessmentYear(user.getId(), assessmentYear)
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found for year " + assessmentYear));
        return mapToResponse(taxReturn);
    }

    public List<TaxReturnResponse> getFilingHistory(String username, String status, LocalDate fromDate, LocalDate toDate) {
        User user = getUserByUsername(username);
        List<TaxReturn> returns = taxReturnRepository.findByUserId(user.getId());
        if (status != null && !status.isBlank()) {
            returns = returns.stream().filter(r -> status.equals(r.getStatus())).collect(Collectors.toList());
        }
        if (fromDate != null) {
            returns = returns.stream().filter(r -> r.getSubmissionDate() != null
                    && !r.getSubmissionDate().isBefore(fromDate)).collect(Collectors.toList());
        }
        if (toDate != null) {
            returns = returns.stream().filter(r -> r.getSubmissionDate() != null
                    && !r.getSubmissionDate().isAfter(toDate)).collect(Collectors.toList());
        }
        returns.sort((a, b) -> {
            LocalDateTime aTime = a.getUpdatedAt() != null ? a.getUpdatedAt() : LocalDateTime.MIN;
            LocalDateTime bTime = b.getUpdatedAt() != null ? b.getUpdatedAt() : LocalDateTime.MIN;
            return bTime.compareTo(aTime);
        });
        return returns.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public byte[] generateAcknowledgmentPdf(String username, Long returnId) {
        TaxReturn taxReturn = getOwnedReturn(username, returnId);
//        requirePremium(taxReturn.getUserId());
        User user = getUserByUsername(username);
        List<String> lines = List.of(
                "Acknowledgment Number: " + (taxReturn.getAcknowledgmentNumber() != null ? taxReturn.getAcknowledgmentNumber() : "N/A"),
                "Filing ID: " + taxReturn.getFilingId(),
                "Assessment Year: " + taxReturn.getAssessmentYear(),
                "Status: " + taxReturn.getStatus(),
                "Submission Date: " + (taxReturn.getSubmissionDate() != null ? taxReturn.getSubmissionDate() : "N/A"),
                "",
                "Taxpayer: " + user.getFullName(),
                "TIN: " + user.getTinNumber(),
                "Email: " + user.getEmail(),
                "",
                "Total Income: " + taxReturn.getTotalIncome(),
                "Deductions: " + taxReturn.getDeductions(),
                "Taxable Income: " + taxReturn.getTaxableIncome(),
                "Tax Payable: " + taxReturn.getTaxPayable(),
                "Total Liability: " + taxReturn.getTotalLiability(),
                "",
                "This is a computer generated acknowledgment and does not require a signature."
        );
        return PdfBuilder.simpleDocument("ACKNOWLEDGMENT OF TAX RETURN FILING", lines);
    }

    public byte[] generateTaxReturnPdf(String username, Long returnId) {
        TaxReturn taxReturn = getOwnedReturn(username, returnId);
//        requirePremium(taxReturn.getUserId());
        User user = getUserByUsername(username);
        List<String> lines = List.of(
                "Filing ID: " + taxReturn.getFilingId(),
                "Assessment Year: " + taxReturn.getAssessmentYear(),
                "Filing Type: " + taxReturn.getFilingType(),
                "Status: " + taxReturn.getStatus(),
                "",
                "Taxpayer: " + user.getFullName(),
                "TIN: " + user.getTinNumber(),
                "Email: " + user.getEmail(),
                "Mobile: " + (user.getMobileNumber() != null ? user.getMobileNumber() : "N/A"),
                "",
                "Total Income: " + taxReturn.getTotalIncome(),
                "Deductions: " + taxReturn.getDeductions(),
                "Taxable Income: " + taxReturn.getTaxableIncome(),
                "Tax Payable: " + taxReturn.getTaxPayable(),
                "Interest: " + taxReturn.getInterest(),
                "Penalty: " + taxReturn.getPenalty(),
                "Total Liability: " + taxReturn.getTotalLiability(),
                "Acknowledgment Number: " + (taxReturn.getAcknowledgmentNumber() != null ? taxReturn.getAcknowledgmentNumber() : "N/A"),
                "Submission Date: " + (taxReturn.getSubmissionDate() != null ? taxReturn.getSubmissionDate() : "N/A")
        );
        return PdfBuilder.simpleDocument("TAX RETURN - ASSESSMENT YEAR " + taxReturn.getAssessmentYear(), lines);
    }

    @Transactional
    public void deleteDraftReturn(String username, Long returnId) {
        TaxReturn taxReturn = getOwnedReturn(username, returnId);
        if (!"DRAFT".equals(taxReturn.getStatus())) {
            throw new IllegalStateException("Only draft returns can be deleted");
        }
        taxReturnRepository.delete(taxReturn);
    }

    public List<DueDateResponse> getUpcomingDueDates(String username) {
        User user = getUserByUsername(username);
        List<TaxReturn> returns = taxReturnRepository.findByUserId(user.getId());
        Set<String> filedYears = returns.stream()
                .filter(r -> "SUBMITTED".equals(r.getStatus())
                        || "ASSESSED".equals(r.getStatus())
                        || "COMPLETED".equals(r.getStatus()))
                .map(r -> r.getAssessmentYear())
                .collect(Collectors.toSet());

        int currentYear = LocalDate.now().getYear();
        List<DueDateResponse> result = new ArrayList<>();
        for (int year = currentYear - 1; year <= currentYear + 1; year++) {
            String assessmentYear = year + "/" + (year + 1);
            if (filedYears.contains(assessmentYear)) {
                continue;
            }
            LocalDate due = LocalDate.of(year + 1, 7, 31);
            if (LocalDate.now().isAfter(due)) {
                continue;
            }
            DueDateResponse response = new DueDateResponse();
            response.setLabel("Assessment year " + assessmentYear + " tax return");
            response.setDueDate(due.toString());
            result.add(response);
        }
        return result;
    }

    private String currentAssessmentYear() {
        int current = LocalDate.now().getYear();
        return current + "/" + (current + 1);
    }

    private Integer parseYear(String assessmentYear) {
        if (assessmentYear == null || assessmentYear.isBlank()) {
            return LocalDate.now().getYear();
        }
        String digits = assessmentYear.trim();
        int dash = digits.indexOf('-');
        int slash = digits.indexOf('/');
        int separator = dash < 0 ? slash : (slash < 0 ? dash : Math.min(dash, slash));
        if (separator > 0) {
            digits = digits.substring(0, separator);
        }
        try {
            return Integer.parseInt(digits.trim());
        } catch (NumberFormatException e) {
            return LocalDate.now().getYear();
        }
    }

    private String generateFilingId(Long userId, String assessmentYear) {
        String safeAssessmentYear = assessmentYear == null ? "UNKNOWN" : assessmentYear
                .replaceAll("[^A-Za-z0-9-]", "-")
                .replaceAll("-+", "-")
                .replaceAll("^-|-$", "");

        return String.format("TR-%s-%d-%s",
                safeAssessmentYear,
                userId,
                UUID.randomUUID().toString().substring(0, 6).toUpperCase());
    }

    private String generateAcknowledgmentNumber() {
        return "ACK-" + System.currentTimeMillis() + "-" +
                UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }
}
