package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.dto.service.ServiceRequest;
import com.salonvala.salonmanagement.dto.service.ServiceResponse;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.ServiceEntity;
import com.salonvala.salonmanagement.service.SalonService;
import com.salonvala.salonmanagement.service.ServiceService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/service")
@CrossOrigin
public class ServiceController {

    @Autowired
    private ServiceService serviceService;

    @Autowired
    private SalonService salonService;

    // Convert entity → DTO
    private ServiceResponse toDto(ServiceEntity s) {
        ServiceResponse r = new ServiceResponse();
        r.setId(s.getId());
        r.setServiceName(s.getServiceName());
        r.setPrice(s.getPrice());
        r.setDurationMinutes(s.getDurationMinutes());
        r.setDescription(s.getDescription());
        r.setCategory(s.getCategory());
        r.setSubCategory(s.getSubCategory());
        return r;
    }

    // -------------------------------------
    // 1️⃣ Add new service under a Salon
    // -------------------------------------
    @PostMapping("/add")
    public ResponseEntity<?> addService(@RequestBody ServiceRequest req) {

        Salon salon = salonService.getSalonById(req.getSalonId());

        ServiceEntity s = new ServiceEntity();
        s.setSalon(salon);
        s.setServiceName(req.getServiceName());
        s.setPrice(req.getPrice());
        s.setDurationMinutes(req.getDurationMinutes());
        s.setDescription(req.getDescription());
        s.setCategory(req.getCategory());
        s.setSubCategory(req.getSubCategory());

        ServiceEntity saved = serviceService.addService(s);

        return ResponseEntity.ok(new ApiResponse("Service added", toDto(saved)));
    }

    // -------------------------------------
    // 2️⃣ Update an existing service
    // -------------------------------------
    @PutMapping("/update")
    public ResponseEntity<?> updateService(@RequestBody ServiceRequest req) {

        ServiceEntity s = new ServiceEntity();
        s.setId(req.getServiceId());
        s.setServiceName(req.getServiceName());
        s.setPrice(req.getPrice());
        s.setDurationMinutes(req.getDurationMinutes());
        s.setDescription(req.getDescription());
        s.setCategory(req.getCategory());
        s.setSubCategory(req.getSubCategory());

        ServiceEntity updated = serviceService.updateService(s);

        return ResponseEntity.ok(new ApiResponse("Service updated", toDto(updated)));
    }

    // -------------------------------------
    // 3️⃣ Delete a service
    // -------------------------------------
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteService(@PathVariable Long id) {

        serviceService.deleteService(id);
        return ResponseEntity.ok(new ApiResponse("Service deleted", null));
    }

    // -------------------------------------
    // 4️⃣ List all services for a Salon
    // -------------------------------------
    @GetMapping("/salon/{salonId}")
    public ResponseEntity<?> listServicesOfSalon(@PathVariable Long salonId) {

        Salon salon = salonService.getSalonById(salonId);

        List<ServiceResponse> list = serviceService.listServicesBySalon(salon)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }
}
