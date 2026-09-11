package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.HouseholdSetupRequestDto;
import com.app.maidattendance.entity.HouseholdLocation;
import com.app.maidattendance.entity.MaidHouseholdAssignment;

import java.util.List;

public interface HouseholdService {
    HouseholdLocation setupHousehold(HouseholdSetupRequestDto request);
    HouseholdLocation getHouseholdById(Long id);
    List<HouseholdLocation> getHouseholdsForEmployer(Long employerId);
    MaidHouseholdAssignment assignMaidToHousehold(Long maidId, Long householdId);
    List<MaidHouseholdAssignment> getAssignmentsForMaid(Long maidId);
}
