package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.ServiceEntity;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.repository.ServiceRepository;
import com.salonvala.salonmanagement.service.ServiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ServiceServiceImpl implements ServiceService {

    private final ServiceRepository serviceRepository;

    @Autowired
    public ServiceServiceImpl(ServiceRepository serviceRepository) {
        this.serviceRepository = serviceRepository;
    }

    @Override
    @Transactional
    public ServiceEntity addService(ServiceEntity service) {
        return serviceRepository.save(service);
    }

    @Override
    @Transactional
    public ServiceEntity updateService(ServiceEntity service) {
        ServiceEntity existing = serviceRepository.findById(service.getId())
                .orElseThrow(() -> new IllegalArgumentException("Service not found"));
        existing.setServiceName(service.getServiceName());
        existing.setPrice(service.getPrice());
        existing.setDurationMinutes(service.getDurationMinutes());
        existing.setDescription(service.getDescription());
        existing.setCategory(service.getCategory());
        existing.setSubCategory(service.getSubCategory());
        return serviceRepository.save(existing);
    }

    @Override
    @Transactional
    public void deleteService(Long serviceId) {
        serviceRepository.deleteById(serviceId);
    }

    @Override
    public List<ServiceEntity> listServicesBySalon(Salon salon) {
        return serviceRepository.findBySalon(salon);
    }
}
