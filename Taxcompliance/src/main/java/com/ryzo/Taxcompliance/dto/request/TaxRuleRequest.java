package com.ryzo.Taxcompliance.dto.request;

import lombok.Data;

@Data
public class TaxRuleRequest {
    private String ruleCode;
    private String ruleName;
    private String ruleType;
}
