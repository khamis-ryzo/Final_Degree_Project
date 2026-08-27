package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.SubscriptionStats;
import com.ryzo.Taxcompliance.dto.request.AssignSubscriptionRequest;
import com.ryzo.Taxcompliance.dto.response.SubscriptionResponse;
import com.ryzo.Taxcompliance.entity.Subscription;
import com.ryzo.Taxcompliance.entity.User;
import com.ryzo.Taxcompliance.exception.ResourceNotFoundException;
import com.ryzo.Taxcompliance.repository.InMemorySubscriptionRepository;
import com.ryzo.Taxcompliance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SubscriptionService {

    private static final Set<String> PLANS = Set.of("FREE", "PREMIUM");
    private static final Set<String> CYCLES = Set.of("MONTHLY", "YEARLY");
    private static final BigDecimal PREMIUM_MONTHLY_FEE = new BigDecimal("5000");
    private static final BigDecimal PREMIUM_YEARLY_FEE = new BigDecimal("50000");

    private final InMemorySubscriptionRepository subscriptionRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public SubscriptionResponse getMySubscription(String username) {
        User user = getUserByUsername(username);
        Subscription subscription = getOrCreateForUser(user);
        return mapToResponse(subscription, user, "Subscription for " + user.getFullName());
    }

    public SubscriptionResponse getSubscriptionForUser(Long userId, String adminUsername) {
        User user = findUser(userId);
        Subscription subscription = getOrCreateForUser(user);
        return mapToResponse(subscription, user, "Subscription for " + user.getFullName());
    }

    public List<SubscriptionResponse> getAllSubscriptions(String adminUsername) {
        // Return empty by default when using in-memory stub
        return List.of();
    }

    @Transactional
    public SubscriptionResponse assignPlan(Long userId, AssignSubscriptionRequest request, String adminUsername) {
        SubscriptionResponse response = applyPlan(userId, request, false);
        notificationService.create(userId, "Subscription Updated",
                "Your subscription plan is now " + response.getPlan() + ".", "SUCCESS");
        return response;
    }

    @Transactional
    public SubscriptionResponse subscribeSelf(String username, AssignSubscriptionRequest request) {
        User user = getUserByUsername(username);
        SubscriptionResponse response = applyPlan(user.getId(), request, true);
        notificationService.create(user.getId(), "Subscription Updated",
                "Your subscription plan is now " + response.getPlan() + ".", "SUCCESS");
        return response;
    }

    @Transactional
    public SubscriptionResponse cancelSubscription(Long userId, String adminUsername) {
        SubscriptionResponse response = cancelForUser(userId);
        notificationService.create(userId, "Subscription Cancelled",
                "Your subscription has been cancelled by the administrator.", "WARNING");
        return response;
    }

    @Transactional
    public SubscriptionResponse cancelSelf(String username) {
        User user = getUserByUsername(username);
        SubscriptionResponse response = cancelForUser(user.getId());
        notificationService.create(user.getId(), "Subscription Cancelled",
                "Your subscription has been cancelled.", "WARNING");
        return response;
    }

    private SubscriptionResponse applyPlan(Long userId, AssignSubscriptionRequest request, boolean selfServe) {
        User user = findUser(userId);

        String plan = request.getPlan() == null ? "PREMIUM" : request.getPlan().trim().toUpperCase();
        if (!PLANS.contains(plan)) {
            throw new IllegalArgumentException("Invalid plan. Must be FREE or PREMIUM");
        }

        Subscription subscription = new Subscription();
        subscription.setUserId(userId);
        subscription.setPlan(plan);
        subscription.setStatus("ACTIVE");
        subscription.setStartDate(LocalDate.now());
        subscription.setAutoRenew(request.getAutoRenew() != null && request.getAutoRenew());

        if ("PREMIUM".equals(plan)) {
            String cycle = request.getBillingCycle() == null ? "MONTHLY" : request.getBillingCycle().trim().toUpperCase();
            if (!CYCLES.contains(cycle)) {
                throw new IllegalArgumentException("Invalid billing cycle. Must be MONTHLY or YEARLY");
            }
            subscription.setBillingCycle(cycle);
            LocalDate expiry = request.getExpiryDate();
            if (expiry == null) {
                expiry = "MONTHLY".equals(cycle) ? LocalDate.now().plusMonths(1) : LocalDate.now().plusYears(1);
            }
            subscription.setExpiryDate(expiry);
        } else {
            subscription.setBillingCycle("NONE");
            subscription.setExpiryDate(null);
        }

        expireActiveSubscriptions(userId);

        Subscription saved = subscriptionRepository.save(subscription);
        return mapToResponse(saved, user,
                selfServe ? "Subscription activated successfully" : "Subscription assigned successfully");
    }

    private SubscriptionResponse cancelForUser(Long userId) {
        User user = findUser(userId);
        Subscription subscription = subscriptionRepository
                .findFirstByUserIdOrderByIdDesc(userId)
                .orElseGet(() -> {
                    Subscription freeSubscription = createFreeSubscription(userId);
                    return subscriptionRepository.save(freeSubscription);
                });
        if (!"ACTIVE".equals(effectiveStatus(subscription))) {
            throw new IllegalStateException("No active subscription to cancel for user " + user.getUsername());
        }
        subscription.setStatus("CANCELLED");
        Subscription saved = subscriptionRepository.save(subscription);
        return mapToResponse(saved, user, "Subscription cancelled successfully");
    }

    public boolean hasActivePremium(Long userId) {
        Subscription subscription = subscriptionRepository.findFirstByUserIdOrderByIdDesc(userId).orElse(null);
        return subscription != null
                && "PREMIUM".equals(subscription.getPlan())
                && "ACTIVE".equals(effectiveStatus(subscription));
    }

    public SubscriptionStats getSubscriptionStats() {
        List<Subscription> all = subscriptionRepository.findAll();
        long active = all.stream().filter(s -> "ACTIVE".equals(effectiveStatus(s))).count();
        long premium = all.stream()
                .filter(s -> "PREMIUM".equals(s.getPlan()) && "ACTIVE".equals(effectiveStatus(s)))
                .count();
        long free = all.stream()
                .filter(s -> "FREE".equals(s.getPlan()) && "ACTIVE".equals(effectiveStatus(s)))
                .count();
        long expired = all.stream().filter(s -> "EXPIRED".equals(effectiveStatus(s))).count();
        LocalDate monthStart = LocalDate.now().withDayOfMonth(1);
        LocalDate monthEnd = LocalDate.now().withDayOfMonth(LocalDate.now().lengthOfMonth());
        long expiringThisMonth = all.stream()
                .filter(s -> s.getExpiryDate() != null
                        && !s.getExpiryDate().isBefore(monthStart)
                        && !s.getExpiryDate().isAfter(monthEnd))
                .count();

        BigDecimal monthlyRevenue = all.stream()
                .filter(s -> "PREMIUM".equals(s.getPlan()) && "ACTIVE".equals(effectiveStatus(s)))
                .map(s -> "YEARLY".equals(s.getBillingCycle()) ? PREMIUM_YEARLY_FEE : PREMIUM_MONTHLY_FEE)
                .reduce(BigDecimal.ZERO, (a, b) -> a.add(b));

        return SubscriptionStats.builder()
                .totalSubscriptions(all.size())
                .activeSubscriptions(active)
                .premiumSubscriptions(premium)
                .freeSubscriptions(free)
                .expiredSubscriptions(expired)
                .expiringThisMonth(expiringThisMonth)
                .estimatedMonthlyRevenue(monthlyRevenue)
                .build();
    }

    private Subscription getOrCreateForUser(User user) {
        return subscriptionRepository
                .findFirstByUserIdOrderByIdDesc(user.getId())
                .orElseGet(() -> subscriptionRepository.save(createFreeSubscription(user.getId())));
    }

    private Subscription createFreeSubscription(Long userId) {
        Subscription subscription = new Subscription();
        subscription.setUserId(userId);
        subscription.setPlan("FREE");
        subscription.setBillingCycle("NONE");
        subscription.setStatus("ACTIVE");
        subscription.setStartDate(LocalDate.now());
        subscription.setExpiryDate(null);
        subscription.setAutoRenew(false);
        return subscription;
    }

    private void expireActiveSubscriptions(Long userId) {
        subscriptionRepository.findByUserId(userId).forEach(existing -> {
            if ("ACTIVE".equals(existing.getStatus())) {
                existing.setStatus("CANCELLED");
                subscriptionRepository.save(existing);
            }
        });
    }

    private String effectiveStatus(Subscription subscription) {
        String status = subscription.getStatus();
        if ("ACTIVE".equals(status)
                && subscription.getExpiryDate() != null
                && subscription.getExpiryDate().isBefore(LocalDate.now())) {
            return "EXPIRED";
        }
        return status;
    }

    private User findUser(Long userId) {
        return userRepository.findById(Objects.requireNonNull(userId))
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
    }

    private SubscriptionResponse mapToResponse(Subscription subscription, User user, String message) {
        String effective = effectiveStatus(subscription);
        long daysRemaining = -1L;
        if (subscription.getExpiryDate() != null && "ACTIVE".equals(effective)) {
            daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), subscription.getExpiryDate());
        }
        return SubscriptionResponse.builder()
                .id(subscription.getId())
                .userId(subscription.getUserId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .plan(subscription.getPlan())
                .billingCycle(subscription.getBillingCycle())
                .status(effective)
                .startDate(subscription.getStartDate())
                .expiryDate(subscription.getExpiryDate())
                .autoRenew(subscription.getAutoRenew())
                .daysRemaining(daysRemaining)
                .createdAt(subscription.getCreatedAt())
                .message(message)
                .build();
    }
}
