package com.app.maidattendance.service.impl;

import com.app.maidattendance.dto.request.RegisterFcmTokenRequestDto;
import com.app.maidattendance.dto.request.VerifyOtpRequestDto;
import com.app.maidattendance.dto.response.AuthResponseDto;
import com.app.maidattendance.entity.FcmDeviceToken;
import com.app.maidattendance.entity.User;
import com.app.maidattendance.exception.ResourceNotFoundException;
import com.app.maidattendance.repository.FcmDeviceTokenRepository;
import com.app.maidattendance.repository.UserRepository;
import com.app.maidattendance.security.JwtTokenProvider;
import com.app.maidattendance.service.AuthService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final FcmDeviceTokenRepository fcmDeviceTokenRepository;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthServiceImpl(
            UserRepository userRepository,
            FcmDeviceTokenRepository fcmDeviceTokenRepository,
            JwtTokenProvider jwtTokenProvider) {
        this.userRepository = userRepository;
        this.fcmDeviceTokenRepository = fcmDeviceTokenRepository;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Override
    public AuthResponseDto verifyOtp(VerifyOtpRequestDto request) {
        // Verification: in development/testing mode, accept standard "123456" OTP
        if (!"123456".equals(request.getOtp())) {
            throw new IllegalArgumentException("Invalid or expired OTP. Please use test code 123456.");
        }

        User user = userRepository.findByPhoneNumber(request.getPhoneNumber())
                .orElseGet(() -> {
                    User newUser = new User();
                    newUser.setPhoneNumber(request.getPhoneNumber());
                    newUser.setFullName(request.getFullName() != null ? request.getFullName() : "User " + request.getPhoneNumber());
                    newUser.setRole(request.getRole() != null ? request.getRole() : User.Role.MAID);
                    newUser.setIsActive(true);
                    return userRepository.save(newUser);
                });

        String token = jwtTokenProvider.generateToken(user.getId(), user.getPhoneNumber(), user.getRole().name());

        return new AuthResponseDto(
                token,
                user.getId(),
                user.getFullName(),
                user.getPhoneNumber(),
                user.getRole()
        );
    }

    @Override
    public void registerFcmToken(RegisterFcmTokenRequestDto request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + request.getUserId()));

        FcmDeviceToken token = fcmDeviceTokenRepository.findByFcmToken(request.getFcmToken())
                .orElseGet(() -> {
                    FcmDeviceToken newToken = new FcmDeviceToken();
                    newToken.setUser(user);
                    newToken.setFcmToken(request.getFcmToken());
                    return newToken;
                });

        token.setUser(user);
        token.setDeviceType(request.getDeviceType());
        fcmDeviceTokenRepository.save(token);
    }

    @Override
    @Transactional(readOnly = true)
    public User getUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + userId));
    }

    @Override
    public User updateUserProfile(Long userId, com.app.maidattendance.dto.request.UserProfileUpdateRequestDto request) {
        User user = getUserById(userId);

        // IDOR Protection: Caller can only modify their own profile and banking info
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !("anonymousUser".equals(auth.getPrincipal()))) {
            String principalPhone = auth.getName();
            if (!user.getPhoneNumber().equals(principalPhone)) {
                throw new org.springframework.security.access.AccessDeniedException("IDOR Security Violation: You cannot modify another user's profile.");
            }
        }

        if (request.getFullName() != null && !request.getFullName().trim().isEmpty()) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getEmergencyContact() != null) {
            user.setEmergencyContact(request.getEmergencyContact().trim());
        }
        if (request.getServicesOffered() != null) {
            user.setServicesOffered(request.getServicesOffered().trim());
        }
        if (request.getUpiId() != null) {
            user.setUpiId(request.getUpiId().trim());
        }
        if (request.getBankAccount() != null) {
            user.setBankAccount(request.getBankAccount().trim());
        }
        return userRepository.save(user);
    }
}
