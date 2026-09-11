package com.app.maidattendance.repository;

import com.app.maidattendance.entity.MaidHouseholdAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MaidHouseholdAssignmentRepository extends JpaRepository<MaidHouseholdAssignment, Long> {
    List<MaidHouseholdAssignment> findByMaidIdAndStatus(Long maidId, MaidHouseholdAssignment.Status status);
    List<MaidHouseholdAssignment> findByHouseholdLocationIdAndStatus(Long householdId, MaidHouseholdAssignment.Status status);
    Optional<MaidHouseholdAssignment> findByMaidIdAndHouseholdLocationId(Long maidId, Long householdId);
}
