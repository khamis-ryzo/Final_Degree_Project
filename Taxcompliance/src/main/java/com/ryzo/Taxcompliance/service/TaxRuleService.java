package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.entity.TaxRule;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface TaxRuleService {

    TaxRule createRule(TaxRule taxRule);
    TaxRule updateRule(Long id, TaxRule taxRule);
    TaxRule getRuleById(Long id);
    TaxRule getRuleByCode(String ruleCode);
    List<TaxRule> getAllRules();
    Page<TaxRule> getAllRules(Pageable pageable);
    void deleteRule(Long id);
    void deleteRuleByCode(String ruleCode);

    TaxRule activateRule(Long id);
    TaxRule deactivateRule(Long id);
    TaxRule updateRulePriority(Long id, Integer priority);

    BigDecimal calculateTax(String ruleType, BigDecimal amount, Integer year);
    BigDecimal calculateTax(String ruleType, BigDecimal amount, Integer year, String taxpayerType);
    Map<String, BigDecimal> calculateAllTaxes(BigDecimal income, Integer year);

    List<TaxRule> findActiveRulesByType(String ruleType, Integer year);
    List<TaxRule> findActiveRulesByTypes(List<String> ruleTypes, Integer year);
    List<TaxRule> findActivePayeSlabs(Integer year);
    TaxRule findPayeSlabForIncome(BigDecimal income, Integer year);
    List<TaxRule> findActiveReliefRules(Integer year);
    List<TaxRule> findActiveLevies(Integer year);
    List<TaxRule> findActiveVatRules(Integer year);
    List<TaxRule> findActiveWithholdingTaxRules(Integer year);
    List<TaxRule> findActiveCorporateTaxRules(Integer year);
    List<TaxRule> findActiveRulesForTaxpayerType(Integer year, String taxpayerType);

    TaxSummary getTaxSummary(BigDecimal income, Integer year);
    TaxSummary getTaxSummary(BigDecimal income, Integer year, String taxpayerType);

    List<TaxRule> importRules(List<TaxRule> rules);
    void exportRules(String filePath);

    List<com.ryzo.Taxcompliance.dto.response.TaxRuleResponse> getAllActiveRules();
    List<com.ryzo.Taxcompliance.dto.response.TaxRuleResponse> getRulesByType(String ruleType);
    com.ryzo.Taxcompliance.dto.response.TaxRuleResponse getRuleByCodeResponse(String ruleCode);
    List<com.ryzo.Taxcompliance.dto.response.TaxRuleResponse> getRulesApplicableForYear(String assessmentYear);
    List<com.ryzo.Taxcompliance.dto.response.TaxRuleResponse> getTaxSlabs(String assessmentYear);
    List<com.ryzo.Taxcompliance.dto.response.TaxRuleResponse> getDeductions(String assessmentYear);
    com.ryzo.Taxcompliance.dto.response.TaxRuleResponse createTaxRule(com.ryzo.Taxcompliance.dto.request.TaxRuleRequest request);
    com.ryzo.Taxcompliance.dto.response.TaxRuleResponse updateTaxRule(String ruleCode, com.ryzo.Taxcompliance.dto.request.TaxRuleRequest request);
    void deleteTaxRule(String ruleCode);
    void toggleRuleStatus(String ruleCode, boolean active);
    List<com.ryzo.Taxcompliance.dto.response.TaxRuleResponse> getCurrentFinancialYearRules();

    boolean validateRule(TaxRule rule);
    boolean isRuleCodeAvailable(String ruleCode);
    boolean isRuleActive(String ruleCode);

    List<TaxRule> activateAllRules();
    List<TaxRule> deactivateAllRules();
    List<TaxRule> updateRulesForYear(Integer year);

    Map<String, Long> getRuleCountByType();
    List<TaxRule> getExpiringRules();

    BigDecimal calculateTax(BigDecimal taxableIncome, String assessmentYear);
}