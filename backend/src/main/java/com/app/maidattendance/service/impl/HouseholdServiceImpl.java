package com.app.maidattendance.service.impl;

import com.app.maidattendance.dto.request.HouseholdSetupRequestDto;
import com.app.maidattendance.entity.HouseholdLocation;
import com.app.maidattendance.entity.MaidHouseholdAssignment;
import com.app.maidattendance.entity.ShiftSchedule;
import com.app.maidattendance.entity.User;
import com.app.maidattendance.exception.ResourceNotFoundException;
import com.app.maidattendance.repository.HouseholdLocationRepository;
import com.app.maidattendance.repository.MaidHouseholdAssignmentRepository;
import com.app.maidattendance.repository.ShiftScheduleRepository;
import com.app.maidattendance.repository.UserRepository;
import com.app.maidattendance.service.HouseholdService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class HouseholdServiceImpl implements HouseholdService {

    private final HouseholdLocationRepository householdLocationRepository;
    private final ShiftScheduleRepository shiftScheduleRepository;
    private final UserRepository userRepository;
    private final MaidHouseholdAssignmentRepository assignmentRepository;

    public HouseholdServiceImpl(
            HouseholdLocationRepository householdLocationRepository,
            ShiftScheduleRepository shiftScheduleRepository,
            UserRepository userRepository,
            MaidHouseholdAssignmentRepository assignmentRepository) {
        this.householdLocationRepository = householdLocationRepository;
        this.shiftScheduleRepository = shiftScheduleRepository;
        this.userRepository = userRepository;
        this.assignmentRepository = assignmentRepository;
    }

    @Override
    public HouseholdLocation setupHousehold(HouseholdSetupRequestDto request) {
        User employer = userRepository.findById(request.getEmployerId())
                .orElseThrow(() -> new ResourceNotFoundException("Employer not found with ID: " + request.getEmployerId()));

        List<HouseholdLocation> existing = householdLocationRepository.findByEmployerId(employer.getId());
        HouseholdLocation location = existing.isEmpty() ? new HouseholdLocation() : existing.get(0);
        location.setEmployer(employer);
        location.setHouseName(request.getHouseName());
        location.setAddress(request.getAddress());
        location.setLatitude(request.getLatitude());
        location.setLongitude(request.getLongitude());
        location.setGeofenceRadiusMeters(request.getGeofenceRadiusMeters() != null ? request.getGeofenceRadiusMeters() : 50);
        location.setDwellTimeMinutes(request.getDwellTimeMinutes() != null ? request.getDwellTimeMinutes() : 3);

        if (request.getInviteCode() != null && !request.getInviteCode().trim().isEmpty()) {
            location.setInviteCode(request.getInviteCode().trim().toUpperCase());
        } else if (location.getInviteCode() == null || location.getInviteCode().trim().isEmpty()) {
            location.setInviteCode(generateUniqueInviteCode(request.getHouseName()));
        }

        if (request.getMonthlySalary() != null) {
            location.setMonthlySalary(request.getMonthlySalary());
        }
        if (request.getAllowedLeaves() != null) {
            location.setAllowedLeaves(request.getAllowedLeaves());
        }

        HouseholdLocation savedLocation = householdLocationRepository.save(location);

        // Configure default or provided shift schedules
        if (request.getShifts() != null && !request.getShifts().isEmpty()) {
            for (HouseholdSetupRequestDto.ShiftDto shiftDto : request.getShifts()) {
                ShiftSchedule shift = new ShiftSchedule();
                shift.setHouseholdLocation(savedLocation);
                shift.setShiftName(shiftDto.getShiftName());
                shift.setStartTime(shiftDto.getStartTime());
                shift.setEndTime(shiftDto.getEndTime());
                shift.setGracePeriodMinutes(shiftDto.getGracePeriodMinutes() != null ? shiftDto.getGracePeriodMinutes() : 15);
                shiftScheduleRepository.save(shift);
            }
        }

        return savedLocation;
    }

    private String generateUniqueInviteCode(String houseName) {
        String prefix = "HOME";
        if (houseName != null && !houseName.trim().isEmpty()) {
            String sanitized = houseName.replaceAll("[^a-zA-Z]", "").toUpperCase();
            if (sanitized.length() >= 3) {
                prefix = sanitized.substring(0, Math.min(6, sanitized.length()));
            }
        }
        java.util.Random random = new java.util.Random();
        for (int attempt = 0; attempt < 20; attempt++) {
            int suffix = 100 + random.nextInt(900);
            String candidate = prefix + suffix;
            if (!householdLocationRepository.existsByInviteCode(candidate)) {
                return candidate;
            }
        }
        return "HOME" + (System.currentTimeMillis() % 100000);
    }

    @Override
    @Transactional(readOnly = true)
    public HouseholdLocation getHouseholdById(Long id) {
        return householdLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Household not found with ID: " + id));
    }

    @Override
    @Transactional(readOnly = true)
    public HouseholdLocation getHouseholdByInviteCode(String inviteCode) {
        return householdLocationRepository.findByInviteCode(inviteCode.trim().toUpperCase())
                .orElseThrow(() -> new ResourceNotFoundException("Household not found for Invite Code: " + inviteCode));
    }

    @Override
    @Transactional(readOnly = true)
    public List<HouseholdLocation> getHouseholdsForEmployer(Long employerId) {
        return householdLocationRepository.findByEmployerId(employerId);
    }

    @Override
    public MaidHouseholdAssignment assignMaidToHousehold(Long maidId, Long householdId) {
        User maid = userRepository.findById(maidId)
                .orElseThrow(() -> new ResourceNotFoundException("Maid not found with ID: " + maidId));

        HouseholdLocation household = householdLocationRepository.findById(householdId)
                .orElseThrow(() -> new ResourceNotFoundException("Household not found with ID: " + householdId));

        return assignmentRepository.findByMaidIdAndHouseholdLocationId(maidId, householdId)
                .orElseGet(() -> {
                    MaidHouseholdAssignment assignment = new MaidHouseholdAssignment();
                    assignment.setMaid(maid);
                    assignment.setHouseholdLocation(household);
                    assignment.setStatus(MaidHouseholdAssignment.Status.ACTIVE);
                    return assignmentRepository.save(assignment);
                });
    }

    @Override
    public MaidHouseholdAssignment joinHouseholdByCode(Long maidId, String inviteCode) {
        HouseholdLocation household = getHouseholdByInviteCode(inviteCode);
        return assignMaidToHousehold(maidId, household.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public List<MaidHouseholdAssignment> getAssignmentsForMaid(Long maidId) {
        return assignmentRepository.findByMaidIdAndStatus(maidId, MaidHouseholdAssignment.Status.ACTIVE);
    }
}
