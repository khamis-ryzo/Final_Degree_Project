package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.LoginRequest;
import com.ryzo.Taxcompliance.dto.RegisterRequest;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.text.SimpleDateFormat;
import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
class UserServiceRegistrationTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuthService authService;

    @Test
    void registrationPersistsAllUserDetails() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setUsername("registered_user");
        request.setEmail("REGISTERED@EXAMPLE.COM");
        request.setPassword("securePassword1");
        request.setTinNumber("tin-reg-test");
        request.setFullName("Registered User");
        request.setMobileNumber("0712345678");
        request.setAddress("123 Registration Street");
        request.setDateOfBirth(new SimpleDateFormat("yyyy-MM-dd").parse("1990-01-15"));

        User registeredUser = userService.registerUser(request);
        User savedUser = userRepository.findById(Objects.requireNonNull(registeredUser.getId())).orElseThrow();

        assertThat(savedUser.getId()).isNotNull();
        assertThat(savedUser.getUsername()).isEqualTo("registered_user");
        assertThat(savedUser.getEmail()).isEqualTo("registered@example.com");
        assertThat(savedUser.getTinNumber()).isEqualTo("TIN-REG-TEST");
        assertThat(savedUser.getFullName()).isEqualTo("Registered User");
        assertThat(savedUser.getMobileNumber()).isEqualTo("0712345678");
        assertThat(savedUser.getAddress()).isEqualTo("123 Registration Street");
        assertThat(savedUser.getDateOfBirth()).isNotNull();
        assertThat(savedUser.getPassword()).isNotEqualTo(request.getPassword());
    }

    @Test
    void loginRequiresEmailVerificationBeforeAccessIsGranted() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setUsername("verify_login_user");
        request.setEmail("verify-login@example.com");
        request.setPassword("securePassword1");
        request.setTinNumber("TIN-VERIFY-LOGIN");
        request.setFullName("Verify Login User");
        request.setMobileNumber("0712345678");
        request.setAddress("123 Verification Street");
        request.setDateOfBirth(new SimpleDateFormat("yyyy-MM-dd").parse("1992-05-24"));

        User registeredUser = userService.registerUser(request);
        User savedUser = userRepository.findById(Objects.requireNonNull(registeredUser.getId())).orElseThrow();

        assertThat(savedUser.getEmailVerified()).isFalse();

        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsername(request.getUsername());
        loginRequest.setPassword(request.getPassword());

        assertThatThrownBy(() -> authService.authenticateUser(loginRequest))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("verify your email");

        authService.verifyEmail(request.getEmail(), savedUser.getOtp());
        assertThat(authService.authenticateUser(loginRequest).getEmail())
                .isEqualTo("verify-login@example.com");
    }

    @Test
    void resendVerificationOtpGeneratesNewCodeBeforeEmailIsVerified() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setUsername("resend_otp_user");
        request.setEmail("resend-otp@example.com");
        request.setPassword("securePassword1");
        request.setTinNumber("TIN-RESEND-OTP");
        request.setFullName("Resend OTP User");
        request.setMobileNumber("0712345678");
        request.setAddress("456 Resend Street");
        request.setDateOfBirth(new SimpleDateFormat("yyyy-MM-dd").parse("1988-11-02"));

        User registeredUser = userService.registerUser(request);
        String originalOtp = registeredUser.getOtp();

        authService.resendVerificationOtp(request.getEmail());

        User updatedUser = userRepository.findById(Objects.requireNonNull(registeredUser.getId())).orElseThrow();
        assertThat(updatedUser.getOtp()).isNotBlank();
        assertThat(updatedUser.getOtp()).isNotEqualTo(originalOtp);
        assertThat(updatedUser.getEmailVerified()).isFalse();
    }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
    @Test
    void verifyEmailReissuesOtpWhenUserRecordHasNoStoredCode() throws Exception {
        RegisterRequest request = new RegisterRequest();
        request.setUsername("missing_otp_user");
        request.setEmail("missing-otp@example.com");
        request.setPassword("securePassword1");
        request.setTinNumber("TIN-MISSING-OTP");
        request.setFullName("Missing OTP User");
        request.setMobileNumber("0712345678");
        request.setAddress("789 Missing OTP Street");
        request.setDateOfBirth(new SimpleDateFormat("yyyy-MM-dd").parse("1995-07-12"));

        User registeredUser = userService.registerUser(request);
        User savedUser = userRepository.findById(Objects.requireNonNull(registeredUser.getId())).orElseThrow();
        savedUser.setOtp(null);
        savedUser.setOtpExpiry(null);
        userRepository.save(savedUser);

        assertThatThrownBy(() -> authService.verifyEmail(request.getEmail(), "000000"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("A new code has been sent");

        User refreshedUser = userRepository.findById(Objects.requireNonNull(registeredUser.getId())).orElseThrow();
        assertThat(refreshedUser.getOtp()).isNotBlank();
        assertThat(refreshedUser.getOtpExpiry()).isNotNull();
    }
}
