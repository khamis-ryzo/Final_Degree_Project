package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.LoginRequest;
import com.ryzo.Taxcompliance.dto.LoginResponse;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.exception.ResourceNotFoundException;
import com.ryzo.Taxcompliance.repository.UserRepository;
import com.ryzo.Taxcompliance.security.JwtUtils;
import com.ryzo.Taxcompliance.security.TokenBlacklist;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Date;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private static final int OTP_TTL_MINUTES = 15;

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final JwtUtils jwtUtils;
    private final TokenBlacklist tokenBlacklist;
    private final BCryptPasswordEncoder passwordEncoder;
    private final EmailService emailService;

    private final SecureRandom secureRandom = new SecureRandom();

    public LoginResponse authenticateUser(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword()));

        User user = userRepository.findByUsernameOrEmail(request.getUsername())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (Boolean.FALSE.equals(user.getEmailVerified())) {
            throw new IllegalStateException("Please verify your email before logging in. A verification OTP was sent to " + user.getEmail());
        }

        String token = jwtUtils.generateToken(user.getUsername());

        return new LoginResponse(token, user.getId(), user.getUsername(),
                user.getEmail(), user.getFullName(), user.getTinNumber(), user.getRole());
    }

    public LoginResponse refreshToken(String refreshToken) {
        if (tokenBlacklist.isBlacklisted(refreshToken)) {
            throw new ResourceNotFoundException("Token has been revoked");
        }
        String username = jwtUtils.getUsernameFromToken(refreshToken);
        User user = userRepository.findByUsernameOrEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        String token = jwtUtils.generateToken(user.getUsername());
        return new LoginResponse(token, user.getId(), user.getUsername(),
                user.getEmail(), user.getFullName(), user.getTinNumber(), user.getRole());
    }

    public void logoutUser(String token) {
        if (token == null || token.isBlank()) {
            return;
        }
        String bearer = token.startsWith("Bearer ") ? token.substring(7) : token;
        if (jwtUtils.validateToken(bearer)) {
            Date expiresAt = jwtUtils.getExpirationFromToken(bearer);
            tokenBlacklist.blacklist(bearer, expiresAt.toInstant());
            tokenBlacklist.clear();
            log.info("Token invalidated for logout");
        }
    }

    @Transactional(noRollbackFor = IllegalStateException.class)
    public void verifyEmail(String email, String otp) {
        User user = userRepository.findByEmail(email.toLowerCase())
                .orElseThrow(() -> new ResourceNotFoundException("User not found for email: " + email));

        if (user.getOtp() == null || user.getOtpExpiry() == null) {
            String freshOtp = generateOtp();
            user.setOtp(freshOtp);
            user.setOtpExpiry(LocalDateTime.now().plusMinutes(OTP_TTL_MINUTES));
            userRepository.save(user);
            try {
                emailService.sendOtpEmail(user, freshOtp);
            } catch (Exception ex) {
                log.warn("Failed to resend verification OTP for {} after missing code: {}", email, ex.getMessage());
            }
            throw new IllegalStateException("No verification code was found for this account. A new code has been sent to your email.");
        }

        validateOtp(user, otp);
        user.setEmailVerified(true);
        user.setOtp(null);
        user.setOtpExpiry(null);
        userRepository.save(user);
    }

    public void resendVerificationOtp(String email) {
        User user = userRepository.findByEmail(email.toLowerCase())
                .orElseThrow(() -> new ResourceNotFoundException("User not found for email: " + email));
        if (Boolean.TRUE.equals(user.getEmailVerified())) {
            throw new IllegalStateException("This email is already verified.");
        }

        String otp = generateOtp();
        user.setOtp(otp);
        user.setOtpExpiry(LocalDateTime.now().plusMinutes(OTP_TTL_MINUTES));
        userRepository.save(user);

        try {
            emailService.sendOtpEmail(user, otp);
        } catch (Exception ex) {
            log.warn("Failed to resend verification OTP for {}: {}", email, ex.getMessage());
        }
    }

    public void sendPasswordResetOtp(String email) {
        userRepository.findByEmail(email.toLowerCase()).ifPresent(user -> {
            String otp = generateOtp();
            user.setOtp(otp);
            user.setOtpExpiry(LocalDateTime.now().plusMinutes(OTP_TTL_MINUTES));
            userRepository.save(user);
            // Email sending hook: send the OTP to the user's registered email address.
            log.info("Password reset OTP for {} is: {}", email, otp);
        });
    }

    @Transactional
    public void resetPassword(String email, String otp, String newPassword) {
        User user = userRepository.findByEmail(email.toLowerCase())
                .orElseThrow(() -> new ResourceNotFoundException("User not found for email: " + email));
        validateOtp(user, otp);
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setOtp(null);
        user.setOtpExpiry(null);
        userRepository.save(user);
    }

    private void validateOtp(User user, String otp) {
        if (user.getOtp() == null || user.getOtpExpiry() == null) {
            throw new IllegalArgumentException("No OTP has been requested for this account");
        }
        if (!user.getOtp().equals(otp)) {
            throw new IllegalArgumentException("Invalid OTP");
        }
        if (LocalDateTime.now().isAfter(user.getOtpExpiry())) {
            throw new IllegalArgumentException("OTP has expired. Please request a new one.");
        }
    }

    private String generateOtp() {
        return String.format("%06d", secureRandom.nextInt(1_000_000));
    }
}
