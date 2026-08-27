package com.ryzo.Taxcompliance.dto.request;


import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class TaxReturnRequest {

    @NotBlank(message = "Assessment year is required")
    @Pattern(regexp = "\\d{4}-\\d{2}", message = "Assessment year must be in format YYYY-YY (e.g., 2024-25)")
    private String assessmentYear;

    @NotNull(message = "Total income is required")
    @DecimalMin(value = "0.00", message = "Total income cannot be negative")
    @DecimalMax(value = "999999999.99", message = "Total income exceeds maximum limit")
    private BigDecimal totalIncome;

    @DecimalMin(value = "0.00", message = "Deductions cannot be negative")
    @DecimalMax(value = "999999999.99", message = "Deductions exceed maximum limit")
    private BigDecimal deductions = BigDecimal.ZERO;

    private String filingType = "ORIGINAL"; // ORIGINAL, REVISED, BELATED

    private String additionalInfo;
}
