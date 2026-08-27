package com.ryzo.Taxcompliance.dto;


import jakarta.validation.constraints.*;
import lombok.Data;
import java.util.Date;

@Data
public class RegisterRequest {

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 40, message = "Password must be between 6 and 40 characters")
    private String password;

    @NotBlank(message = "TIN number is required")
    private String tinNumber;

    @NotBlank(message = "Full name is required")
    private String fullName;

    @Pattern(regexp = "[0-9]{10}", message = "Mobile number must be 10 digits")
    private String mobileNumber;

    @Past(message = "Date of birth must be in the past")
    private Date dateOfBirth;

    private String address;
}
