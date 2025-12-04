package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.SalonGallery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SalonGalleryRepository extends JpaRepository<SalonGallery, Long> {
    List<SalonGallery> findBySalon(Salon salon);
    void deleteBySalonId(Long salonId);
}

