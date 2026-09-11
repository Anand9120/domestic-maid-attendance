package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.RegisterFcmTokenRequestDto;
import com.app.maidattendance.dto.request.VerifyOtpRequestDto;
import com.app.maidattendance.dto.response.AuthResponseDto;

public interface AuthService {
    AuthResponseDto verifyOtp(VerifyOtpRequestDto request);
    void registerFcmToken(RegisterFcmTokenRequestDto request);
}
