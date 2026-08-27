package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.request.TaxRuleRequest;
import com.ryzo.Taxcompliance.dto.response.TaxRuleResponse;
import com.ryzo.Taxcompliance.entity.TaxRule;
import com.ryzo.Taxcompliance.exception.DuplicateResourceException;
import com.ryzo.Taxcompliance.exception.ResourceNotFoundException;
import com.ryzo.Taxcompliance.repository.TaxRuleRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class TaxRuleServiceImpl implements TaxRuleService {

    private final TaxRuleRepository taxRuleRepository;

    @Override
    public TaxRule createRule(TaxRule taxRule) {
        log.info("Creating new tax rule: {}", taxRule.getRuleCode());

        if (taxRuleRepository.findByRuleCode(taxRule.getRuleCode()).isPresent()) {
            throw new DuplicateResourceException("Rule with code " + taxRule.getRuleCode() + " already exists");
        }

        validateRule(taxRule);
        return taxRuleRepository.save(taxRule);
    }

    @Override
    public TaxRule updateRule(Long id, TaxRule taxRule) {
        log.info("Updating tax rule: {}", id);

        TaxRule existingRule = getRuleById(id);
        existingRule.setRuleCode(taxRule.getRuleCode());
        existingRule.setRuleName(taxRule.getRuleName());
        existingRule.setRuleType(taxRule.getRuleType());
        existingRule.setApplicableFromYear(taxRule.getApplicableFromYear());
        existingRule.setApplicableToYear(taxRule.getApplicableToYear());
        existingRule.setMinIncome(taxRule.getMinIncome());
        existingRule.setMaxIncome(taxRule.getMaxIncome());
        existingRule.setTaxRate(taxRule.getTaxRate());
        existingRule.setFlatAmount(taxRule.getFlatAmount());
        existingRule.setPercentageOf(taxRule.getPercentageOf());
        existingRule.setMaxLimit(taxRule.getMaxLimit());
        existingRule.setConditions(taxRule.getConditions());
        existingRule.setPriority(taxRule.getPriority());
        existingRule.setIsActive(taxRule.getIsActive());

        validateRule(existingRule);
        return taxRuleRepository.save(existingRule);
    }

    @Override
    public TaxRule getRuleById(Long id) {
        Objects.requireNonNull(id, "Tax rule id must not be null");
        return taxRuleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tax rule not found with ID: " + id));
    }

    @Override
    public TaxRule getRuleByCode(String ruleCode) {
        return taxRuleRepository.findByRuleCode(ruleCode)
                .orElseThrow(() -> new ResourceNotFoundException("Tax rule not found with code: " + ruleCode));
    }

    @Override
    public List<TaxRule> getAllRules() {
        return taxRuleRepository.findAll();
    }

    @Override
    public Page<TaxRule> getAllRules(Pageable pageable) {
        Objects.requireNonNull(pageable, "Pageable must not be null");
        return taxRuleRepository.findAll(pageable);
    }

    @Override
    public void deleteRule(Long id) {
        log.info("Deleting tax rule: {}", id);
        taxRuleRepository.deleteById(Objects.requireNonNull(id));
    }

    @Override
    public void deleteRuleByCode(String ruleCode) {
        log.info("Deleting tax rule by code: {}", ruleCode);
        taxRuleRepository.delete(Objects.requireNonNull(getRuleByCode(ruleCode)));
    }

    @Override
    public TaxRule activateRule(Long id) {
        log.info("Activating tax rule: {}", id);
        TaxRule rule = getRuleById(id);
        rule.setIsActive(true);
        return taxRuleRepository.save(rule);
    }

    @Override
    public TaxRule deactivateRule(Long id) {
        log.info("Deactivating tax rule: {}", id);
        TaxRule rule = getRuleById(id);
        rule.setIsActive(false);
        return taxRuleRepository.save(rule);
    }

    @Override
    public TaxRule updateRulePriority(Long id, Integer priority) {
        log.info("Updating priority for rule: {} to {}", id, priority);
        TaxRule rule = getRuleById(id);
        rule.setPriority(priority);
        return taxRuleRepository.save(rule);
    }

    @Override
    public BigDecimal calculateTax(String ruleType, BigDecimal amount, Integer year) {
        return calculateTax(ruleType, amount, year, "INDIVIDUAL");
    }

    @Override
    public BigDecimal calculateTax(String ruleType, BigDecimal amount, Integer year, String taxpayerType) {
        log.info("Calculating tax for type: {}, amount: {}, year: {}", ruleType, amount, year);

        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        if ("PAYE".equals(ruleType)) {
            return calculatePaye(amount, year);
        }

        List<TaxRule> rules = findActiveRulesByType(ruleType, year);
        if (rules.isEmpty()) {
            log.warn("No active rules found for type: {} in year: {}", ruleType, year);
            return BigDecimal.ZERO;
        }

        TaxRule rule = rules.get(0);
        if (rule.getTaxRate() == null) {
            return BigDecimal.ZERO;
        }
        return amount.multiply(rule.getTaxRate())
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
    }

    private BigDecimal calculatePaye(BigDecimal income, Integer year) {
        List<TaxRule> slabs = findActivePayeSlabs(year);
        if (slabs.isEmpty()) {
            return BigDecimal.ZERO;
        }

        BigDecimal tax = BigDecimal.ZERO;
        for (TaxRule slab : slabs) {
            BigDecimal slabMin = slab.getMinIncome() != null ? slab.getMinIncome() : BigDecimal.ZERO;
            if (income.compareTo(slabMin) <= 0) {
                break;
            }

            BigDecimal taxableInSlab;
            if (slab.getMaxIncome() == null) {
                taxableInSlab = income.subtract(slabMin);
            } else {
                taxableInSlab = income.min(slab.getMaxIncome()).subtract(slabMin);
                if (taxableInSlab.compareTo(BigDecimal.ZERO) < 0) {
                    taxableInSlab = BigDecimal.ZERO;
                }
            }

            BigDecimal rate = slab.getTaxRate() != null ? slab.getTaxRate() : BigDecimal.ZERO;
            tax = tax.add(taxableInSlab.multiply(rate)
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP));
        }
        return tax;
    }

    @Override
    public Map<String, BigDecimal> calculateAllTaxes(BigDecimal income, Integer year) {
        Map<String, BigDecimal> taxMap = new LinkedHashMap<>();
        taxMap.put("PAYE", calculateTax("PAYE", income, year));
        taxMap.put("SKILLS_LEVY", calculateTax("SKILLS_LEVY", income, year));
        taxMap.put("RAILWAY_LEVY", calculateTax("RAILWAY_LEVY", income, year));
        return taxMap;
    }

    @Override
    public List<TaxRule> findActiveRulesByType(String ruleType, Integer year) {
        List<TaxRule> rules = taxRuleRepository.findByRuleTypeAndIsActiveTrue(ruleType);
        if (year == null) {
            return rules;
        }
        return rules.stream()
                .filter(rule -> isApplicableForYear(rule, year))
                .collect(Collectors.toList());
    }

    @Override
    public List<TaxRule> findActiveRulesByTypes(List<String> ruleTypes, Integer year) {
        if (ruleTypes == null || ruleTypes.isEmpty()) {
            return new ArrayList<>();
        }
        List<TaxRule> result = new ArrayList<>();
        for (String ruleType : ruleTypes) {
            result.addAll(findActiveRulesByType(ruleType, year));
        }
        return result;
    }

    @Override
    public List<TaxRule> findActivePayeSlabs(Integer year) {
        return taxRuleRepository.findActiveTaxSlabsForYear(year);
    }

    @Override
    public TaxRule findPayeSlabForIncome(BigDecimal income, Integer year) {
        List<TaxRule> slabs = findActivePayeSlabs(year);
        TaxRule matching = null;
        for (TaxRule slab : slabs) {
            BigDecimal slabMin = slab.getMinIncome() != null ? slab.getMinIncome() : BigDecimal.ZERO;
            if (income.compareTo(slabMin) < 0) {
                break;
            }
            matching = slab;
            if (slab.getMaxIncome() != null && income.compareTo(slab.getMaxIncome()) <= 0) {
                break;
            }
        }
        return matching;
    }

    @Override
    public List<TaxRule> findActiveReliefRules(Integer year) {
        return findActiveRulesByType("RELIEF", year);
    }

    @Override
    public List<TaxRule> findActiveLevies(Integer year) {
        return findActiveRulesByTypes(List.of("LEVY", "SKILLS_LEVY", "RAILWAY_LEVY"), year);
    }

    @Override
    public List<TaxRule> findActiveVatRules(Integer year) {
        return findActiveRulesByType("VAT", year);
    }

    @Override
    public List<TaxRule> findActiveWithholdingTaxRules(Integer year) {
        return findActiveRulesByType("WITHHOLDING", year);
    }

    @Override
    public List<TaxRule> findActiveCorporateTaxRules(Integer year) {
        return findActiveRulesByType("CORPORATE", year);
    }

    @Override
    public List<TaxRule> findActiveRulesForTaxpayerType(Integer year, String taxpayerType) {
        if (taxpayerType == null) {
            return new ArrayList<>();
        }
        String normalized = taxpayerType.toUpperCase();
        return taxRuleRepository.findByIsActiveTrueOrderByPriorityAsc().stream()
                .filter(rule -> isApplicableForYear(rule, year))
                .filter(rule -> rule.getRuleType() != null
                        && (rule.getRuleType().contains(normalized)
                        || (rule.getPercentageOf() != null && rule.getPercentageOf().toUpperCase().contains(normalized))))
                .collect(Collectors.toList());
    }

    @Override
    public TaxSummary getTaxSummary(BigDecimal income, Integer year) {
        return getTaxSummary(income, year, "INDIVIDUAL");
    }

    @Override
    public TaxSummary getTaxSummary(BigDecimal income, Integer year, String taxpayerType) {
        TaxSummary summary = new TaxSummary();
        summary.setYear(year);
        summary.setTaxpayerType(taxpayerType);
        summary.setGrossIncome(income);
        summary.setPaye(calculateTax("PAYE", income, year, taxpayerType));
        summary.setSkillsLevy(calculateTax("SKILLS_LEVY", income, year, taxpayerType));
        summary.setRailwayLevy(calculateTax("RAILWAY_LEVY", income, year, taxpayerType));
        summary.setCess(BigDecimal.ZERO);
        summary.setTotalTax(summary.getPaye().add(summary.getSkillsLevy()).add(summary.getRailwayLevy()));
        summary.setNetTax(summary.getTotalTax());
        return summary;
    }

    @Override
    public List<TaxRuleResponse> getAllActiveRules() {
        return taxRuleRepository.findByIsActiveTrueOrderByPriorityAsc().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaxRuleResponse> getRulesByType(String ruleType) {
        return taxRuleRepository.findByRuleTypeAndIsActiveTrue(ruleType).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public TaxRuleResponse getRuleByCodeResponse(String ruleCode) {
        return mapToResponse(getRuleByCode(ruleCode));
    }

    @Override
    public List<TaxRuleResponse> getRulesApplicableForYear(String assessmentYear) {
        Integer year = parseYear(assessmentYear);
        return taxRuleRepository.findByIsActiveTrueOrderByPriorityAsc().stream()
                .filter(rule -> isApplicableForYear(rule, year))
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaxRuleResponse> getTaxSlabs(String assessmentYear) {
        return taxRuleRepository.findActiveTaxSlabsForYear(parseYear(assessmentYear)).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaxRuleResponse> getDeductions(String assessmentYear) {
        return taxRuleRepository.findActiveDeductionsForYear(parseYear(assessmentYear)).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public TaxRuleResponse createTaxRule(TaxRuleRequest request) {
        Objects.requireNonNull(request, "Tax rule request is required");
        if (taxRuleRepository.findByRuleCode(request.getRuleCode()).isPresent()) {
            throw new DuplicateResourceException("Rule with code " + request.getRuleCode() + " already exists");
        }

        TaxRule rule = new TaxRule();
        rule.setRuleCode(request.getRuleCode());
        rule.setRuleName(request.getRuleName());
        rule.setRuleType(request.getRuleType());
        rule.setIsActive(true);
        rule.setPriority(0);
        return mapToResponse(taxRuleRepository.save(rule));
    }

    @Override
    public TaxRuleResponse updateTaxRule(String ruleCode, TaxRuleRequest request) {
        Objects.requireNonNull(request, "Tax rule request is required");
        TaxRule rule = getRuleByCode(ruleCode);
        rule.setRuleName(request.getRuleName());
        rule.setRuleType(request.getRuleType());
        return mapToResponse(taxRuleRepository.save(rule));
    }

    @Override
    public void deleteTaxRule(String ruleCode) {
        taxRuleRepository.delete(Objects.requireNonNull(getRuleByCode(ruleCode)));
    }

    @Override
    public void toggleRuleStatus(String ruleCode, boolean active) {
        TaxRule rule = getRuleByCode(ruleCode);
        rule.setIsActive(active);
        taxRuleRepository.save(rule);
    }

    @Override
    public List<TaxRuleResponse> getCurrentFinancialYearRules() {
        return getRulesApplicableForYear(currentAssessmentYear());
    }

    @Override
    public List<TaxRule> importRules(List<TaxRule> rules) {
        List<TaxRule> imported = new ArrayList<>();
        for (TaxRule rule : rules) {
            if (validateRule(rule) && isRuleCodeAvailable(rule.getRuleCode())) {
                imported.add(taxRuleRepository.save(rule));
            }
        }
        return imported;
    }

    @Override
    public void exportRules(String filePath) {
        log.info("Exporting tax rules to: {}", filePath);
    }

    @Override
    public boolean validateRule(TaxRule rule) {
        return rule.getRuleCode() != null && !rule.getRuleCode().isBlank()
                && rule.getRuleName() != null && !rule.getRuleName().isBlank()
                && rule.getRuleType() != null && !rule.getRuleType().isBlank();
    }

    @Override
    public boolean isRuleCodeAvailable(String ruleCode) {
        return taxRuleRepository.findByRuleCode(ruleCode).isEmpty();
    }

    @Override
    public boolean isRuleActive(String ruleCode) {
        return taxRuleRepository.findByRuleCode(ruleCode).map(r -> r.getIsActive()).orElse(false);
    }

    @Override
    public List<TaxRule> activateAllRules() {
        List<TaxRule> rules = taxRuleRepository.findAll();
        rules.forEach(rule -> rule.setIsActive(true));
        return taxRuleRepository.saveAll(rules);
    }

    @Override
    public List<TaxRule> deactivateAllRules() {
        List<TaxRule> rules = taxRuleRepository.findAll();
        rules.forEach(rule -> rule.setIsActive(false));
        return taxRuleRepository.saveAll(rules);
    }

    @Override
    public List<TaxRule> updateRulesForYear(Integer year) {
        return taxRuleRepository.findByIsActiveTrueOrderByPriorityAsc().stream()
                .filter(rule -> isApplicableForYear(rule, year))
                .collect(Collectors.toList());
    }

    @Override
    public Map<String, Long> getRuleCountByType() {
        Map<String, Long> counts = new HashMap<>();
        for (TaxRule rule : taxRuleRepository.findAll()) {
            String type = rule.getRuleType();
            Long current = counts.get(type);
            counts.put(type, current == null ? 1L : current + 1L);
        }
        return counts;
    }

    @Override
    public List<TaxRule> getExpiringRules() {
        int currentYear = LocalDate.now().getYear();
        return taxRuleRepository.findAll().stream()
                .filter(rule -> rule.getApplicableToYear() != null
                        && rule.getApplicableToYear() <= currentYear)
                .collect(Collectors.toList());
    }

    @Override
    public BigDecimal calculateTax(BigDecimal taxableIncome, String assessmentYear) {
        return calculateTax("PAYE", taxableIncome, parseYear(assessmentYear));
    }

    private boolean isApplicableForYear(TaxRule rule, Integer year) {
        if (year == null) {
            return true;
        }
        if (rule.getApplicableFromYear() != null && year < rule.getApplicableFromYear()) {
            return false;
        }
        return rule.getApplicableToYear() == null || year <= rule.getApplicableToYear();
    }

    private Integer parseYear(String assessmentYear) {
        if (assessmentYear == null || assessmentYear.isBlank()) {
            return LocalDate.now().getYear();
        }
        String digits = assessmentYear.trim();
        int separator = indexOfYearSeparator(digits);
        if (separator > 0) {
            digits = digits.substring(0, separator);
        }
        try {
            return Integer.parseInt(digits.trim());
        } catch (NumberFormatException e) {
            return LocalDate.now().getYear();
        }
    }

    private int indexOfYearSeparator(String value) {
        int dash = value.indexOf('-');
        int slash = value.indexOf('/');
        if (dash < 0) {
            return slash;
        }
        if (slash < 0) {
            return dash;
        }
        return Math.min(dash, slash);
    }

    private String currentAssessmentYear() {
        int current = LocalDate.now().getYear();
        return current + "/" + (current + 1);
    }

    private TaxRuleResponse mapToResponse(TaxRule rule) {
        TaxRuleResponse response = new TaxRuleResponse();
        response.setId(rule.getId());
        response.setRuleCode(rule.getRuleCode());
        response.setRuleName(rule.getRuleName());
        response.setRuleType(rule.getRuleType());
        response.setApplicableFromYear(rule.getApplicableFromYear());
        response.setApplicableToYear(rule.getApplicableToYear());
        response.setMinIncome(rule.getMinIncome());
        response.setMaxIncome(rule.getMaxIncome());
        response.setTaxRate(rule.getTaxRate());
        response.setFlatAmount(rule.getFlatAmount());
        response.setPercentageOf(rule.getPercentageOf());
        response.setMaxLimit(rule.getMaxLimit());
        response.setPriority(rule.getPriority());
        response.setIsActive(rule.getIsActive());
        return response;
    }
}
