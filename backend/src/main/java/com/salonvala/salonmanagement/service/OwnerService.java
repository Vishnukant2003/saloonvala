package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;

import java.util.List;

public interface OwnerService {

    User getOwnerById(Long ownerId);

    List<Salon> getSalonsByOwner(Long ownerId);

    Salon createSalonForOwner(Long ownerId, Salon salon);

    Salon updateSalon(Long ownerId, Salon salon);

    List<User> getCustomersOfOwner(Long ownerId);  // Optional future use

}
