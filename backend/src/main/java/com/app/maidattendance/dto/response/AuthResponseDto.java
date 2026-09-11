package com.app.maidattendance.dto.response;

import com.app.maidattendance.entity.User;

public class AuthResponseDto {

    private String token;
    private String tokenType = "Bearer";
    private Long userId;
    private String fullName;
    private String phoneNumber;
    private User.Role role;

    public AuthResponseDto() {}

    public AuthResponseDto(String token, Long userId, String fullName, String phoneNumber, User.Role role) {
        this.token = token;
        this.tokenType = "Bearer";
        this.userId = userId;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.role = role;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getTokenType() { return tokenType; }
    public void setTokenType(String tokenType) { this.tokenType = tokenType; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public User.Role getRole() { return role; }
    public void setRole(User.Role role) { this.role = role; }
}
