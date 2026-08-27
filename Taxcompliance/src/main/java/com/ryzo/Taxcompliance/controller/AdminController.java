package com.ryzo.Taxcompliance.controller;

import com.ryzo.Taxcompliance.dto.*;
import com.ryzo.Taxcompliance.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@Slf4j
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Admin Dashboard", description = "APIs for system administration")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AdminController {

    private final AdminService adminService;

    @Operation(summary = "Get admin dashboard statistics")
    @GetMapping("/dashboard/stats")
    public ResponseEntity<AdminDashboardResponse> getDashboardStats() {
        log.info("Fetching admin dashboard statistics");
        AdminDashboardResponse stats = adminService.getDashboardStatistics();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/users")
    @Operation(summary = "Get all users with pagination")
    public ResponseEntity<Page<UserResponseDTO>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) Boolean isActive) {
        log.info("Fetching all users with filters - role: {}, active: {}", role, isActive);
        Page<UserResponseDTO> users = adminService.getAllUsers(page, size, role, isActive);
        return ResponseEntity.ok(users);
    }

    @GetMapping("/users/{userId}")
    @Operation(summary = "Get user details by ID")
    public ResponseEntity<UserResponseDTO> getUserById(@PathVariable Long userId) {
        log.info("Fetching user details for ID: {}", userId);
        UserResponseDTO user = adminService.getUserById(userId);
        return ResponseEntity.ok(user);
    }

    @PutMapping("/users/{userId}/status")
    @Operation(summary = "Activate or deactivate user account")
    public ResponseEntity<MessageResponse> toggleUserStatus(
            @PathVariable Long userId,
            @RequestParam boolean active) {
        log.info("Toggling user status for ID: {} to active: {}", userId, active);
        MessageResponse response = adminService.toggleUserStatus(userId, active);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/users/{userId}")
    @Operation(summary = "Delete user account")
    public ResponseEntity<MessageResponse> deleteUser(@PathVariable Long userId) {
        log.info("Deleting user with ID: {}", userId);
        MessageResponse response = adminService.deleteUser(userId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tax-returns")
    @Operation(summary = "Get all tax returns with pagination")
    public ResponseEntity<Page<TaxReturnResponseDTO>> getAllTaxReturns(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String assessmentYear) {
        log.info("Fetching all tax returns - status: {}, year: {}", status, assessmentYear);
        Page<TaxReturnResponseDTO> returns = adminService.getAllTaxReturns(page, size, status, assessmentYear);
        return ResponseEntity.ok(returns);
    }

    @GetMapping("/tax-returns/{returnId}")
    @Operation(summary = "Get tax return details by ID")
    public ResponseEntity<TaxReturnResponseDTO> getTaxReturnById(@PathVariable Long returnId) {
        log.info("Fetching tax return details for ID: {}", returnId);
        TaxReturnResponseDTO taxReturn = adminService.getTaxReturnById(returnId);
        return ResponseEntity.ok(taxReturn);
    }

    @PutMapping("/tax-returns/{returnId}/status")
    @Operation(summary = "Update tax return status")
    public ResponseEntity<MessageResponse> updateTaxReturnStatus(
            @PathVariable Long returnId,
            @RequestParam String status,
            @RequestParam(required = false) String remarks) {
        log.info("Updating tax return status for ID: {} to: {}", returnId, status);
        MessageResponse response = adminService.updateTaxReturnStatus(returnId, status, remarks);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tax-rules")
    @Operation(summary = "Get all tax rules")
    public ResponseEntity<Page<TaxRuleResponseDTO>> getAllTaxRules(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String ruleType) {
        log.info("Fetching all tax rules - type: {}", ruleType);
        Page<TaxRuleResponseDTO> rules = adminService.getAllTaxRules(page, size, ruleType);
        return ResponseEntity.ok(rules);
    }

    @PostMapping("/tax-rules")
    @Operation(summary = "Create new tax rule")
    public ResponseEntity<TaxRuleResponseDTO> createTaxRule(@RequestBody TaxRuleRequestDTO request) {
        log.info("Creating new tax rule: {}", request.getRuleCode());
        TaxRuleResponseDTO response = adminService.createTaxRule(request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/tax-rules/{ruleId}")
    @Operation(summary = "Update existing tax rule")
    public ResponseEntity<TaxRuleResponseDTO> updateTaxRule(
            @PathVariable Long ruleId,
            @RequestBody TaxRuleRequestDTO request) {
        log.info("Updating tax rule with ID: {}", ruleId);
        TaxRuleResponseDTO response = adminService.updateTaxRule(ruleId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/tax-rules/{ruleId}")
    @Operation(summary = "Delete tax rule")
    public ResponseEntity<MessageResponse> deleteTaxRule(@PathVariable Long ruleId) {
        log.info("Deleting tax rule with ID: {}", ruleId);
        MessageResponse response = adminService.deleteTaxRule(ruleId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/dashboard/recent-activity")
    @Operation(summary = "Get recent system activity")
    public ResponseEntity<RecentActivityResponse> getRecentActivity(
            @RequestParam(defaultValue = "10") int limit) {
        log.info("Fetching recent activity with limit: {}", limit);
        RecentActivityResponse activity = adminService.getRecentActivity(limit);
        return ResponseEntity.ok(activity);
    }

    @GetMapping("/dashboard/compliance-summary")
    @Operation(summary = "Get compliance summary")
    public ResponseEntity<ComplianceSummaryResponse> getComplianceSummary() {
        log.info("Fetching compliance summary");
        ComplianceSummaryResponse summary = adminService.getComplianceSummary();
        return ResponseEntity.ok(summary);
    }
}
