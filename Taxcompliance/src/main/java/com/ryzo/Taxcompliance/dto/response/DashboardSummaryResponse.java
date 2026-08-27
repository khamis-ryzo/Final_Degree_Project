package com.ryzo.Taxcompliance.dto.response;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
public class DashboardSummaryResponse {
    private Long userId;
    private String username;
    private String fullName;
    private String message;
    private String currentAssessmentYear;
    private BigDecimal totalIncome;
    private BigDecimal deductions;
    private BigDecimal taxableIncome;
    private BigDecimal taxPayable;
    private BigDecimal totalLiability;
    private String filingStatus;
    private LocalDate dueDate;
    private long totalReturns;
    private long pendingActions;
    private long unreadNotifications;
    private List<NotificationResponse> recentNotifications;
}
