package com.app.maidattendance.controller;

import com.app.maidattendance.entity.NotificationLog;
import com.app.maidattendance.security.CustomUserDetailsService;
import com.app.maidattendance.security.JwtAuthenticationFilter;
import com.app.maidattendance.security.JwtTokenProvider;
import com.app.maidattendance.service.NotificationService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(NotificationController.class)
@AutoConfigureMockMvc(addFilters = false)
class NotificationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NotificationService notificationService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private CustomUserDetailsService customUserDetailsService;

    @MockBean
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Test
    @DisplayName("GET /api/v1/notifications/user/{userId} should return user notification list")
    void testGetUserNotifications() throws Exception {
        NotificationLog notif1 = new NotificationLog(2L, 1L, "Arrival Verified: Flat 402", "Checked in at 07:35 AM", "CHECK_IN");
        notif1.setId(101L);

        when(notificationService.getUserNotifications(2L)).thenReturn(List.of(notif1));

        mockMvc.perform(get("/api/v1/notifications/user/2")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data[0].title").value("Arrival Verified: Flat 402"))
                .andExpect(jsonPath("$.data[0].type").value("CHECK_IN"));

        verify(notificationService, times(1)).getUserNotifications(2L);
    }

    @Test
    @DisplayName("GET /api/v1/notifications/user/{userId}/unread-count should return unread count")
    void testGetUnreadCount() throws Exception {
        when(notificationService.getUnreadCount(2L)).thenReturn(3L);

        mockMvc.perform(get("/api/v1/notifications/user/2/unread-count")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.unreadCount").value(3));

        verify(notificationService, times(1)).getUnreadCount(2L);
    }

    @Test
    @DisplayName("PUT /api/v1/notifications/{id}/read should mark notification read")
    void testMarkAsRead() throws Exception {
        doNothing().when(notificationService).markAsRead(101L);

        mockMvc.perform(put("/api/v1/notifications/101/read")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(notificationService, times(1)).markAsRead(101L);
    }

    @Test
    @DisplayName("PUT /api/v1/notifications/user/{userId}/read-all should mark all as read")
    void testMarkAllAsRead() throws Exception {
        doNothing().when(notificationService).markAllAsRead(2L);

        mockMvc.perform(put("/api/v1/notifications/user/2/read-all")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        verify(notificationService, times(1)).markAllAsRead(2L);
    }
}
