package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.SalonApprovalStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SalonRepository extends JpaRepository<Salon, Long> {

    List<Salon> findByApprovalStatus(SalonApprovalStatus status);

    List<Salon> findByCity(String city);

    List<Salon> findByOwner(User owner);

    long countByApprovalStatus(SalonApprovalStatus status);
}
