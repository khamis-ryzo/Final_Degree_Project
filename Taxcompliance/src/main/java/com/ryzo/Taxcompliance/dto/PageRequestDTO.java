package com.ryzo.Taxcompliance.dto;


import jakarta.validation.constraints.Min;
import lombok.Data;

@Data
public class PageRequestDTO {
    @Min(value = 0, message = "Page number must be greater than or equal to 0")
    private int page = 0;

    @Min(value = 1, message = "Page size must be greater than 0")
    private int size = 10;

    private String sortBy = "createdAt";

    private String sortDir = "DESC"; // ASC or DESC
}
