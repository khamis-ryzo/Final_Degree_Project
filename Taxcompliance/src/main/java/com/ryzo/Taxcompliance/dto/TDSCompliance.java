package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TDSCompliance {
    private long totalEmployers;
    private long tdsFiled;
    private long tdsDefaults;
    private BigDecimal totalTDSDeducted;
    private BigDecimal totalTDSDeposited;
    private double tdsComplianceRate;
}
