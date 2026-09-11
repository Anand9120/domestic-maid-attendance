package com.app.maidattendance.dto.request;

import com.app.maidattendance.entity.FcmDeviceToken;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class RegisterFcmTokenRequestDto {

    @NotNull(message = "User ID is required")
    private Long userId;

    @NotBlank(message = "FCM Token is required")
    private String fcmToken;

    private FcmDeviceToken.DeviceType deviceType = FcmDeviceToken.DeviceType.ANDROID;

    public RegisterFcmTokenRequestDto() {}

    public RegisterFcmTokenRequestDto(Long userId, String fcmToken, FcmDeviceToken.DeviceType deviceType) {
        this.userId = userId;
        this.fcmToken = fcmToken;
        this.deviceType = deviceType != null ? deviceType : FcmDeviceToken.DeviceType.ANDROID;
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getFcmToken() { return fcmToken; }
    public void setFcmToken(String fcmToken) { this.fcmToken = fcmToken; }

    public FcmDeviceToken.DeviceType getDeviceType() { return deviceType; }
    public void setDeviceType(FcmDeviceToken.DeviceType deviceType) { this.deviceType = deviceType; }
}
