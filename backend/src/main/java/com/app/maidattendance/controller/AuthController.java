package com.app.maidattendance.controller;

import com.app.maidattendance.dto.request.RegisterFcmTokenRequestDto;
import com.app.maidattendance.dto.request.VerifyOtpRequestDto;
import com.app.maidattendance.dto.response.ApiResponse;
import com.app.maidattendance.dto.response.AuthResponseDto;
import com.app.maidattendance.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentication", description = "Endpoints for Phone OTP authentication and FCM token registration")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/verify-otp")
    @Operation(summary = "Verify Phone OTP", description = "Verifies phone OTP and returns JWT bearer token")
    public ResponseEntity<ApiResponse<AuthResponseDto>> verifyOtp(@Valid @RequestBody VerifyOtpRequestDto request) {
        AuthResponseDto authResponse = authService.verifyOtp(request);
        return ResponseEntity.ok(ApiResponse.ok("OTP verified successfully", authResponse));
    }

    @PostMapping("/register-fcm-token")
    @Operation(summary = "Register FCM Device Token", description = "Stores user device FCM push token")
    public ResponseEntity<ApiResponse<Void>> registerFcmToken(@Valid @RequestBody RegisterFcmTokenRequestDto request) {
        authService.registerFcmToken(request);
        return ResponseEntity.ok(ApiResponse.ok("Device token registered successfully", null));
    }
}
