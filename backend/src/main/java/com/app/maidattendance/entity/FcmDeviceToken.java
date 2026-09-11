package com.app.maidattendance.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "fcm_device_tokens")
public class FcmDeviceToken {

    public enum DeviceType {
        ANDROID,
        IOS,
        WEB
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "fcm_token", nullable = false, unique = true)
    private String fcmToken;

    @Enumerated(EnumType.STRING)
    @Column(name = "device_type", length = 20)
    private DeviceType deviceType = DeviceType.ANDROID;

    public FcmDeviceToken() {}

    public FcmDeviceToken(Long id, User user, String fcmToken, DeviceType deviceType) {
        this.id = id;
        this.user = user;
        this.fcmToken = fcmToken;
        this.deviceType = deviceType != null ? deviceType : DeviceType.ANDROID;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getFcmToken() { return fcmToken; }
    public void setFcmToken(String fcmToken) { this.fcmToken = fcmToken; }

    public DeviceType getDeviceType() { return deviceType; }
    public void setDeviceType(DeviceType deviceType) { this.deviceType = deviceType; }
}
