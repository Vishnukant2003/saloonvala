package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;

import java.util.List;

public interface SalonService {
    Salon createSalon(Salon salon);
    Salon updateSalon(Salon salon);
    Salon getSalonById(Long id);
    List<Salon> listAllSalons();
    List<Salon> listSalonsByCity(String city);
    List<Salon> listSalonsByOwner(User owner);
    Salon approveSalon(Long salonId);
    Salon rejectSalon(Long salonId, String reason);
}
