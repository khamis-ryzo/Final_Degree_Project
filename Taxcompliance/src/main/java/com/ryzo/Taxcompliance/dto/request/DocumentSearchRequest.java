package com.ryzo.Taxcompliance.dto.request;


import lombok.Data;

import jakarta.validation.constraints.Size;

@Data
public class DocumentSearchRequest {

    @Size(max = 100, message = "Search term must be less than 100 characters")
    private String searchTerm;

    private String documentType;

    private String status;

    private String userFullName;

    private String tinNumber;

    private String taxReturnId;

    private String controlNumber;

    private String matchType = "CONTAINS"; // CONTAINS, STARTS_WITH, ENDS_WITH, EXACT

    private String dateFrom;

    private String dateTo;
}