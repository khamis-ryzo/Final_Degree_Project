package com.ryzo.Taxcompliance.controller;


import com.ryzo.Taxcompliance.dto.LoginRequest;
import com.ryzo.Taxcompliance.dto.LoginResponse;
import com.ryzo.Taxcompliance.dto.MessageResponse;
import com.ryzo.Taxcompliance.dto.RefreshTokenRequest;
import com.ryzo.Taxcompliance.dto.RegisterRequest;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.service.AuthService;
import com.ryzo.Taxcompliance.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
// `server.servlet.context-path=/api` already contributes the /api prefix.
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Authentication", description = "Authentication APIs for login, register, and token refresh")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    private final AuthService authService;
    private final UserService userService;

    @PostMapping("/login")
    @Operation(summary = "Authenticate user and return JWT token")
    public ResponseEntity<LoginResponse> authenticateUser(@Valid @RequestBody LoginRequest loginRequest) {
        log.info("Login request for user: {}", loginRequest.getUsername());
        LoginResponse response = authService.authenticateUser(loginRequest);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @Operation(summary = "Register new user")
    public ResponseEntity<MessageResponse> registerUser(@Valid @RequestBody RegisterRequest registerRequest) {
        log.info("Registration request for user: {}", registerRequest.getUsername());
        User user = userService.registerUser(registerRequest);
        return ResponseEntity.ok(new MessageResponse("User registered successfully!", user.getId()));
    }

    @PostMapping("/refresh-token")
    @Operation(summary = "Refresh JWT token using refresh token")
    public ResponseEntity<LoginResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest refreshTokenRequest) {
        log.info("Token refresh request");
        LoginResponse response = authService.refreshToken(refreshTokenRequest.getRefreshToken());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout user and invalidate token")
    public ResponseEntity<MessageResponse> logoutUser(@RequestHeader("Authorization") String token) {
        log.info("Logout request");
        authService.logoutUser(token);
        return ResponseEntity.ok(new MessageResponse("Logged out successfully!"));
    }

    @PostMapping("/verify-email")
    @Operation(summary = "Verify user email with OTP")
    public ResponseEntity<MessageResponse> verifyEmail(@RequestParam String email, @RequestParam String otp) {
        log.info("Email verification for: {}", email);
        authService.verifyEmail(email, otp);
        return ResponseEntity.ok(new MessageResponse("Email verified successfully!"));
    }

    @PostMapping("/resend-verification-otp")
    @Operation(summary = "Resend user verification OTP")
    public ResponseEntity<MessageResponse> resendVerificationOtp(@RequestParam String email) {
        log.info("Resend verification OTP for: {}", email);
        authService.resendVerificationOtp(email);
        return ResponseEntity.ok(new MessageResponse("Verification OTP sent to your email!"));
    }

    @PostMapping("/forgot-password")
    @Operation(summary = "Send OTP for password reset")
    public ResponseEntity<MessageResponse> forgotPassword(@RequestParam String email) {
        log.info("Forgot password request for: {}", email);
        authService.sendPasswordResetOtp(email);
        return ResponseEntity.ok(new MessageResponse("Password reset OTP sent to email!"));
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Reset password using OTP")
    public ResponseEntity<MessageResponse> resetPassword(
            @RequestParam String email,
            @RequestParam String otp,
            @RequestParam String newPassword) {
        log.info("Reset password request for: {}", email);
        authService.resetPassword(email, otp, newPassword);
        return ResponseEntity.ok(new MessageResponse("Password reset successfully!"));
    }
}
