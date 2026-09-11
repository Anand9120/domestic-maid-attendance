package com.app.maidattendance.repository;

import com.app.maidattendance.entity.FcmDeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FcmDeviceTokenRepository extends JpaRepository<FcmDeviceToken, Long> {
    List<FcmDeviceToken> findByUserId(Long userId);
    Optional<FcmDeviceToken> findByFcmToken(String fcmToken);
    void deleteByFcmToken(String fcmToken);
}
