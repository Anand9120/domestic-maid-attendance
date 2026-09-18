package com.app.maidattendance.repository;

import com.app.maidattendance.entity.HouseholdLocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HouseholdLocationRepository extends JpaRepository<HouseholdLocation, Long> {
    List<HouseholdLocation> findByEmployerId(Long employerId);
    Optional<HouseholdLocation> findByInviteCode(String inviteCode);
    boolean existsByInviteCode(String inviteCode);
}
