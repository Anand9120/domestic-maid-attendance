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

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get User Profile", description = "Fetches user details by user ID")
    public ResponseEntity<ApiResponse<com.app.maidattendance.entity.User>> getUserProfile(@PathVariable Long userId) {
        com.app.maidattendance.entity.User user = authService.getUserById(userId);
        return ResponseEntity.ok(ApiResponse.ok("User profile retrieved successfully", user));
    }

    @PutMapping("/user/{userId}/profile")
    @Operation(summary = "Update User Profile", description = "Updates user profile (services, payout, emergency contact)")
    public ResponseEntity<ApiResponse<com.app.maidattendance.entity.User>> updateUserProfile(
            @PathVariable Long userId,
            @RequestBody com.app.maidattendance.dto.request.UserProfileUpdateRequestDto request) {
        com.app.maidattendance.entity.User updated = authService.updateUserProfile(userId, request);
        return ResponseEntity.ok(ApiResponse.ok("User profile updated successfully", updated));
    }
}
