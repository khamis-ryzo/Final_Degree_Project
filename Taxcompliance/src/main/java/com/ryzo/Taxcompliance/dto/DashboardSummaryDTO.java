package com.ryzo.Taxcompliance.dto;


import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummaryDTO {
    private UserSummaryDTO user;
    private TaxSummaryDTO currentYearTax;
    private TaxSummaryDTO previousYearTax;
    private Map<String, TaxReturnSummaryDTO> recentReturns;
    private NotificationDTO notifications;
    private ComplianceStatusDTO complianceStatus;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class TaxSummaryDTO {
    private String assessmentYear;
    private BigDecimal totalIncome;
    private BigDecimal totalDeductions;
    private BigDecimal taxableIncome;
    private BigDecimal taxPayable;
    private String filingStatus;
    private LocalDate dueDate;
    private boolean isFilingCompleted;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class NotificationDTO {
    private int unreadCount;
    private List<NotificationItem> recentNotifications;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class NotificationItem {
    private String id;
    private String title;
    private String message;
    private String type; // INFO, WARNING, SUCCESS, ERROR
    private LocalDateTime createdAt;
    private boolean isRead;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
class ComplianceStatusDTO {
    private boolean isITRFiled;
    private boolean isTDSMatched;
    private String lastFilingDate;
    private int pendingActions;
}
