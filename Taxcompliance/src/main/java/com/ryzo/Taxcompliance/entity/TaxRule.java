package com.ryzo.Taxcompliance.entity;

import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "tax_rule")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaxRule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "rule_code", nullable = false, unique = true, length = 20)
    private String ruleCode; // e.g., "SLAB_INDV_2024", "DEDUCTION_80C"

    @Column(name = "rule_name", nullable = false)
    private String ruleName;

    @Column(name = "rule_type", nullable = false)
    private String ruleType; // TAX_SLAB, DEDUCTION, CESS, SURCHARGE, INTEREST

    @Column(name = "applicable_from_year")
    private Integer applicableFromYear;

    @Column(name = "applicable_to_year")
    private Integer applicableToYear;

    @Column(name = "min_income", precision = 15, scale = 2)
    private BigDecimal minIncome;

    @Column(name = "max_income", precision = 15, scale = 2)
    private BigDecimal maxIncome;

    @Column(name = "tax_rate", precision = 5, scale = 2)
    private BigDecimal taxRate; // e.g., 5.00 for 5%

    @Column(name = "flat_amount", precision = 15, scale = 2)
    private BigDecimal flatAmount; // For fixed deductions

    @Column(name = "percentage_of", length = 50)
    private String percentageOf; // e.g., "TAX", "INCOME"

    @Column(name = "max_limit", precision = 15, scale = 2)
    private BigDecimal maxLimit; // Maximum deduction limit

    @Column(name = "conditions", columnDefinition = "TEXT")
    private String conditions; // JSON string for complex conditions

    @Column(name = "priority")
    private Integer priority = 0; // Lower number = higher priority

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}