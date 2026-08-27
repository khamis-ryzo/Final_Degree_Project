package com.ryzo.Taxcompliance.dto.request;

import lombok.Data;

@Data
public class UpdateProfileRequest {
    private String fullName;
    private String mobileNumber;
    private String address;
}
