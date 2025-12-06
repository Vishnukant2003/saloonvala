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
                isNullOrBlank(req.getPincode())) {

            return ResponseEntity
                    .badRequest()
                    .body(new ApiResponse("Please fill all mandatory salon details (name, address, city, state, pincode).", null));
        }

        Salon s = new Salon();
        
        // Basic Salon Info
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
        s.setLandmark(req.getLandmark());
        s.setHomeServiceAvailable(req.getHomeServiceAvailable());
        s.setWorkingDays(req.getWorkingDays());
        
        // Owner Details
        s.setOwnerName(req.getOwnerName());
        s.setOwnerPhone(req.getOwnerPhone());
        s.setOwnerEmail(req.getOwnerEmail());
        s.setOwnerAge(req.getOwnerAge());
        s.setOwnerGender(req.getOwnerGender());
        s.setOwnerProfileImageUrl(req.getOwnerProfileImageUrl());
        
        // Documents
        s.setAadhaarNumber(req.getAadhaarNumber());
        s.setAadhaarFrontImageUrl(req.getAadhaarFrontImageUrl());
        s.setAadhaarBackImageUrl(req.getAadhaarBackImageUrl());
        s.setPanNumber(req.getPanNumber());
        s.setPanCardImageUrl(req.getPanCardImageUrl());
        s.setShopLicenseNumber(req.getShopLicenseNumber());
        s.setShopLicenseImageUrl(req.getShopLicenseImageUrl());
        s.setGstNumber(req.getGstNumber());
        s.setGstCertificateImageUrl(req.getGstCertificateImageUrl());
        
        // Photos
        s.setLiveSelfieImageUrl(req.getLiveSelfieImageUrl());
        s.setShopFrontImageUrl(req.getShopFrontImageUrl());
        s.setShopInsideImage1Url(req.getShopInsideImage1Url());
        s.setShopInsideImage2Url(req.getShopInsideImage2Url());

        Salon saved = ownerService.createSalonForOwner(ownerId, s);

        return ResponseEntity.ok(new ApiResponse("Salon created", DtoMapper.toSalonResponse(saved)));
    }

    // 4️⃣ UPDATE SALON FOR LOGGED-IN OWNER
    @PutMapping("/salon")
    public ResponseEntity<?> updateSalon(@RequestBody SalonRequest req) {

        Long ownerId = getLoggedInOwnerId();

        Salon s = salonService.getSalonById(req.getSalonId());
        
        // Basic Info
        if (req.getSalonName() != null) s.setSalonName(req.getSalonName());
        if (req.getAddress() != null) s.setAddress(req.getAddress());
        if (req.getCity() != null) s.setCity(req.getCity());
        if (req.getState() != null) s.setState(req.getState());
        if (req.getPincode() != null) s.setPincode(req.getPincode());
        if (req.getContactNumber() != null) s.setContactNumber(req.getContactNumber());
        if (req.getImageUrl() != null) s.setImageUrl(req.getImageUrl());
        if (req.getOpenTime() != null) s.setOpenTime(req.getOpenTime());
        if (req.getCloseTime() != null) s.setCloseTime(req.getCloseTime());
        if (req.getIsLive() != null) s.setIsLive(req.getIsLive());
        if (req.getLatitude() != null) s.setLatitude(req.getLatitude());
        if (req.getLongitude() != null) s.setLongitude(req.getLongitude());
        if (req.getCategory() != null) s.setCategory(req.getCategory());
        if (req.getEstablishedYear() != null) s.setEstablishedYear(req.getEstablishedYear());
        if (req.getDescription() != null) s.setDescription(req.getDescription());
        if (req.getNumberOfStaff() != null) s.setNumberOfStaff(req.getNumberOfStaff());
        if (req.getSpecialities() != null) s.setSpecialities(req.getSpecialities());
        if (req.getLanguages() != null) s.setLanguages(req.getLanguages());
        if (req.getServiceArea() != null) s.setServiceArea(req.getServiceArea());
        if (req.getLandmark() != null) s.setLandmark(req.getLandmark());
        if (req.getHomeServiceAvailable() != null) s.setHomeServiceAvailable(req.getHomeServiceAvailable());
        if (req.getWorkingDays() != null) s.setWorkingDays(req.getWorkingDays());
        
        // Owner Details
        if (req.getOwnerName() != null) s.setOwnerName(req.getOwnerName());
        if (req.getOwnerPhone() != null) s.setOwnerPhone(req.getOwnerPhone());
        if (req.getOwnerEmail() != null) s.setOwnerEmail(req.getOwnerEmail());
        if (req.getOwnerAge() != null) s.setOwnerAge(req.getOwnerAge());
        if (req.getOwnerGender() != null) s.setOwnerGender(req.getOwnerGender());
        if (req.getOwnerProfileImageUrl() != null) s.setOwnerProfileImageUrl(req.getOwnerProfileImageUrl());
        
        // Documents
        if (req.getAadhaarNumber() != null) s.setAadhaarNumber(req.getAadhaarNumber());
        if (req.getAadhaarFrontImageUrl() != null) s.setAadhaarFrontImageUrl(req.getAadhaarFrontImageUrl());
        if (req.getAadhaarBackImageUrl() != null) s.setAadhaarBackImageUrl(req.getAadhaarBackImageUrl());
        if (req.getPanNumber() != null) s.setPanNumber(req.getPanNumber());
        if (req.getPanCardImageUrl() != null) s.setPanCardImageUrl(req.getPanCardImageUrl());
        if (req.getShopLicenseNumber() != null) s.setShopLicenseNumber(req.getShopLicenseNumber());
        if (req.getShopLicenseImageUrl() != null) s.setShopLicenseImageUrl(req.getShopLicenseImageUrl());
        if (req.getGstNumber() != null) s.setGstNumber(req.getGstNumber());
        if (req.getGstCertificateImageUrl() != null) s.setGstCertificateImageUrl(req.getGstCertificateImageUrl());
        
        // Photos
        if (req.getLiveSelfieImageUrl() != null) s.setLiveSelfieImageUrl(req.getLiveSelfieImageUrl());
        if (req.getShopFrontImageUrl() != null) s.setShopFrontImageUrl(req.getShopFrontImageUrl());
        if (req.getShopInsideImage1Url() != null) s.setShopInsideImage1Url(req.getShopInsideImage1Url());
        if (req.getShopInsideImage2Url() != null) s.setShopInsideImage2Url(req.getShopInsideImage2Url());

        Salon updated = ownerService.updateSalon(ownerId, s);

        return ResponseEntity.ok(new ApiResponse("Salon updated", DtoMapper.toSalonResponse(updated)));
    }
}
