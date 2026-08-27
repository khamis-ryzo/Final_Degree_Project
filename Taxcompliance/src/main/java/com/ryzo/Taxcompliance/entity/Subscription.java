package com.ryzo.Taxcompliance.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Subscription {

    private Long id;

    private Long userId;

    private String plan; // FREE, PREMIUM

    private String billingCycle; // NONE, MONTHLY, YEARLY

    private LocalDate startDate;

    private LocalDate expiryDate;

    private String status; // ACTIVE, EXPIRED, CANCELLED

    private Boolean autoRenew = false;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

}
