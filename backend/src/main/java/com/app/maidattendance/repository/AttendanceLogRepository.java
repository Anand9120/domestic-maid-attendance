package com.app.maidattendance.repository;

import com.app.maidattendance.entity.AttendanceLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceLogRepository extends JpaRepository<AttendanceLog, Long> {

    List<AttendanceLog> findByMaidIdAndAttendanceDate(Long maidId, LocalDate date);

    Optional<AttendanceLog> findByMaidIdAndHouseholdLocationIdAndAttendanceDateAndShiftScheduleId(
            Long maidId, Long householdId, LocalDate date, Long shiftId);

    Optional<AttendanceLog> findFirstByMaidIdAndHouseholdLocationIdAndAttendanceDateOrderByCheckInTimeDesc(
            Long maidId, Long householdId, LocalDate date);

    @Query("SELECT a FROM AttendanceLog a WHERE a.maid.id = :maidId " +
           "AND a.attendanceDate BETWEEN :startDate AND :endDate ORDER BY a.attendanceDate ASC, a.checkInTime ASC")
    List<AttendanceLog> findMonthlyLogsForMaid(
            @Param("maidId") Long maidId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT a FROM AttendanceLog a WHERE a.householdLocation.id = :householdId " +
           "AND a.attendanceDate BETWEEN :startDate AND :endDate ORDER BY a.attendanceDate ASC, a.checkInTime ASC")
    List<AttendanceLog> findMonthlyLogsForHousehold(
            @Param("householdId") Long householdId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT a FROM AttendanceLog a WHERE a.householdLocation.id = :householdId AND a.maid.id = :maidId " +
           "AND a.attendanceDate BETWEEN :startDate AND :endDate ORDER BY a.attendanceDate ASC, a.checkInTime ASC")
    List<AttendanceLog> findMonthlyLogsForHouseholdAndMaid(
            @Param("householdId") Long householdId,
            @Param("maidId") Long maidId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);

    @Query("SELECT COUNT(a) FROM AttendanceLog a WHERE a.maid.id = :maidId " +
           "AND a.attendanceDate BETWEEN :startDate AND :endDate AND a.status = :status")
    long countByMaidIdAndDateRangeAndStatus(
            @Param("maidId") Long maidId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("status") AttendanceLog.AttendanceStatus status);
}
