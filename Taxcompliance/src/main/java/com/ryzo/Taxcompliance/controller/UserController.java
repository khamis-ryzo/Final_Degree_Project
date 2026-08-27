package com.ryzo.Taxcompliance.controller;


import com.ryzo.Taxcompliance.dto.MessageResponse;
import com.ryzo.Taxcompliance.dto.request.UpdateProfileRequest;
import com.ryzo.Taxcompliance.dto.response.UserResponse;
import com.ryzo.Taxcompliance.dto.response.DashboardSummaryResponse;
import com.ryzo.Taxcompliance.dto.response.NotificationResponse;
import com.ryzo.Taxcompliance.dto.response.TaxSummaryResponse;
import com.ryzo.Taxcompliance.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "User Management", description = "APIs for managing user profile and account")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {

    private final UserService userService;

    @GetMapping("/profile")
    @Operation(summary = "Get current user profile")
    public ResponseEntity<UserResponse> getCurrentUserProfile(Authentication authentication) {
        String username = authentication.getName();
        log.info("Fetching profile for user: {}", username);
        UserResponse response = userService.getUserProfile(username);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/profile")
    @Operation(summary = "Update user profile")
    public ResponseEntity<UserResponse> updateProfile(
            Authentication authentication,
            @Valid @RequestBody UpdateProfileRequest updateRequest) {
        String username = authentication.getName();
        log.info("Updating profile for user: {}", username);
        UserResponse response = userService.updateUserProfile(username, updateRequest);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/dashboard-summary")
    @Operation(summary = "Get dashboard summary with tax statistics")
    public ResponseEntity<DashboardSummaryResponse> getDashboardSummary(Authentication authentication) {
        String username = authentication.getName();
        log.info("Fetching dashboard summary for user: {}", username);
        DashboardSummaryResponse response = userService.getDashboardSummary(username);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tax-summary/{assessmentYear}")
    @Operation(summary = "Get tax summary for specific assessment year")
    public ResponseEntity<TaxSummaryResponse> getTaxSummary(
            Authentication authentication,
            @PathVariable String assessmentYear) {
        String username = authentication.getName();
        log.info("Fetching tax summary for year: {}", assessmentYear);
        TaxSummaryResponse response = userService.getTaxSummary(username, assessmentYear);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/notifications")
    @Operation(summary = "Get user notifications")
    public ResponseEntity<List<NotificationResponse>> getNotifications(
            Authentication authentication,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        String username = authentication.getName();
        List<NotificationResponse> notifications = userService.getUserNotifications(username, page, size);
        return ResponseEntity.ok(notifications);
    }

    @PutMapping("/notifications/{notificationId}/read")
    @Operation(summary = "Mark notification as read")
    public ResponseEntity<MessageResponse> markNotificationRead(
            Authentication authentication,
            @PathVariable Long notificationId) {
        String username = authentication.getName();
        userService.markNotificationAsRead(username, notificationId);
        return ResponseEntity.ok(new MessageResponse("Notification marked as read"));
    }
}
