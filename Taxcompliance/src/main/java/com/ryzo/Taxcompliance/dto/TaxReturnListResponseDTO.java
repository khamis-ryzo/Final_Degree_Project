package com.ryzo.Taxcompliance.dto;


import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TaxReturnListResponseDTO {
    private List<TaxReturnSummaryDTO> returns;
    private int totalCount;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
    private boolean hasNext;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class TaxReturnSummaryDTO {
    private Long id;
    private String filingId;
    private String assessmentYear;
    private BigDecimal totalIncome;
    private BigDecimal totalLiability;
    private String status;
    private LocalDate submissionDate;
    private String acknowledgmentNumber;
}
