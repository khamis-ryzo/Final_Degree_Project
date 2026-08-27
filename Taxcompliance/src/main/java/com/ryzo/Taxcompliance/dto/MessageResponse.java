package com.ryzo.Taxcompliance.dto;


import lombok.Builder;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageResponse {
    private String message;
    private String status;
    private Long timestamp;

    public MessageResponse(String message) {
        this.message = message;
    }

    public MessageResponse(String message, Long timestamp) {
        this.message = message;
        this.timestamp = timestamp;
    }

    public static MessageResponse success(String message) {
        return MessageResponse.builder()
                .message(message)
                .status("SUCCESS")
                .timestamp(System.currentTimeMillis())
                .build();
    }

    public static MessageResponse error(String message) {
        return MessageResponse.builder()
                .message(message)
                .status("ERROR")
                .timestamp(System.currentTimeMillis())
                .build();
    }
}
