package com.ryzo.Taxcompliance.dto.request;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AssignSubscriptionRequest {
    private String plan;          // FREE, PREMIUM
    private String billingCycle;  // MONTHLY, YEARLY (for PREMIUM)
    private LocalDate expiryDate; // optional; defaults from billing cycle
    private Boolean autoRenew;
}
