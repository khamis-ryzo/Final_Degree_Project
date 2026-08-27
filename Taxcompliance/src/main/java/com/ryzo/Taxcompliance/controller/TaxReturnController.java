package com.ryzo.Taxcompliance.controller;

import com.ryzo.Taxcompliance.dto.request.TaxCalculationRequest;
import com.ryzo.Taxcompliance.dto.request.TaxReturnRequest;
import com.ryzo.Taxcompliance.dto.response.DueDateResponse;
import com.ryzo.Taxcompliance.dto.response.MessageResponse;
import com.ryzo.Taxcompliance.dto.response.TaxCalculationResponse;
import com.ryzo.Taxcompliance.dto.response.TaxReturnResponse;
import com.ryzo.Taxcompliance.service.TaxReturnService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/tax-returns")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Tax Returns", description = "APIs for managing tax return filing")
@CrossOrigin(origins = "*", maxAge = 3600)
public class TaxReturnController {

    private final TaxReturnService taxReturnService;

    @PostMapping("/calculate")
    @Operation(summary = "Calculate tax liability based on income and deductions")
    public ResponseEntity<TaxCalculationResponse> calculateTax(
            Authentication authentication,
            @Valid @RequestBody TaxCalculationRequest request) {
        String username = authentication.getName();
        log.info("Tax calculation request for user: {}", username);
        TaxCalculationResponse response = taxReturnService.calculateTax(username, request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/create")
    @Operation(summary = "Create a new tax return draft")
    public ResponseEntity<TaxReturnResponse> createTaxReturn(
            Authentication authentication,
            @RequestBody(required = false) Map<String, String> payload) {
        String username = authentication.getName();
        String assessmentYear = payload != null ? payload.get("assessmentYear") : null;
        log.info("Creating tax return for year: {} for user: {}", assessmentYear, username);
        TaxReturnResponse response = taxReturnService.createTaxReturn(username, assessmentYear);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{returnId}")
    @Operation(summary = "Update tax return draft")
    public ResponseEntity<TaxReturnResponse> updateTaxReturn(
            Authentication authentication,
            @PathVariable Long returnId,
            @Valid @RequestBody TaxReturnRequest request) {
        String username = authentication.getName();
        log.info("Updating tax return: {} for user: {}", returnId, username);
        TaxReturnResponse response = taxReturnService.updateTaxReturn(username, returnId, request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{returnId}/submit")
    @Operation(summary = "Submit tax return for filing")
    public ResponseEntity<TaxReturnResponse> submitTaxReturn(
            Authentication authentication,
            @PathVariable Long returnId) {
        String username = authentication.getName();
        log.info("Submitting tax return: {} for user: {}", returnId, username);
        TaxReturnResponse response = taxReturnService.submitTaxReturn(username, returnId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{returnId}")
    @Operation(summary = "Get tax return by ID")
    public ResponseEntity<TaxReturnResponse> getTaxReturnById(
            Authentication authentication,
            @PathVariable Long returnId) {
        String username = authentication.getName();
        log.info("Fetching tax return: {} for user: {}", returnId, username);
        TaxReturnResponse response = taxReturnService.getTaxReturnById(username, returnId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/filing-id/{filingId}")
    @Operation(summary = "Get tax return by filing ID")
    public ResponseEntity<TaxReturnResponse> getTaxReturnByFilingId(
            Authentication authentication,
            @PathVariable String filingId) {
        String username = authentication.getName();
        log.info("Fetching tax return by filing ID: {} for user: {}", filingId, username);
        TaxReturnResponse response = taxReturnService.getTaxReturnByFilingId(username, filingId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/my-returns")
    @Operation(summary = "Get all tax returns for current user")
    public ResponseEntity<Page<TaxReturnResponse>> getUserTaxReturns(
            Authentication authentication,
            Pageable pageable) {
        String username = authentication.getName();
        log.info("Fetching all tax returns for user: {}", username);
        Page<TaxReturnResponse> responses = taxReturnService.getUserTaxReturns(username, pageable);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/my-returns/year/{assessmentYear}")
    @Operation(summary = "Get tax return for specific assessment year")
    public ResponseEntity<TaxReturnResponse> getTaxReturnByYear(
            Authentication authentication,
            @PathVariable String assessmentYear) {
        String username = authentication.getName();
        log.info("Fetching tax return for year: {} for user: {}", assessmentYear, username);
        TaxReturnResponse response = taxReturnService.getTaxReturnByYear(username, assessmentYear);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/history")
    @Operation(summary = "Get filing history with filters")
    public ResponseEntity<List<TaxReturnResponse>> getFilingHistory(
            Authentication authentication,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate toDate) {
        String username = authentication.getName();
        log.info("Fetching filing history for user: {} with filters", username);
        List<TaxReturnResponse> responses = taxReturnService.getFilingHistory(username, status, fromDate, toDate);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{returnId}/download-acknowledgment")
    @Operation(summary = "Download acknowledgment PDF")
    public ResponseEntity<byte[]> downloadAcknowledgment(
            Authentication authentication,
            @PathVariable Long returnId) {
        String username = authentication.getName();
        log.info("Downloading acknowledgment for return: {}", returnId);
        byte[] pdfContent = taxReturnService.generateAcknowledgmentPdf(username, returnId);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=acknowledgment_" + returnId + ".pdf")
                .contentType(MediaType.valueOf("application/pdf"))
                .body(pdfContent);
    }

    @GetMapping("/{returnId}/download-return")
    @Operation(summary = "Download complete tax return PDF")
    public ResponseEntity<byte[]> downloadTaxReturn(
            Authentication authentication,
            @PathVariable Long returnId) {
        String username = authentication.getName();
        log.info("Downloading tax return: {}", returnId);
        byte[] pdfContent = taxReturnService.generateTaxReturnPdf(username, returnId);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=tax_return_" + returnId + ".pdf")
                .contentType(MediaType.valueOf("application/pdf"))
                .body(pdfContent);
    }

    @DeleteMapping("/{returnId}")
    @Operation(summary = "Delete draft tax return")
    public ResponseEntity<MessageResponse> deleteDraftReturn(
            Authentication authentication,
            @PathVariable Long returnId) {
        String username = authentication.getName();
        log.info("Deleting draft return: {}", returnId);
        taxReturnService.deleteDraftReturn(username, returnId);
        return ResponseEntity.ok(new MessageResponse("Draft return deleted successfully"));
    }

    @GetMapping("/due-dates")
    @Operation(summary = "Get upcoming filing due dates")
    public ResponseEntity<List<DueDateResponse>> getDueDates(Authentication authentication) {
        String username = authentication.getName();
        log.info("Fetching due dates for user: {}", username);
        List<DueDateResponse> dueDates = taxReturnService.getUpcomingDueDates(username);
        return ResponseEntity.ok(dueDates);
    }
}
