package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.Staff;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StaffRepository extends JpaRepository<Staff, Long> {

    List<Staff> findBySalon(Salon salon);
}

