package com.app.maidattendance.repository;

import com.app.maidattendance.entity.SalarySettlement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SalarySettlementRepository extends JpaRepository<SalarySettlement, Long> {

    @Query("SELECT s FROM SalarySettlement s WHERE s.maid.id = :maidId AND s.payoutYear = :year AND s.payoutMonth = :month")
    Optional<SalarySettlement> findByMaidIdAndYearAndMonth(@Param("maidId") Long maidId, 
                                                           @Param("year") int year, 
                                                           @Param("month") int month);

    @Query("SELECT s FROM SalarySettlement s WHERE s.maid.id = :maidId ORDER BY s.settledAt DESC")
    List<SalarySettlement> findByMaidIdOrderBySettledAtDesc(@Param("maidId") Long maidId);

    @Query("SELECT s FROM SalarySettlement s WHERE s.household.id = :householdId ORDER BY s.settledAt DESC")
    List<SalarySettlement> findByHouseholdIdOrderBySettledAtDesc(@Param("householdId") Long householdId);

    Optional<SalarySettlement> findByTransactionRef(String transactionRef);
}
