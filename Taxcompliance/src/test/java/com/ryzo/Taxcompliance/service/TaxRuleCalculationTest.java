package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.entity.TaxRule;
import com.ryzo.Taxcompliance.repository.TaxRuleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
class TaxRuleCalculationTest {

    @Autowired
    private TaxRuleService taxRuleService;

    @Autowired
    private TaxRuleRepository taxRuleRepository;

    @BeforeEach
    void seedSlabs() {
        taxRuleRepository.deleteAll();
        taxRuleRepository.save(Objects.requireNonNull(slab("SLAB_1", new BigDecimal("0"), new BigDecimal("3240000"), new BigDecimal("0"))));
        taxRuleRepository.save(Objects.requireNonNull(slab("SLAB_2", new BigDecimal("3240000"), new BigDecimal("4320000"), new BigDecimal("8"))));
        taxRuleRepository.save(Objects.requireNonNull(slab("SLAB_3", new BigDecimal("4320000"), new BigDecimal("5400000"), new BigDecimal("20"))));
        taxRuleRepository.save(Objects.requireNonNull(slab("SLAB_4", new BigDecimal("5400000"), null, new BigDecimal("30"))));
    }

    private TaxRule slab(String code, BigDecimal min, BigDecimal max, BigDecimal rate) {
        return rule(code, "TAX_SLAB", min, max, rate);
    }

    private TaxRule rule(String code, String type, BigDecimal min, BigDecimal max, BigDecimal rate) {
        TaxRule rule = new TaxRule();
        rule.setRuleCode(code);
        rule.setRuleName(code);
        rule.setRuleType(type);
        rule.setApplicableFromYear(2000);
        rule.setApplicableToYear(2100);
        rule.setMinIncome(min);
        rule.setMaxIncome(max);
        rule.setTaxRate(rate);
        rule.setIsActive(true);
        rule.setPriority(0);
        return rule;
    }

    @Test
    void calculatesProgressivePayeAcrossSlabs() {
        BigDecimal tax = taxRuleService.calculateTax("PAYE", new BigDecimal("5000000"), 2026);
        assertThat(tax).isEqualByComparingTo(new BigDecimal("222400.00"));
    }

    @Test
    void returnsZeroForIncomeWithinZeroRateSlab() {
        BigDecimal tax = taxRuleService.calculateTax("PAYE", new BigDecimal("1000000"), 2026);
        assertThat(tax).isEqualByComparingTo(BigDecimal.ZERO);
    }

    @Test
    void returnsZeroWhenNoSlabsApplicable() {
        BigDecimal tax = taxRuleService.calculateTax("PAYE", new BigDecimal("7000000"), 1950);
        assertThat(tax).isEqualByComparingTo(BigDecimal.ZERO);
    }

    @Test
    void appliesFlatRateForLevyType() {
        taxRuleRepository.save(Objects.requireNonNull(rule("LEVY_1", "LEVY", null, null, new BigDecimal("3"))));
        BigDecimal levy = taxRuleService.calculateTax("LEVY", new BigDecimal("1000000"), 2026);
        assertThat(levy).isEqualByComparingTo(new BigDecimal("30000.00"));
    }
}
