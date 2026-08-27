package com.ryzo.Taxcompliance.controller;

import com.ryzo.Taxcompliance.dto.request.TaxRuleRequest;
import com.ryzo.Taxcompliance.dto.response.TaxRuleResponse;
import com.ryzo.Taxcompliance.dto.response.MessageResponse;
import com.ryzo.Taxcompliance.service.TaxRuleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/tax-rules")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Tax Rules", description = "APIs for managing tax calculation rules")
@CrossOrigin(origins = "*", maxAge = 3600)
public class TaxRuleController {

    private final TaxRuleService taxRuleService;

    @GetMapping
    @Operation(summary = "Get all active tax rules")
    public ResponseEntity<List<TaxRuleResponse>> getAllActiveRules() {
        log.info("Fetching all active tax rules");
        List<TaxRuleResponse> rules = taxRuleService.getAllActiveRules();
        return ResponseEntity.ok(rules);
    }

    @GetMapping("/type/{ruleType}")
    @Operation(summary = "Get tax rules by type")
    public ResponseEntity<List<TaxRuleResponse>> getRulesByType(@PathVariable String ruleType) {
        log.info("Fetching tax rules by type: {}", ruleType);
        List<TaxRuleResponse> rules = taxRuleService.getRulesByType(ruleType);
        return ResponseEntity.ok(rules);
    }

    @GetMapping("/{ruleCode}")
    @Operation(summary = "Get tax rule by code")
    public ResponseEntity<TaxRuleResponse> getRuleByCode(@PathVariable String ruleCode) {
        log.info("Fetching tax rule by code: {}", ruleCode);
        TaxRuleResponse rule = taxRuleService.getRuleByCodeResponse(ruleCode);
        return ResponseEntity.ok(rule);
    }

    @GetMapping("/applicable/{assessmentYear}")
    @Operation(summary = "Get rules applicable for specific assessment year")
    public ResponseEntity<List<TaxRuleResponse>> getRulesApplicableForYear(@PathVariable String assessmentYear) {
        log.info("Fetching rules applicable for year: {}", assessmentYear);
        List<TaxRuleResponse> rules = taxRuleService.getRulesApplicableForYear(assessmentYear);
        return ResponseEntity.ok(rules);
    }

    @GetMapping("/tax-slabs/{assessmentYear}")
    @Operation(summary = "Get tax slabs for assessment year")
    public ResponseEntity<List<TaxRuleResponse>> getTaxSlabs(@PathVariable String assessmentYear) {
        log.info("Fetching tax slabs for year: {}", assessmentYear);
        List<TaxRuleResponse> slabs = taxRuleService.getTaxSlabs(assessmentYear);
        return ResponseEntity.ok(slabs);
    }

    @GetMapping("/deductions/{assessmentYear}")
    @Operation(summary = "Get deductions available for assessment year")
    public ResponseEntity<List<TaxRuleResponse>> getDeductions(@PathVariable String assessmentYear) {
        log.info("Fetching deductions for year: {}", assessmentYear);
        List<TaxRuleResponse> deductions = taxRuleService.getDeductions(assessmentYear);
        return ResponseEntity.ok(deductions);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create new tax rule (Admin only)")
    public ResponseEntity<TaxRuleResponse> createTaxRule(@Valid @RequestBody TaxRuleRequest request) {
        log.info("Creating new tax rule: {}", request.getRuleCode());
        TaxRuleResponse response = taxRuleService.createTaxRule(request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{ruleCode}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update existing tax rule (Admin only)")
    public ResponseEntity<TaxRuleResponse> updateTaxRule(
            @PathVariable String ruleCode,
            @Valid @RequestBody TaxRuleRequest request) {
        log.info("Updating tax rule: {}", ruleCode);
        TaxRuleResponse response = taxRuleService.updateTaxRule(ruleCode, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{ruleCode}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete tax rule (Admin only)")
    public ResponseEntity<MessageResponse> deleteTaxRule(@PathVariable String ruleCode) {
        log.info("Deleting tax rule: {}", ruleCode);
        taxRuleService.deleteTaxRule(ruleCode);
        return ResponseEntity.ok(new MessageResponse("Tax rule deleted successfully"));
    }

    @PatchMapping("/{ruleCode}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Activate or deactivate tax rule (Admin only)")
    public ResponseEntity<MessageResponse> toggleRuleStatus(
            @PathVariable String ruleCode,
            @RequestParam boolean active) {
        log.info("Setting rule {} active status to: {}", ruleCode, active);
        taxRuleService.toggleRuleStatus(ruleCode, active);
        return ResponseEntity.ok(new MessageResponse("Rule status updated successfully"));
    }

    @GetMapping("/current-year-rules")
    @Operation(summary = "Get all rules for current financial year")
    public ResponseEntity<List<TaxRuleResponse>> getCurrentYearRules() {
        log.info("Fetching rules for current financial year");
        List<TaxRuleResponse> rules = taxRuleService.getCurrentFinancialYearRules();
        return ResponseEntity.ok(rules);
    }
}
