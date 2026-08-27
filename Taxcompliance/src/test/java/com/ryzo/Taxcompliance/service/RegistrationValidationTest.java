package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.RegisterRequest;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.exception.DuplicateResourceException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
class RegistrationValidationTest {

    @Autowired
    private UserService userService;

    private User register(String username) {
        RegisterRequest request = new RegisterRequest();
        request.setUsername(username);
        request.setEmail(username + "@example.com");
        request.setPassword("password123");
        request.setTinNumber("T" + System.nanoTime());
        request.setFullName(username.toUpperCase());
        return userService.registerUser(request);
    }

    @Test
    void duplicateUsernameThrowsConflict() {
        String username = "dup_" + System.nanoTime();
        register(username);

        RegisterRequest duplicate = new RegisterRequest();
        duplicate.setUsername(username);
        duplicate.setEmail("another@example.com");
        duplicate.setPassword("password123");
        duplicate.setTinNumber("TIN-DUP");
        duplicate.setFullName("Dup");

        assertThatThrownBy(() -> userService.registerUser(duplicate))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessageContaining("Username already exists");
    }
}
