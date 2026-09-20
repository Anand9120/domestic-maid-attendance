package com.app.maidattendance.controller;

import com.app.maidattendance.dto.request.SalarySettlementRequestDto;
import com.app.maidattendance.dto.response.SalaryCalculationResponseDto;
import com.app.maidattendance.dto.response.SalarySettlementResponseDto;
import com.app.maidattendance.security.CustomUserDetailsService;
import com.app.maidattendance.security.JwtAuthenticationFilter;
import com.app.maidattendance.security.JwtTokenProvider;
import com.app.maidattendance.service.SalarySettlementService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(SalarySettlementController.class)
@AutoConfigureMockMvc(addFilters = false)
class SalarySettlementControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private SalarySettlementService salarySettlementService;

    @MockBean
    private JwtTokenProvider jwtTokenProvider;

    @MockBean
    private CustomUserDetailsService customUserDetailsService;

    @MockBean
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Test
    @DisplayName("GET /api/v1/salary/calculate should return payroll breakdown")
    void testCalculateSalary() throws Exception {
        SalaryCalculationResponseDto calc = new SalaryCalculationResponseDto();
        calc.setMaidId(2L);
        calc.setMaidName("Sunita Devi");
        calc.setMaidUpiId("sunita@okhdfcbank");
        calc.setMonthlyBaseSalary(new BigDecimal("5000.00"));
        calc.setTotalWorkingDays(26);
        calc.setPresentDays(24);
        calc.setAbsentDays(2);
        calc.setAllowedLeaves(2);
        calc.setEffectiveDeductionDays(BigDecimal.ZERO);
        calc.setDeductionAmount(BigDecimal.ZERO);
        calc.setNetPayableSalary(new BigDecimal("5000.00"));
        calc.setIsAlreadySettled(false);

        when(salarySettlementService.calculateSalary(2L, 1L, 2026, 9)).thenReturn(calc);

        mockMvc.perform(get("/api/v1/salary/calculate")
                .param("maidId", "2")
                .param("householdId", "1")
                .param("year", "2026")
                .param("month", "9")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.maidName").value("Sunita Devi"))
                .andExpect(jsonPath("$.data.netPayableSalary").value(5000.00));

        verify(salarySettlementService, times(1)).calculateSalary(2L, 1L, 2026, 9);
    }

    @Test
    @DisplayName("POST /api/v1/salary/settle should record payout and return receipt")
    void testSettleSalary() throws Exception {
        SalarySettlementResponseDto resp = new SalarySettlementResponseDto();
        resp.setId(10L);
        resp.setMaidId(2L);
        resp.setMaidName("Sunita Devi");
        resp.setNetAmount(new BigDecimal("4800.00"));
        resp.setTransactionRef("REC-202609-2-ABC12345");
        resp.setStatus("SETTLED");
        resp.setSettledAt(LocalDateTime.now());

        when(salarySettlementService.settleSalary(any(SalarySettlementRequestDto.class))).thenReturn(resp);

        SalarySettlementRequestDto req = new SalarySettlementRequestDto();
        req.setMaidId(2L);
        req.setHouseholdId(1L);
        req.setYear(2026);
        req.setMonth(9);
        req.setPaymentMode("UPI");
        req.setTransactionRef("REC-202609-2-ABC12345");

        mockMvc.perform(post("/api/v1/salary/settle")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.transactionRef").value("REC-202609-2-ABC12345"))
                .andExpect(jsonPath("$.data.status").value("SETTLED"));

        verify(salarySettlementService, times(1)).settleSalary(any(SalarySettlementRequestDto.class));
    }
}
