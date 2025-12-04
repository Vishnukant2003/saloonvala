package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.dto.salon.SalonRequest;
import com.salonvala.salonmanagement.dto.salon.SalonResponse;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.service.OwnerService;
import com.salonvala.salonmanagement.service.SalonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/salon")
@CrossOrigin
public class SalonController {

    @Autowired
    private SalonService salonService;

    @Autowired
    private OwnerService ownerService;

    // 📌 Convert Entity → DTO
    private SalonResponse mapToDto(Salon salon) {
        SalonResponse dto = new SalonResponse();
        dto.setId(salon.getId());
        dto.setSalonName(salon.getSalonName());
        dto.setAddress(salon.getAddress());
        dto.setCity(salon.getCity());
        dto.setState(salon.getState());
        dto.setPincode(salon.getPincode());
        dto.setContactNumber(salon.getContactNumber());
        dto.setImageUrl(salon.getImageUrl());
        dto.setApprovalStatus(salon.getApprovalStatus().name());
        dto.setOpenTime(salon.getOpenTime());
        dto.setCloseTime(salon.getCloseTime());
        dto.setOwnerId(salon.getOwner().getId());
        dto.setIsLive(salon.getIsLive() != null ? salon.getIsLive() : false);
        dto.setLatitude(salon.getLatitude());
        dto.setLongitude(salon.getLongitude());
        // Map category so that user app can filter salons by category
        dto.setCategory(salon.getCategory());
        return dto;
    }

    // 📌 Create Salon (Owner)
    @PostMapping("/create")
    public ResponseEntity<?> createSalon(@RequestBody SalonRequest req) {

        // Owner exists?
        var owner = ownerService.getOwnerById(req.getOwnerId());

        // Create entity
        Salon s = new Salon();
        s.setSalonName(req.getSalonName());
        s.setAddress(req.getAddress());
        s.setCity(req.getCity());
        s.setState(req.getState());
        s.setPincode(req.getPincode());
        s.setContactNumber(req.getContactNumber());
        s.setImageUrl(req.getImageUrl());
        s.setOpenTime(req.getOpenTime());
        s.setCloseTime(req.getCloseTime());
        s.setCategory(req.getCategory());
        if (req.getIsLive() != null) {
            s.setIsLive(req.getIsLive());
        }
        s.setLatitude(req.getLatitude());
        s.setLongitude(req.getLongitude());
        s.setOwner(owner);

        Salon saved = salonService.createSalon(s);

        return ResponseEntity.ok(new ApiResponse("Salon created", mapToDto(saved)));
    }

    // 📌 Update Salon (Owner)
    @PutMapping("/update")
    public ResponseEntity<?> updateSalon(@RequestBody SalonRequest req) {

        var owner = ownerService.getOwnerById(req.getOwnerId());

        Salon s = salonService.getSalonById(req.getOwnerId());

        s.setSalonName(req.getSalonName());
        s.setAddress(req.getAddress());
        s.setCity(req.getCity());
        s.setState(req.getState());
        s.setPincode(req.getPincode());
        s.setContactNumber(req.getContactNumber());
        s.setImageUrl(req.getImageUrl());
        s.setOpenTime(req.getOpenTime());
        s.setCloseTime(req.getCloseTime());
        s.setCategory(req.getCategory());
        if (req.getIsLive() != null) {
            s.setIsLive(req.getIsLive());
        }
        s.setLatitude(req.getLatitude());
        s.setLongitude(req.getLongitude());
        s.setOwner(owner);

        Salon updated = salonService.updateSalon(s);

        return ResponseEntity.ok(new ApiResponse("Salon updated", mapToDto(updated)));
    }

    // 📌 Get Salon by ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        Salon salon = salonService.getSalonById(id);
        return ResponseEntity.ok(mapToDto(salon));
    }

    // 📌 List all salons (User App)
    @GetMapping("/all")
    public ResponseEntity<?> getAll() {
        // Return all salons without filtering by city
        List<SalonResponse> list = salonService.listAllSalons()
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }

    // 📌 List salons by city (User App)
    @GetMapping("/city/{city}")
    public ResponseEntity<?> getByCity(@PathVariable String city) {
        List<SalonResponse> list = salonService.listSalonsByCity(city)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }

    // 📌 Approve Salon (Admin)
    @PostMapping("/approve/{id}")
    public ResponseEntity<?> approveSalon(@PathVariable Long id) {
        Salon approved = salonService.approveSalon(id);
        return ResponseEntity.ok(new ApiResponse("Salon Approved", mapToDto(approved)));
    }

    // 📌 Reject Salon (Admin)
    @PostMapping("/reject/{id}")
    public ResponseEntity<?> rejectSalon(@PathVariable Long id, @RequestParam String reason) {
        Salon rejected = salonService.rejectSalon(id, reason);
        return ResponseEntity.ok(new ApiResponse("Salon Rejected", mapToDto(rejected)));
    }
}
