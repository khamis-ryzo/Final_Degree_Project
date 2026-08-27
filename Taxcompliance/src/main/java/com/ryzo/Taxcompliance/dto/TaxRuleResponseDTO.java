package com.ryzo.Taxcompliance.dto;


import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaxRuleResponseDTO {
    private Long id;
    private String ruleCode;
    private String ruleName;
    private String ruleType;
    private Integer applicableFromYear;
    private Integer applicableToYear;
    private BigDecimal minIncome;
    private BigDecimal maxIncome;
    private BigDecimal taxRate;
    private BigDecimal flatAmount;
    private String percentageOf;
    private BigDecimal maxLimit;
    private String conditions;
    private Integer priority;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
