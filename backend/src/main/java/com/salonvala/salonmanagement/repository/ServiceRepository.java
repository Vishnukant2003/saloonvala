package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.ServiceEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServiceRepository extends JpaRepository<ServiceEntity, Long> {

    List<ServiceEntity> findBySalon(Salon salon);
}
