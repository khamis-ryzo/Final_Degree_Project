package com.ryzo.Taxcompliance.repository;

import com.ryzo.Taxcompliance.entity.TaxRule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TaxRuleRepository extends JpaRepository<TaxRule, Long> {

    Optional<TaxRule> findByRuleCode(String ruleCode);

    List<TaxRule> findByRuleType(String ruleType);

    List<TaxRule> findByRuleTypeAndIsActiveTrue(String ruleType);

    List<TaxRule> findByIsActiveTrueOrderByPriorityAsc();

    @Query("SELECT t FROM TaxRule t WHERE t.ruleType = 'TAX_SLAB' AND t.isActive = true " +
            "AND (:year BETWEEN t.applicableFromYear AND t.applicableToYear) " +
            "ORDER BY t.minIncome ASC")
    List<TaxRule> findActiveTaxSlabsForYear(@Param("year") Integer year);

    @Query("SELECT t FROM TaxRule t WHERE t.ruleType = 'DEDUCTION' AND t.isActive = true " +
            "AND (:year BETWEEN t.applicableFromYear AND t.applicableToYear)")
    List<TaxRule> findActiveDeductionsForYear(@Param("year") Integer year);

    @Query("SELECT t FROM TaxRule t WHERE t.ruleCode IN :ruleCodes AND t.isActive = true")
    List<TaxRule> findByRuleCodes(@Param("ruleCodes") List<String> ruleCodes);
}
