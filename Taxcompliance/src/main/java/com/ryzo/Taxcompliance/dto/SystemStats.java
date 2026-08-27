package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SystemStats {
    private long totalApiCallsToday;
    private double averageResponseTime;
    private int activeSessions;
    private long databaseSize;
    private String lastBackupTime;
}
