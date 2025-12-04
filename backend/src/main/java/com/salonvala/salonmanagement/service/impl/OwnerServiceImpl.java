package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.Role;
import com.salonvala.salonmanagement.repository.SalonRepository;
import com.salonvala.salonmanagement.repository.UserRepository;
import com.salonvala.salonmanagement.service.OwnerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OwnerServiceImpl implements OwnerService {

    private final UserRepository userRepository;
    private final SalonRepository salonRepository;

    @Autowired
    public OwnerServiceImpl(UserRepository userRepository,
                            SalonRepository salonRepository) {
        this.userRepository = userRepository;
        this.salonRepository = salonRepository;
    }

    @Override
    public User getOwnerById(Long ownerId) {
        User owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new IllegalArgumentException("Owner not found"));

        if (owner.getRole() != Role.OWNER) {
            throw new IllegalArgumentException("This user is not a salon owner");
        }

        return owner;
    }

    @Override
    public List<Salon> getSalonsByOwner(Long ownerId) {
        User owner = getOwnerById(ownerId);
        return salonRepository.findByOwner(owner);
    }

    @Override
    public Salon createSalonForOwner(Long ownerId, Salon salon) {
        User owner = getOwnerById(ownerId);
        salon.setOwner(owner);
        return salonRepository.save(salon);
    }

    @Override
    public Salon updateSalon(Long ownerId, Salon salon) {
        User owner = getOwnerById(ownerId);

        Salon existing = salonRepository.findById(salon.getId())
                .orElseThrow(() -> new IllegalArgumentException("Salon not found"));

        if (!existing.getOwner().getId().equals(owner.getId())) {
            throw new IllegalArgumentException("This salon does not belong to the owner");
        }

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
        // Update category field
        if (salon.getCategory() != null) {
            existing.setCategory(salon.getCategory());
        }

        return salonRepository.save(existing);
    }

    @Override
    public List<User> getCustomersOfOwner(Long ownerId) {
        // You can implement this later when needed
        return List.of();
    }
}
