package com.ryzo.Taxcompliance.service;

import com.ryzo.Taxcompliance.dto.RegisterRequest;
import com.ryzo.Taxcompliance.dto.request.AssignSubscriptionRequest;
import com.ryzo.Taxcompliance.dto.request.TaxReturnRequest;
import com.ryzo.Taxcompliance.dto.response.TaxReturnResponse;
import com.ryzo.Taxcompliance.entity.TaxReturn;
import com.ryzo.Taxcompliance.entity.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
class TaxReturnServiceAuthorizationTest {

    @Autowired
    private TaxReturnService taxReturnService;

    @Autowired
    private UserService userService;

    @Autowired
    private SubscriptionService subscriptionService;

    private User register(String username) {
        RegisterRequest request = new RegisterRequest();
        request.setUsername(username);
        request.setEmail(username + "@example.com");
        request.setPassword("password123");
        request.setTinNumber("T" + System.nanoTime());
        request.setFullName(username.toUpperCase());
        return userService.registerUser(request);
    }

    private User registerPremium(String username) {
        User user = register(username);
        AssignSubscriptionRequest subscriptionRequest = new AssignSubscriptionRequest();
        subscriptionRequest.setPlan("PREMIUM");
        subscriptionRequest.setBillingCycle("MONTHLY");
        subscriptionService.assignPlan(user.getId(), subscriptionRequest, "admin");
        return user;
    }

    @Test
    void userCanSelfSubscribeWithoutAdminApproval() {
        User user = register("tr_self_subscribe_" + System.nanoTime());

        AssignSubscriptionRequest request = new AssignSubscriptionRequest();
        request.setPlan("PREMIUM");
        request.setBillingCycle("MONTHLY");
        request.setAutoRenew(false);

        var subscription = subscriptionService.subscribeSelf(user.getUsername(), request);

        assertThat(subscription.getPlan()).isEqualTo("PREMIUM");
        assertThat(subscription.getStatus()).isEqualTo("ACTIVE");
        assertThat(subscriptionService.hasActivePremium(user.getId())).isTrue();
    }

    @Test
    void freeUserCanCreateDraftReturnWithoutPremium() {
        User user = register("tr_free_draft_" + System.nanoTime());

        TaxReturn created = taxReturnService.createTaxReturn(user, "2025-26");

        assertThat(created.getUserId()).isEqualTo(user.getId());
        assertThat(created.getStatus()).isEqualTo("DRAFT");
        assertThat(created.getAssessmentYear()).isEqualTo("2025-26");
    }

    @Test
    void userCannotReadAnotherUsersReturn() {
        User owner = registerPremium("tr_owner_" + System.nanoTime());
        User other = registerPremium("tr_other_" + System.nanoTime());
        TaxReturn taxReturn = taxReturnService.createTaxReturn(owner, "2025-26");

        assertThatThrownBy(() -> taxReturnService.getTaxReturnById(other.getUsername(), taxReturn.getId()))
                .isInstanceOf(AccessDeniedException.class);
    }

    @Test
    void userCannotUpdateAnotherUsersReturn() {
        User owner = registerPremium("tr_upd_a_" + System.nanoTime());
        User other = registerPremium("tr_upd_b_" + System.nanoTime());
        TaxReturn taxReturn = taxReturnService.createTaxReturn(owner, "2025-26");

        TaxReturnRequest request = new TaxReturnRequest();
        request.setTotalIncome(new BigDecimal("5000000"));
        request.setDeductions(BigDecimal.ZERO);

        assertThatThrownBy(() -> taxReturnService.updateTaxReturn(other.getUsername(), taxReturn.getId(), request))
                .isInstanceOf(AccessDeniedException.class);
    }

    @Test
    void ownerCanUpdateAndSeeFullData() {
        User owner = registerPremium("tr_own2_" + System.nanoTime());
        TaxReturn taxReturn = taxReturnService.createTaxReturn(owner, "2025-26");

        TaxReturnRequest request = new TaxReturnRequest();
        request.setTotalIncome(new BigDecimal("5000000"));
        request.setDeductions(BigDecimal.ZERO);

        TaxReturnResponse updated = taxReturnService.updateTaxReturn(owner.getUsername(), taxReturn.getId(), request);
        assertThat(updated.getTotalIncome()).isEqualByComparingTo(new BigDecimal("5000000"));
        assertThat(updated.getTaxableIncome()).isEqualByComparingTo(new BigDecimal("5000000"));
        assertThat(updated.getTaxPayable()).isNotNull();
    }

    @Test
    void updateClampsNegativeTaxableIncomeToZero() {
        User owner = registerPremium("tr_own3_" + System.nanoTime());
        TaxReturn taxReturn = taxReturnService.createTaxReturn(owner, "2025-26");

        TaxReturnRequest request = new TaxReturnRequest();
        request.setTotalIncome(new BigDecimal("1000000"));
        request.setDeductions(new BigDecimal("2000000"));

        TaxReturnResponse updated = taxReturnService.updateTaxReturn(owner.getUsername(), taxReturn.getId(), request);
        assertThat(updated.getTaxableIncome()).isEqualByComparingTo(BigDecimal.ZERO);
        assertThat(updated.getTaxPayable()).isEqualByComparingTo(BigDecimal.ZERO);
    }
}
