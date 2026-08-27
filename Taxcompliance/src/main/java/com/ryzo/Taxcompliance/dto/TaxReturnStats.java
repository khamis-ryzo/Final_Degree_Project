package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaxReturnStats {
    private long totalReturns;
    private long draftReturns;
    private long submittedReturns;
    private long processedReturns;
    private long completedReturns;
    private long rejectedReturns;
    private long returnsThisMonth;
    private long returnsToday;
}
