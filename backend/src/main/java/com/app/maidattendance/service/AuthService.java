package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.RegisterFcmTokenRequestDto;
import com.app.maidattendance.dto.request.VerifyOtpRequestDto;
import com.app.maidattendance.dto.response.AuthResponseDto;

import com.app.maidattendance.dto.request.UserProfileUpdateRequestDto;
import com.app.maidattendance.entity.User;

public interface AuthService {
    AuthResponseDto verifyOtp(VerifyOtpRequestDto request);
    void registerFcmToken(RegisterFcmTokenRequestDto request);
    User getUserById(Long userId);
    User updateUserProfile(Long userId, UserProfileUpdateRequestDto request);
}
