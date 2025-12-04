package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.ServiceEntity;
import com.salonvala.salonmanagement.entity.Salon;

import java.util.List;

public interface ServiceService {
    ServiceEntity addService(ServiceEntity service);
    ServiceEntity updateService(ServiceEntity service);
    void deleteService(Long serviceId);
    List<ServiceEntity> listServicesBySalon(Salon salon);
}
