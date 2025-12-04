package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.dto.salon.SalonRequest;
import com.salonvala.salonmanagement.dto.salon.SalonResponse;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.security.jwt.CustomUserDetails;
import com.salonvala.salonmanagement.service.OwnerService;
import com.salonvala.salonmanagement.service.SalonService;
import com.salonvala.salonmanagement.utils.DtoMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/owner")
@CrossOrigin
public class OwnerController {

    @Autowired
    private OwnerService ownerService;

    @Autowired
    private SalonService salonService;

    // Simple helper to check required string fields
    private boolean isNullOrBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    // Get logged-in Owner ID
    private Long getLoggedInOwnerId() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        CustomUserDetails user = (CustomUserDetails) auth.getPrincipal();
        return user.getId();
    }

    // 1️⃣ GET OWNER PROFILE (from token, no ownerId in URL)
    @GetMapping("/me")
    public ResponseEntity<?> getOwnerProfile() {

        Long ownerId = getLoggedInOwnerId();
        User owner = ownerService.getOwnerById(ownerId);

        var map = new java.util.HashMap<String, Object>();
        map.put("id", owner.getId());
        map.put("name", owner.getName());
        map.put("mobile", owner.getMobile());
        map.put("role", owner.getRole().name());

        return ResponseEntity.ok(new ApiResponse("Owner fetched", map));
    }

    // 2️⃣ GET ALL SALONS FOR LOGGED-IN OWNER
    @GetMapping("/salons")
    public ResponseEntity<?> getMySalons() {

        Long ownerId = getLoggedInOwnerId();

        List<SalonResponse> list = ownerService.getSalonsByOwner(ownerId)
                .stream()
                .map(DtoMapper::toSalonResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(new ApiResponse("My salons fetched", list));
    }

    // 3️⃣ CREATE A SALON FOR LOGGED-IN OWNER
    @PostMapping("/salon")
    public ResponseEntity<?> createSalon(@RequestBody SalonRequest req) {

        Long ownerId = getLoggedInOwnerId();

        // ✅ Server-side validation: do NOT create salon if mandatory details are missing
        if (isNullOrBlank(req.getSalonName()) ||
                isNullOrBlank(req.getAddress()) ||
                isNullOrBlank(req.getCity()) ||
                isNullOrBlank(req.getState()) ||
                isNullOrBlank(req.getPincode()) ||
                isNullOrBlank(req.getContactNumber()) ||
                isNullOrBlank(req.getCategory()) ||
                isNullOrBlank(req.getEstablishedYear()) ||
                isNullOrBlank(req.getDescription()) ||
                req.getNumberOfStaff() == null || req.getNumberOfStaff() <= 0 ||
                req.getLatitude() == null || req.getLongitude() == null ||
                isNullOrBlank(req.getLanguages()) ||
                isNullOrBlank(req.getServiceArea())) {

            return ResponseEntity
                    .badRequest()
                    .body(new ApiResponse("Please fill all mandatory salon details in the form before creating the salon.", null));
        }

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
        s.setLatitude(req.getLatitude());
        s.setLongitude(req.getLongitude());
        s.setCategory(req.getCategory());
        s.setEstablishedYear(req.getEstablishedYear());
        s.setDescription(req.getDescription());
        s.setNumberOfStaff(req.getNumberOfStaff());
        s.setSpecialities(req.getSpecialities());
        s.setLanguages(req.getLanguages());
        s.setServiceArea(req.getServiceArea());

        Salon saved = ownerService.createSalonForOwner(ownerId, s);

        return ResponseEntity.ok(new ApiResponse("Salon created", DtoMapper.toSalonResponse(saved)));
    }

    // 4️⃣ UPDATE SALON FOR LOGGED-IN OWNER
    @PutMapping("/salon")
    public ResponseEntity<?> updateSalon(@RequestBody SalonRequest req) {

        Long ownerId = getLoggedInOwnerId();

        Salon s = salonService.getSalonById(req.getSalonId());
        
        s.setSalonName(req.getSalonName());
        s.setAddress(req.getAddress());
        s.setCity(req.getCity());
        s.setState(req.getState());
        s.setPincode(req.getPincode());
        s.setContactNumber(req.getContactNumber());
        s.setImageUrl(req.getImageUrl());
        s.setOpenTime(req.getOpenTime());
        s.setCloseTime(req.getCloseTime());
        if (req.getIsLive() != null) {
            s.setIsLive(req.getIsLive());
        }
        if (req.getLatitude() != null) {
            s.setLatitude(req.getLatitude());
        }
        if (req.getLongitude() != null) {
            s.setLongitude(req.getLongitude());
        }
        if (req.getCategory() != null) {
            s.setCategory(req.getCategory());
        }
        if (req.getEstablishedYear() != null) {
            s.setEstablishedYear(req.getEstablishedYear());
        }
        if (req.getDescription() != null) {
            s.setDescription(req.getDescription());
        }
        if (req.getNumberOfStaff() != null) {
            s.setNumberOfStaff(req.getNumberOfStaff());
        }
        if (req.getSpecialities() != null) {
            s.setSpecialities(req.getSpecialities());
        }
        if (req.getLanguages() != null) {
            s.setLanguages(req.getLanguages());
        }
        if (req.getServiceArea() != null) {
            s.setServiceArea(req.getServiceArea());
        }

        Salon updated = ownerService.updateSalon(ownerId, s);

        return ResponseEntity.ok(new ApiResponse("Salon updated", DtoMapper.toSalonResponse(updated)));
    }
}
