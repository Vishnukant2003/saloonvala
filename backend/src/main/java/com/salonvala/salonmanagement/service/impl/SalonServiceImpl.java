package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.SalonApprovalStatus;
import com.salonvala.salonmanagement.repository.SalonRepository;
import com.salonvala.salonmanagement.service.SalonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SalonServiceImpl implements SalonService {

    private final SalonRepository salonRepository;

    @Autowired
    public SalonServiceImpl(SalonRepository salonRepository) {
        this.salonRepository = salonRepository;
    }

    @Override
    @Transactional
    public Salon createSalon(Salon salon) {
        salon.setApprovalStatus(SalonApprovalStatus.PENDING);
        return salonRepository.save(salon);
    }

    @Override
    @Transactional
    public Salon updateSalon(Salon salon) {
        Salon existing = getSalonById(salon.getId());
        existing.setSalonName(salon.getSalonName());
        existing.setAddress(salon.getAddress());
        existing.setCity(salon.getCity());
        existing.setState(salon.getState());
        existing.setPincode(salon.getPincode());
        existing.setContactNumber(salon.getContactNumber());
        existing.setImageUrl(salon.getImageUrl());
        existing.setOpenTime(salon.getOpenTime());
        existing.setCloseTime(salon.getCloseTime());
        if (salon.getIsLive() != null) {
            existing.setIsLive(salon.getIsLive());
        }
        if (salon.getLatitude() != null) {
            existing.setLatitude(salon.getLatitude());
        }
        if (salon.getLongitude() != null) {
            existing.setLongitude(salon.getLongitude());
        }
        if (salon.getCategory() != null) {
            existing.setCategory(salon.getCategory());
        }
        return salonRepository.save(existing);
    }

    @Override
    public Salon getSalonById(Long id) {
        return salonRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Salon not found"));
    }

    @Override
    public List<Salon> listSalonsByCity(String city) {
        return salonRepository.findByCity(city);
    }

    @Override
    public List<Salon> listAllSalons() {
        return salonRepository.findAll();
    }

    @Override
    public List<Salon> listSalonsByOwner(User owner) {
        return salonRepository.findByOwner(owner);
    }

    @Override
    @Transactional
    public Salon approveSalon(Long salonId) {
        Salon salon = getSalonById(salonId);
        salon.setApprovalStatus(SalonApprovalStatus.APPROVED);
        return salonRepository.save(salon);
    }

    @Override
    @Transactional
    public Salon rejectSalon(Long salonId, String reason) {
        Salon salon = getSalonById(salonId);
        salon.setApprovalStatus(SalonApprovalStatus.REJECTED);
        // optionally persist rejection reason in another field or admin log
        return salonRepository.save(salon);
    }
}
