package com.ryzo.Taxcompliance.dto;



import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class TaxRuleRequestDTO {

    @NotBlank(message = "Rule code is required")
    @Size(max = 20, message = "Rule code cannot exceed 20 characters")
    private String ruleCode;

    @NotBlank(message = "Rule name is required")
    private String ruleName;

    @NotBlank(message = "Rule type is required")
    private String ruleType; // TAX_SLAB, DEDUCTION, CESS, SURCHARGE, INTEREST

    @NotNull(message = "Applicable from year is required")
    @Min(value = 2000, message = "Year must be 2000 or later")
    private Integer applicableFromYear;

    @Min(value = 2000, message = "Year must be 2000 or later")
    private Integer applicableToYear;

    @DecimalMin(value = "0.00", message = "Minimum income cannot be negative")
    private BigDecimal minIncome;

    @DecimalMin(value = "0.00", message = "Maximum income cannot be negative")
    private BigDecimal maxIncome;

    @DecimalMin(value = "0.00", message = "Tax rate cannot be negative")
    @DecimalMax(value = "100.00", message = "Tax rate cannot exceed 100%")
    private BigDecimal taxRate;

    @DecimalMin(value = "0.00", message = "Flat amount cannot be negative")
    private BigDecimal flatAmount;

    private String percentageOf; // TAX, INCOME

    @DecimalMin(value = "0.00", message = "Max limit cannot be negative")
    private BigDecimal maxLimit;

    private String conditions; // JSON string

    @Min(value = 0, message = "Priority must be 0 or greater")
    private Integer priority = 0;

    private Boolean isActive = true;
}
