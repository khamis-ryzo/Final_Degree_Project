package com.ryzo.Taxcompliance.dto.response;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class TaxRuleResponse {
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
    private Integer priority;
    private Boolean isActive;
}
