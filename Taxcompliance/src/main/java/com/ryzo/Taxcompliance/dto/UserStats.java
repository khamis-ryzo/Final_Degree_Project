package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStats {
    private long totalUsers;
    private long activeUsers;
    private long inactiveUsers;
    private long newUsersThisMonth;
    private long newUsersToday;
    private long adminUsers;
    private long regularUsers;
}
