package com.app.maidattendance.controller;

import com.app.maidattendance.dto.request.CheckInRequestDto;
import com.app.maidattendance.dto.response.AttendanceLogResponseDto;
import com.app.maidattendance.entity.AttendanceLog;
import com.app.maidattendance.security.CustomUserDetailsService;
import com.app.maidattendance.security.JwtAuthenticationFilter;
import com.app.maidattendance.security.JwtTokenProvider;
import com.app.maidattendance.service.AttendanceService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(AttendanceController.class)
@AutoConfigureMockMvc(addFilters = false) // Disable security filters in WebMvc slice test
class AttendanceControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AttendanceService attendanceService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private CustomUserDetailsService customUserDetailsService;

    @MockBean
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
    }

    @Test
    @DisplayName("POST /api/v1/attendance/check-in returns 200 with saved record")
    void testCheckInEndpoint() throws Exception {
        CheckInRequestDto request = new CheckInRequestDto(
                2L, 1L, 1L,
                new BigDecimal("28.6315500"), new BigDecimal("77.2167200"),
                LocalDateTime.now(), false, 180
        );

        AttendanceLogResponseDto responseDto = new AttendanceLogResponseDto();
        responseDto.setId(555L);
        responseDto.setMaidId(2L);
        responseDto.setMaidName("Sunita Devi");
        responseDto.setHouseholdId(1L);
        responseDto.setHouseName("Sharma Residence");
        responseDto.setAttendanceDate(LocalDate.now());
        responseDto.setCheckInTime(LocalTime.of(7, 32));
        responseDto.setStatus(AttendanceLog.AttendanceStatus.PRESENT);
        responseDto.setEntryType(AttendanceLog.EntryType.AUTOMATED_GEOFENCE);

        when(attendanceService.recordCheckIn(any(CheckInRequestDto.class))).thenReturn(responseDto);

        mockMvc.perform(post("/api/v1/attendance/check-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(555))
                .andExpect(jsonPath("$.data.maidName").value("Sunita Devi"))
                .andExpect(jsonPath("$.data.status").value("PRESENT"));
    }
}
