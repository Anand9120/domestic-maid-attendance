package com.app.maidattendance.dto.request;

import com.app.maidattendance.entity.User;
import jakarta.validation.constraints.NotBlank;

public class VerifyOtpRequestDto {

    @NotBlank(message = "Phone number is required")
    private String phoneNumber;

    @NotBlank(message = "OTP is required")
    private String otp;

    private User.Role role = User.Role.MAID;

    private String fullName;

    public VerifyOtpRequestDto() {}

    public VerifyOtpRequestDto(String phoneNumber, String otp, User.Role role, String fullName) {
        this.phoneNumber = phoneNumber;
        this.otp = otp;
        this.role = role != null ? role : User.Role.MAID;
        this.fullName = fullName;
    }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public User.Role getRole() { return role; }
    public void setRole(User.Role role) { this.role = role; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
}
