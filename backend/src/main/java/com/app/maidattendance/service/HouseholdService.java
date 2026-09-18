package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.HouseholdSetupRequestDto;
import com.app.maidattendance.entity.HouseholdLocation;
import com.app.maidattendance.entity.MaidHouseholdAssignment;

import java.util.List;

public interface HouseholdService {
    HouseholdLocation setupHousehold(HouseholdSetupRequestDto request);
    HouseholdLocation getHouseholdById(Long id);
    HouseholdLocation getHouseholdByInviteCode(String inviteCode);
    List<HouseholdLocation> getHouseholdsForEmployer(Long employerId);
    MaidHouseholdAssignment assignMaidToHousehold(Long maidId, Long householdId);
    MaidHouseholdAssignment joinHouseholdByCode(Long maidId, String inviteCode);
    List<MaidHouseholdAssignment> getAssignmentsForMaid(Long maidId);
}
