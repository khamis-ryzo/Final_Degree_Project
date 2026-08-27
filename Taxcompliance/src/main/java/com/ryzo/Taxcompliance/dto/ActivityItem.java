package com.ryzo.Taxcompliance.dto;

import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ActivityItem {
    private Long id;
    private String action;
    private String description;
    private String performedBy;
    private String targetType;
    private Long targetId;
    private LocalDateTime timestamp;
    private String ipAddress;
}
