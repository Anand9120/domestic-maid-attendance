package com.app.maidattendance.controller;

import com.app.maidattendance.dto.response.ApiResponse;
import com.app.maidattendance.entity.NotificationLog;
import com.app.maidattendance.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notifications")
@Tag(name = "In-App Notifications & Activity Timeline API", description = "Endpoints for fetching and managing user notifications and real-time activity timeline")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get User Notifications", description = "Fetches all notifications and activity timeline events for a user in reverse chronological order")
    public ResponseEntity<ApiResponse<List<NotificationLog>>> getUserNotifications(@PathVariable Long userId) {
        List<NotificationLog> notifications = notificationService.getUserNotifications(userId);
        return ResponseEntity.ok(ApiResponse.ok("Notifications retrieved successfully", notifications));
    }

    @GetMapping("/user/{userId}/unread-count")
    @Operation(summary = "Get Unread Count", description = "Returns total count of unread notifications for a user")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUnreadCount(@PathVariable Long userId) {
        Long unreadCount = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(ApiResponse.ok("Unread count retrieved", Map.of("unreadCount", unreadCount)));
    }

    @PutMapping("/{id}/read")
    @Operation(summary = "Mark Notification as Read", description = "Marks a specific notification as read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok(ApiResponse.ok("Notification marked as read", null));
    }

    @PutMapping("/user/{userId}/read-all")
    @Operation(summary = "Mark All Notifications as Read", description = "Marks all notifications for a user as read")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(@PathVariable Long userId) {
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(ApiResponse.ok("All notifications marked as read", null));
    }
}
