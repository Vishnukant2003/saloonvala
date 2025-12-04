package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.QueueState;
import com.salonvala.salonmanagement.entity.Salon;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface QueueStateRepository extends JpaRepository<QueueState, Long> {

    Optional<QueueState> findBySalon(Salon salon);
}
