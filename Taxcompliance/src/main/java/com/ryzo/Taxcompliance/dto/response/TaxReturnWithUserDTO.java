package com.ryzo.Taxcompliance.dto.response;


import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
public class TaxReturnWithUserDTO {

    // Tax Return Fields
    private Long id;
    private String filingId;
    private String assessmentYear;
    private String filingType;
    private BigDecimal totalIncome;
    private BigDecimal deductions;
    private BigDecimal taxableIncome;
    private BigDecimal taxPayable;
    private BigDecimal interest;
    private BigDecimal penalty;
    private BigDecimal totalLiability;
    private BigDecimal taxPaid;
    private BigDecimal refundAmount;
    private String status;
    private LocalDate submissionDate;
    private String acknowledgmentNumber;

    // User Fields
    private String fullName;
    private String mobileNumber;
    private String tinNumber;
    private String email;

    // Constructor for JPA Query
    public TaxReturnWithUserDTO(Long id, String filingId, String assessmentYear, String filingType,
                                BigDecimal totalIncome, BigDecimal deductions, BigDecimal taxableIncome,
                                BigDecimal taxPayable, BigDecimal interest, BigDecimal penalty,
                                BigDecimal totalLiability, BigDecimal taxPaid, BigDecimal refundAmount,
                                String status, LocalDate submissionDate, String acknowledgmentNumber,
                                String fullName, String mobileNumber, String tinNumber, String email) {
        this.id = id;
        this.filingId = filingId;
        this.assessmentYear = assessmentYear;
        this.filingType = filingType;
        this.totalIncome = totalIncome;
        this.deductions = deductions;
        this.taxableIncome = taxableIncome;
        this.taxPayable = taxPayable;
        this.interest = interest;
        this.penalty = penalty;
        this.totalLiability = totalLiability;
        this.taxPaid = taxPaid;
        this.refundAmount = refundAmount;
        this.status = status;
        this.submissionDate = submissionDate;
        this.acknowledgmentNumber = acknowledgmentNumber;
        this.fullName = fullName;
        this.mobileNumber = mobileNumber;
        this.tinNumber = tinNumber;
        this.email = email;
    }
}