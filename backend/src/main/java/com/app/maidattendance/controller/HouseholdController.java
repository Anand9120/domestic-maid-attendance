package com.app.maidattendance.controller;

import com.app.maidattendance.dto.request.HouseholdSetupRequestDto;
import com.app.maidattendance.dto.response.ApiResponse;
import com.app.maidattendance.entity.HouseholdLocation;
import com.app.maidattendance.entity.MaidHouseholdAssignment;
import com.app.maidattendance.service.HouseholdService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/household")
@Tag(name = "Household", description = "Endpoints for household geofence setup, shift management, and maid assignments")
public class HouseholdController {

    private final HouseholdService householdService;

    public HouseholdController(HouseholdService householdService) {
        this.householdService = householdService;
    }

    @PostMapping("/setup")
    @Operation(summary = "Setup Household Geofence & Shifts", 
               description = "Registers employer house location, radius (50m), dwell threshold (3m), and shifts")
    public ResponseEntity<ApiResponse<HouseholdLocation>> setupHousehold(@Valid @RequestBody HouseholdSetupRequestDto request) {
        HouseholdLocation location = householdService.setupHousehold(request);
        return ResponseEntity.ok(ApiResponse.ok("Household location and shifts configured successfully", location));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get Household Details", description = "Fetches household geofence parameters by ID")
    public ResponseEntity<ApiResponse<HouseholdLocation>> getHouseholdById(@PathVariable Long id) {
        HouseholdLocation location = householdService.getHouseholdById(id);
        return ResponseEntity.ok(ApiResponse.ok("Household details retrieved", location));
    }

    @GetMapping("/employer/{employerId}")
    @Operation(summary = "Get Employer Households", description = "Fetches all households registered by employer")
    public ResponseEntity<ApiResponse<List<HouseholdLocation>>> getHouseholdsForEmployer(@PathVariable Long employerId) {
        List<HouseholdLocation> list = householdService.getHouseholdsForEmployer(employerId);
        return ResponseEntity.ok(ApiResponse.ok("Employer households retrieved", list));
    }

    @PostMapping("/{householdId}/assign/{maidId}")
    @Operation(summary = "Assign Maid to Household", description = "Links maid to household for geofence tracking")
    public ResponseEntity<ApiResponse<MaidHouseholdAssignment>> assignMaid(
            @PathVariable Long householdId, 
            @PathVariable Long maidId) {
        MaidHouseholdAssignment assignment = householdService.assignMaidToHousehold(maidId, householdId);
        return ResponseEntity.ok(ApiResponse.ok("Maid successfully assigned to household", assignment));
    }

    @GetMapping("/code/{inviteCode}")
    @Operation(summary = "Get Household Details by Invite Code", description = "Fetches household details using 6-character invite code")
    public ResponseEntity<ApiResponse<HouseholdLocation>> getHouseholdByInviteCode(@PathVariable String inviteCode) {
        HouseholdLocation location = householdService.getHouseholdByInviteCode(inviteCode);
        return ResponseEntity.ok(ApiResponse.ok("Household found", location));
    }

    @PostMapping("/join-by-code")
    @Operation(summary = "Join Household via Invite Code", description = "Allows maid to link to household using invite code")
    public ResponseEntity<ApiResponse<MaidHouseholdAssignment>> joinByCode(
            @Valid @RequestBody com.app.maidattendance.dto.request.JoinHouseholdRequestDto request) {
        MaidHouseholdAssignment assignment = householdService.joinHouseholdByCode(request.getMaidId(), request.getInviteCode());
        return ResponseEntity.ok(ApiResponse.ok("Household linked successfully", assignment));
    }

    @GetMapping("/maid/{maidId}/assignments")
    @Operation(summary = "Get Active Household Targets for Maid", description = "Returns active geofences for maid client")
    public ResponseEntity<ApiResponse<List<MaidHouseholdAssignment>>> getAssignmentsForMaid(@PathVariable Long maidId) {
        List<MaidHouseholdAssignment> assignments = householdService.getAssignmentsForMaid(maidId);
        return ResponseEntity.ok(ApiResponse.ok("Active assignments retrieved", assignments));
    }
}
