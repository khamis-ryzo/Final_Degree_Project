package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.*;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.entity.TaxReturn;
import com.ryzo.Taxcompliance.entity.TaxRule;
import com.ryzo.Taxcompliance.exception.DuplicateResourceException;
import com.ryzo.Taxcompliance.exception.ResourceNotFoundException;
import com.ryzo.Taxcompliance.repository.UserRepository;
import com.ryzo.Taxcompliance.repository.TaxReturnRepository;
import com.ryzo.Taxcompliance.repository.TaxRuleRepository;
import com.ryzo.Taxcompliance.repository.InMemorySubscriptionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminService {

    private final UserRepository userRepository;
    private final TaxReturnRepository taxReturnRepository;
    private final TaxRuleRepository taxRuleRepository;
    private final InMemorySubscriptionRepository subscriptionRepository;
    private final SubscriptionService subscriptionService;

    public AdminDashboardResponse getDashboardStatistics() {
        return AdminDashboardResponse.builder()
                .userStats(getUserStats())
                .taxReturnStats(getTaxReturnStats())
                .subscriptionStats(getSubscriptionStats())
                .complianceStats(getComplianceStats())
                .systemStats(getSystemStats())
                .build();
    }

    public Page<UserResponseDTO> getAllUsers(int page, int size, String role, Boolean isActive) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());

        List<User> users;
        if (role != null && !role.isBlank() && isActive != null) {
            users = userRepository.findByRoleAndIsActive(role, isActive);
        } else if (role != null && !role.isBlank()) {
            users = userRepository.findByRole(role);
        } else if (isActive != null) {
            users = userRepository.findByIsActive(isActive);
        } else {
            users = userRepository.findAll();
        }
        users.sort(byCreatedAtDesc(u -> u.getCreatedAt()));
        return paginate(users, pageable, this::mapToUserResponse);
    }

    public UserResponseDTO getUserById(Long userId) {
        if (userId == null) {
            throw new IllegalArgumentException("User id is required");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return mapToUserResponse(user);
    }

    @Transactional
    public MessageResponse toggleUserStatus(Long userId, boolean active) {
        if (userId == null) {
            throw new IllegalArgumentException("User id is required");
        }
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        user.setIsActive(active);
        userRepository.save(user);

        String message = active ? "User account activated successfully" : "User account deactivated successfully";
        return MessageResponse.success(message);
    }

    @Transactional
    public MessageResponse deleteUser(Long userId) {
        if (userId == null || !userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("User not found");
        }
        userRepository.deleteById(userId);
        return MessageResponse.success("User deleted successfully");
    }

    public Page<TaxReturnResponseDTO> getAllTaxReturns(int page, int size, String status, String assessmentYear) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());

        List<TaxReturn> returns;
        if (status != null && !status.isBlank() && assessmentYear != null && !assessmentYear.isBlank()) {
            returns = taxReturnRepository.findByStatusAndAssessmentYear(status, assessmentYear);
        } else if (status != null && !status.isBlank()) {
            returns = taxReturnRepository.findByStatus(status);
        } else if (assessmentYear != null && !assessmentYear.isBlank()) {
            returns = taxReturnRepository.findByAssessmentYear(assessmentYear);
        } else {
            returns = taxReturnRepository.findAll();
        }
        returns.sort(byCreatedAtDesc(r -> r.getCreatedAt()));
        return paginate(returns, pageable, this::mapToTaxReturnResponse);
    }

    public TaxReturnResponseDTO getTaxReturnById(Long returnId) {
        if (returnId == null) {
            throw new IllegalArgumentException("Tax return id is required");
        }
        TaxReturn taxReturn = taxReturnRepository.findById(returnId)
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found"));
        return mapToTaxReturnResponse(taxReturn);
    }

    @Transactional
    public MessageResponse updateTaxReturnStatus(Long returnId, String status, String remarks) {
        if (returnId == null) {
            throw new IllegalArgumentException("Tax return id is required");
        }
        TaxReturn taxReturn = taxReturnRepository.findById(returnId)
                .orElseThrow(() -> new ResourceNotFoundException("Tax return not found"));
        taxReturn.setStatus(status);
        taxReturnRepository.save(taxReturn);
        return MessageResponse.success("Tax return status updated to: " + status);
    }

    public Page<TaxRuleResponseDTO> getAllTaxRules(int page, int size, String ruleType) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("priority").ascending());

        if (ruleType == null || ruleType.isBlank()) {
            return taxRuleRepository.findAll(pageable).map(this::mapToTaxRuleResponse);
        }

        List<TaxRuleResponseDTO> filtered = taxRuleRepository.findByRuleType(ruleType).stream()
                .map(this::mapToTaxRuleResponse)
                .collect(java.util.stream.Collectors.toList());
        int start = Math.min((int) pageable.getOffset(), filtered.size());
        int end = Math.min(start + pageable.getPageSize(), filtered.size());
        return new PageImpl<>(new ArrayList<>(filtered.subList(start, end)), pageable, filtered.size());
    }

    @Transactional
    public TaxRuleResponseDTO createTaxRule(TaxRuleRequestDTO request) {
        if (request == null) {
            throw new IllegalArgumentException("Tax rule request is required");
        }
        if (taxRuleRepository.findByRuleCode(request.getRuleCode()).isPresent()) {
            throw new DuplicateResourceException("Rule with code " + request.getRuleCode() + " already exists");
        }
        TaxRule rule = new TaxRule();
        applyRuleRequest(rule, request);
        if (request.getIsActive() != null) {
            rule.setIsActive(request.getIsActive());
        }
        TaxRule savedRule = Objects.requireNonNull(
                taxRuleRepository.save(rule),
                "Saved tax rule should not be null");
        return mapToTaxRuleResponse(savedRule);
    }

    @Transactional
    public TaxRuleResponseDTO updateTaxRule(Long ruleId, TaxRuleRequestDTO request) {
        if (ruleId == null) {
            throw new IllegalArgumentException("Tax rule id is required");
        }
        TaxRule rule = taxRuleRepository.findById(ruleId)
                .orElseThrow(() -> new ResourceNotFoundException("Tax rule not found"));
        applyRuleRequest(rule, request);
        TaxRule savedRule = Objects.requireNonNull(taxRuleRepository.save(rule));
        return mapToTaxRuleResponse(savedRule);
    }

    @Transactional
    public MessageResponse deleteTaxRule(Long ruleId) {
        if (ruleId == null || !taxRuleRepository.existsById(ruleId)) {
            throw new ResourceNotFoundException("Tax rule not found");
        }
        taxRuleRepository.deleteById(ruleId);
        return MessageResponse.success("Tax rule deleted successfully");
    }

    public RecentActivityResponse getRecentActivity(int limit) {
        List<ActivityItem> items = new ArrayList<>();

        for (User user : userRepository.findTop10ByOrderByCreatedAtDesc()) {
            items.add(ActivityItem.builder()
                    .id(user.getId())
                    .action("USER_REGISTERED")
                    .description("New user registered: " + user.getFullName() + " (" + user.getUsername() + ")")
                    .performedBy("SYSTEM")
                    .targetType("USER")
                    .targetId(user.getId())
                    .timestamp(user.getCreatedAt() != null ? user.getCreatedAt() : LocalDateTime.MIN)
                    .build());
        }

        PageRequest recentReturns = PageRequest.of(0, Math.max(limit, 10), Sort.by("createdAt").descending());
        for (TaxReturn taxReturn : taxReturnRepository.findAll(recentReturns).getContent()) {
            items.add(ActivityItem.builder()
                    .id(taxReturn.getId())
                    .action("RETURN_" + (taxReturn.getStatus() != null ? taxReturn.getStatus() : "UPDATED"))
                    .description("Tax return " + taxReturn.getFilingId() + " for " + taxReturn.getAssessmentYear()
                            + " is " + taxReturn.getStatus())
                    .performedBy("USER:" + taxReturn.getUserId())
                    .targetType("TAX_RETURN")
                    .targetId(taxReturn.getId())
                    .timestamp(taxReturn.getUpdatedAt() != null ? taxReturn.getUpdatedAt() : LocalDateTime.MIN)
                    .build());
        }

        items.sort(Comparator.comparing(a -> a.getTimestamp(), Comparator.reverseOrder()));
        List<ActivityItem> top = items.subList(0, Math.min(limit, items.size()));
        return RecentActivityResponse.builder()
                .activities(top)
                .totalCount(top.size())
                .build();
    }

    public ComplianceSummaryResponse getComplianceSummary() {
        long totalReturns = taxReturnRepository.count();
        long filed = taxReturnRepository.countByStatus("SUBMITTED")
                + taxReturnRepository.countByStatus("ASSESSED")
                + taxReturnRepository.countByStatus("COMPLETED");
        long totalUsers = userRepository.count();
        long totalSubscriptions = subscriptionRepository.count();
        long activeSubscriptions = subscriptionRepository.countByStatus("ACTIVE");
        long premiumSubscriptions = subscriptionRepository.countByPlanAndStatus("PREMIUM", "ACTIVE");

        double filingRate = round1(totalReturns > 0 ? filed * 100.0 / totalReturns : 0.0);
        double subscriptionRate = round1(totalSubscriptions > 0
                ? activeSubscriptions * 100.0 / totalSubscriptions
                : 0.0);

        String year = currentAssessmentYear();
        OverallCompliance overall = OverallCompliance.builder()
                .filingComplianceRate(filingRate)
                .subscriptionComplianceRate(subscriptionRate)
                .assessmentComplianceRate(0.0)
                .totalTaxpayers(totalUsers)
                .compliantTaxpayers(filed)
                .nonCompliantTaxpayers(Math.max(0, totalUsers - filed))
                .build();

        YearlyCompliance yearly = YearlyCompliance.builder()
                .year(year)
                .totalFilings(totalReturns)
                .onTimeFilings(filed)
                .lateFilings(0)
                .nonFilings(Math.max(0, totalUsers - filed))
                .complianceRate(filingRate)
                .totalSubscriptions(totalSubscriptions)
                .premiumSubscriptions(premiumSubscriptions)
                .build();

        return ComplianceSummaryResponse.builder()
                .overall(overall)
                .yearlyBreakdown(Map.of(year, yearly))
                .tdsCompliance(TDSCompliance.builder().tdsComplianceRate(0.0).build())
                .assessmentSummary(AssessmentSummary.builder().build())
                .build();
    }

    // Helper methods
    private UserResponseDTO mapToUserResponse(User user) {
        return UserResponseDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .tinNumber(user.getTinNumber())
                .fullName(user.getFullName())
                .mobileNumber(user.getMobileNumber())
                .dateOfBirth(user.getDateOfBirth())
                .address(user.getAddress())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    private TaxReturnResponseDTO mapToTaxReturnResponse(TaxReturn taxReturn) {
        User user = userRepository.findById(Objects.requireNonNull(taxReturn.getUserId())).orElse(null);
        return TaxReturnResponseDTO.builder()
                .id(taxReturn.getId())
                .filingId(taxReturn.getFilingId())
                .userId(taxReturn.getUserId())
                .assessmentYear(taxReturn.getAssessmentYear())
                .filingType(taxReturn.getFilingType())
                .totalIncome(taxReturn.getTotalIncome())
                .deductions(taxReturn.getDeductions())
                .taxableIncome(taxReturn.getTaxableIncome())
                .taxPayable(taxReturn.getTaxPayable())
                .interest(taxReturn.getInterest())
                .penalty(taxReturn.getPenalty())
                .totalLiability(taxReturn.getTotalLiability())
                .status(taxReturn.getStatus())
                .submissionDate(taxReturn.getSubmissionDate())
                .acknowledgmentNumber(taxReturn.getAcknowledgmentNumber())
                .createdAt(taxReturn.getCreatedAt())
                .updatedAt(taxReturn.getUpdatedAt())
                .user(user != null ? mapToUserSummary(user) : null)
                .build();
    }

    private UserSummaryDTO mapToUserSummary(User user) {
        return UserSummaryDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .tinNumber(user.getTinNumber())
                .build();
    }

    private TaxRuleResponseDTO mapToTaxRuleResponse(TaxRule rule) {
        return TaxRuleResponseDTO.builder()
                .id(rule.getId())
                .ruleCode(rule.getRuleCode())
                .ruleName(rule.getRuleName())
                .ruleType(rule.getRuleType())
                .applicableFromYear(rule.getApplicableFromYear())
                .applicableToYear(rule.getApplicableToYear())
                .minIncome(rule.getMinIncome())
                .maxIncome(rule.getMaxIncome())
                .taxRate(rule.getTaxRate())
                .flatAmount(rule.getFlatAmount())
                .percentageOf(rule.getPercentageOf())
                .maxLimit(rule.getMaxLimit())
                .conditions(rule.getConditions())
                .priority(rule.getPriority())
                .isActive(rule.getIsActive())
                .createdAt(rule.getCreatedAt())
                .updatedAt(rule.getUpdatedAt())
                .build();
    }

    private void applyRuleRequest(TaxRule rule, TaxRuleRequestDTO request) {
        rule.setRuleCode(request.getRuleCode());
        rule.setRuleName(request.getRuleName());
        rule.setRuleType(request.getRuleType());
        rule.setApplicableFromYear(request.getApplicableFromYear());
        rule.setApplicableToYear(request.getApplicableToYear());
        rule.setMinIncome(request.getMinIncome());
        rule.setMaxIncome(request.getMaxIncome());
        rule.setTaxRate(request.getTaxRate());
        rule.setFlatAmount(request.getFlatAmount());
        rule.setPercentageOf(request.getPercentageOf());
        rule.setMaxLimit(request.getMaxLimit());
        rule.setConditions(request.getConditions());
        rule.setPriority(request.getPriority() != null ? request.getPriority() : 0);
        rule.setIsActive(request.getIsActive() != null ? request.getIsActive() : true);
    }

    // Statistics helper methods
    private UserStats getUserStats() {
        long total = userRepository.count();
        long active = userRepository.countByIsActiveTrue();
        long admins = userRepository.countByRole("ROLE_ADMIN");
        LocalDateTime monthStart = LocalDate.now().withDayOfMonth(1).atStartOfDay();
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        return UserStats.builder()
                .totalUsers(total)
                .activeUsers(active)
                .inactiveUsers(total - active)
                .newUsersThisMonth(userRepository.countByCreatedAtAfter(monthStart))
                .newUsersToday(userRepository.countByCreatedAtAfter(todayStart))
                .adminUsers(admins)
                .regularUsers(total - admins)
                .build();
    }

    private TaxReturnStats getTaxReturnStats() {
        LocalDateTime monthStart = LocalDate.now().withDayOfMonth(1).atStartOfDay();
        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        return TaxReturnStats.builder()
                .totalReturns(taxReturnRepository.count())
                .draftReturns(taxReturnRepository.countByStatus("DRAFT"))
                .submittedReturns(taxReturnRepository.countByStatus("SUBMITTED"))
                .processedReturns(taxReturnRepository.countByStatus("PROCESSING"))
                .completedReturns(taxReturnRepository.countByStatus("COMPLETED"))
                .rejectedReturns(taxReturnRepository.countByStatus("REJECTED"))
                .returnsThisMonth(taxReturnRepository.countByCreatedAtAfter(monthStart))
                .returnsToday(taxReturnRepository.countByCreatedAtAfter(todayStart))
                .build();
    }

    private SubscriptionStats getSubscriptionStats() {
        return subscriptionService.getSubscriptionStats();
    }

    private ComplianceStats getComplianceStats() {
        long total = taxReturnRepository.count();
        long filed = taxReturnRepository.countByStatus("SUBMITTED")
                + taxReturnRepository.countByStatus("ASSESSED")
                + taxReturnRepository.countByStatus("COMPLETED");
        return ComplianceStats.builder()
                .overallComplianceRate(round1(total > 0 ? filed * 100.0 / total : 0.0))
                .onTimeFilings(filed)
                .lateFilings(0)
                .pendingAssessments(taxReturnRepository.countByStatus("PROCESSING"))
                .completedAssessments(taxReturnRepository.countByStatus("COMPLETED"))
                .build();
    }

    private SystemStats getSystemStats() {
        return SystemStats.builder()
                .totalApiCallsToday(0)
                .averageResponseTime(0)
                .activeSessions(0)
                .databaseSize(0)
                .lastBackupTime(null)
                .build();
    }

    private <T, R> Page<R> paginate(List<T> items, Pageable pageable, java.util.function.Function<T, R> mapper) {
        int start = Math.min((int) pageable.getOffset(), items.size());
        int end = Math.min(start + pageable.getPageSize(), items.size());
        List<R> mapped = new ArrayList<>();
        for (int i = start; i < end; i++) {
            mapped.add(mapper.apply(items.get(i)));
        }
        return new PageImpl<>(mapped, pageable, items.size());
    }

    private <T> Comparator<T> byCreatedAtDesc(java.util.function.Function<T, LocalDateTime> timestampFn) {
        return (a, b) -> {
            LocalDateTime at = timestampFn.apply(a);
            LocalDateTime bt = timestampFn.apply(b);
            if (at == null) {
                at = LocalDateTime.MIN;
            }
            if (bt == null) {
                bt = LocalDateTime.MIN;
            }
            return bt.compareTo(at);
        };
    }

    private double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    private String currentAssessmentYear() {
        int current = LocalDate.now().getYear();
        return current + "/" + (current + 1);
    }
}
