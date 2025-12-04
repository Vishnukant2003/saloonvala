package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.dto.staff.StaffRequest;
import com.salonvala.salonmanagement.dto.staff.StaffResponse;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.Staff;
import com.salonvala.salonmanagement.service.SalonService;
import com.salonvala.salonmanagement.service.StaffService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/staff")
@CrossOrigin
public class StaffController {

    @Autowired
    private StaffService staffService;

    @Autowired
    private SalonService salonService;

    private static final String STAFF_UPLOAD_DIR = "uploads/staff/";

    // Create upload directory if it doesn't exist
    private void ensureStaffUploadDirExists() {
        try {
            Path uploadPath = Paths.get(STAFF_UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Test endpoint to verify controller is loaded
    @GetMapping("/test")
    public ResponseEntity<?> test() {
        return ResponseEntity.ok(new ApiResponse("Staff controller is working", null));
    }

    // Convert entity → DTO
    private StaffResponse toDto(Staff s) {
        StaffResponse r = new StaffResponse();
        r.setId(s.getId());
        r.setName(s.getName());
        r.setMobileNumber(s.getMobileNumber());
        r.setEmail(s.getEmail());
        r.setRole(s.getRole());
        r.setSpecialties(s.getSpecialties());
        r.setExperience(s.getExperience());
        r.setGender(s.getGender());
        r.setPhotoUrl(s.getPhotoUrl());
        r.setWorkingDays(s.getWorkingDays());
        r.setShift(s.getShift());
        r.setAge(s.getAge());
        r.setIsAvailable(s.getAvailable());
        r.setIsOnline(s.getIsOnline());
        r.setTotalWorkingHours(s.getTotalWorkingHours());
        r.setTodayWorkingHours(s.getTodayWorkingHours());
        r.setSalonId(s.getSalon() != null ? s.getSalon().getId() : null);
        return r;
    }

    // -------------------------------------
    // 1️⃣ Add new staff under a Salon
    // -------------------------------------
    @PostMapping("/add")
    public ResponseEntity<?> addStaff(@RequestBody StaffRequest req) {
        try {
            if (req.getSalonId() == null) {
                return ResponseEntity.badRequest()
                        .body(new ApiResponse("Salon ID is required", null));
            }

            if (req.getName() == null || req.getName().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(new ApiResponse("Staff name is required", null));
            }

            if (req.getRole() == null || req.getRole().trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(new ApiResponse("Staff role is required", null));
            }

            Salon salon = salonService.getSalonById(req.getSalonId());

            Staff s = new Staff();
            s.setSalon(salon);
            s.setName(req.getName());
            s.setMobileNumber(req.getMobileNumber());
            s.setEmail(req.getEmail());
            s.setRole(req.getRole());
            s.setSpecialties(req.getSpecialties());
            s.setExperience(req.getExperience());
            s.setGender(req.getGender());
            s.setPhotoUrl(req.getPhotoUrl());
            s.setWorkingDays(req.getWorkingDays());
            s.setShift(req.getShift());
            s.setAge(req.getAge());
            s.setAvailable(req.getIsAvailable() != null ? req.getIsAvailable() : true);

            Staff saved = staffService.addStaff(s);

            return ResponseEntity.ok(new ApiResponse("Staff added", toDto(saved)));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new ApiResponse("Error adding staff: " + e.getMessage(), null));
        }
    }

    // -------------------------------------
    // 2️⃣ Update an existing staff
    // -------------------------------------
    @PutMapping("/update")
    public ResponseEntity<?> updateStaff(@RequestBody StaffRequest req) {

        Staff existing = staffService.getStaffById(req.getStaffId());
        
        existing.setName(req.getName());
        existing.setMobileNumber(req.getMobileNumber());
        existing.setEmail(req.getEmail());
        existing.setRole(req.getRole());
        existing.setSpecialties(req.getSpecialties());
        existing.setExperience(req.getExperience());
        existing.setGender(req.getGender());
        if (req.getPhotoUrl() != null) {
            existing.setPhotoUrl(req.getPhotoUrl());
        }
        if (req.getWorkingDays() != null) {
            existing.setWorkingDays(req.getWorkingDays());
        }
        if (req.getShift() != null) {
            existing.setShift(req.getShift());
        }
        if (req.getAge() != null) {
            existing.setAge(req.getAge());
        }
        if (req.getIsAvailable() != null) {
            existing.setAvailable(req.getIsAvailable());
        }

        Staff updated = staffService.updateStaff(existing);

        return ResponseEntity.ok(new ApiResponse("Staff updated", toDto(updated)));
    }

    // -------------------------------------
    // 3️⃣ Delete a staff
    // -------------------------------------
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteStaff(@PathVariable Long id) {

        staffService.deleteStaff(id);
        return ResponseEntity.ok(new ApiResponse("Staff deleted", null));
    }

    // -------------------------------------
    // 4️⃣ List all staff for a Salon (Public - customers need to see staff for booking)
    // -------------------------------------
    @GetMapping("/salon/{salonId}")
    @PreAuthorize("permitAll()")
    public ResponseEntity<?> listStaffOfSalon(@PathVariable Long salonId) {

        Salon salon = salonService.getSalonById(salonId);
        LocalDateTime now = LocalDateTime.now();
        LocalDate today = LocalDate.now();

        List<Staff> staffList = staffService.listStaffBySalon(salon);
        
        // Calculate hours for currently online staff
        for (Staff staff : staffList) {
            // Reset today's hours if it's a new day
            if (staff.getLastResetDate() == null || !staff.getLastResetDate().toLocalDate().equals(today)) {
                // If staff was online when day changed, calculate hours from last online time to end of previous day
                if (staff.getIsOnline() != null && staff.getIsOnline() && staff.getLastOnlineTime() != null) {
                    LocalDateTime endOfPreviousDay = staff.getLastResetDate() != null 
                        ? staff.getLastResetDate().toLocalDate().atTime(23, 59, 59)
                        : staff.getLastOnlineTime().toLocalDate().atTime(23, 59, 59);
                    
                    if (staff.getLastOnlineTime().isBefore(endOfPreviousDay)) {
                        long minutes = ChronoUnit.MINUTES.between(staff.getLastOnlineTime(), endOfPreviousDay);
                        double hours = minutes / 60.0;
                        
                        double currentTotal = staff.getTotalWorkingHours() != null ? staff.getTotalWorkingHours() : 0.0;
                        staff.setTotalWorkingHours(currentTotal + hours);
                    }
                }
                staff.setTodayWorkingHours(0.0);
                staff.setLastResetDate(today.atStartOfDay());
            }

            // Calculate current hours if staff is online
            if (staff.getIsOnline() != null && staff.getIsOnline() && staff.getLastOnlineTime() != null) {
                long minutes = ChronoUnit.MINUTES.between(staff.getLastOnlineTime(), now);
                double hours = minutes / 60.0;

                // Calculate today's hours
                double todayHours = 0.0;
                if (staff.getLastOnlineTime().toLocalDate().equals(today)) {
                    // Staff went online today
                    todayHours = hours;
                } else {
                    // Staff was online from previous day - only count today's hours
                    LocalDateTime startOfToday = today.atStartOfDay();
                    if (staff.getLastOnlineTime().isBefore(startOfToday)) {
                        long todayMinutes = ChronoUnit.MINUTES.between(startOfToday, now);
                        todayHours = todayMinutes / 60.0;
                    } else {
                        todayHours = hours;
                    }
                }

                // Update today's working hours (temporary, for display)
                staff.setTodayWorkingHours(todayHours);
            }
        }

        List<StaffResponse> list = staffList.stream()
                .map(this::toDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }

    // -------------------------------------
    // 5️⃣ Toggle staff online/offline status and calculate working hours
    // -------------------------------------
    @PutMapping(value = "/toggle-online/{staffId}", produces = "application/json")
    public ResponseEntity<?> toggleOnlineStatus(@PathVariable Long staffId, @RequestParam Boolean isOnline) {
        try {
            Staff staff = staffService.getStaffById(staffId);
            LocalDateTime now = LocalDateTime.now();
            LocalDate today = LocalDate.now();

            // Reset today's hours if it's a new day
            if (staff.getLastResetDate() == null || !staff.getLastResetDate().toLocalDate().equals(today)) {
                // If staff was online when day changed, calculate hours from last online time to end of previous day
                if (staff.getIsOnline() != null && staff.getIsOnline() && staff.getLastOnlineTime() != null) {
                    LocalDateTime endOfPreviousDay = staff.getLastResetDate() != null 
                        ? staff.getLastResetDate().toLocalDate().atTime(23, 59, 59)
                        : staff.getLastOnlineTime().toLocalDate().atTime(23, 59, 59);
                    
                    if (staff.getLastOnlineTime().isBefore(endOfPreviousDay)) {
                        long minutes = ChronoUnit.MINUTES.between(staff.getLastOnlineTime(), endOfPreviousDay);
                        double hours = minutes / 60.0;
                        
                        double currentTotal = staff.getTotalWorkingHours() != null ? staff.getTotalWorkingHours() : 0.0;
                        staff.setTotalWorkingHours(currentTotal + hours);
                    }
                }
                staff.setTodayWorkingHours(0.0);
                staff.setLastResetDate(today.atStartOfDay());
            }

            // If staff is currently online and going offline, calculate hours
            if (!isOnline && staff.getIsOnline() != null && staff.getIsOnline()) {
                if (staff.getLastOnlineTime() != null) {
                    long minutes = ChronoUnit.MINUTES.between(staff.getLastOnlineTime(), now);
                    double hours = minutes / 60.0;

                    // Update total working hours
                    double currentTotal = staff.getTotalWorkingHours() != null ? staff.getTotalWorkingHours() : 0.0;
                    staff.setTotalWorkingHours(currentTotal + hours);

                    // Update today's working hours
                    double currentToday = staff.getTodayWorkingHours() != null ? staff.getTodayWorkingHours() : 0.0;
                    staff.setTodayWorkingHours(currentToday + hours);
                }
                staff.setIsOnline(false);
                staff.setLastOfflineTime(now);
            } else if (isOnline && (staff.getIsOnline() == null || !staff.getIsOnline())) {
                // Staff is going online
                staff.setIsOnline(true);
                staff.setLastOnlineTime(now);
            }

            Staff updated = staffService.updateStaff(staff);
            return ResponseEntity.ok(new ApiResponse("Status updated", toDto(updated)));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500)
                    .body(new ApiResponse("Error updating status: " + e.getMessage(), null));
        }
    }

    // -------------------------------------
    // 6️⃣ Get current working hours for online staff (for periodic updates)
    // -------------------------------------
    @GetMapping("/calculate-hours/{staffId}")
    public ResponseEntity<?> calculateCurrentHours(@PathVariable Long staffId) {
        try {
            Staff staff = staffService.getStaffById(staffId);
            LocalDateTime now = LocalDateTime.now();
            LocalDate today = LocalDate.now();

            // Reset today's hours if it's a new day
            if (staff.getLastResetDate() == null || !staff.getLastResetDate().toLocalDate().equals(today)) {
                staff.setTodayWorkingHours(0.0);
                staff.setLastResetDate(today.atStartOfDay());
            }

            // Calculate hours if staff is currently online
            if (staff.getIsOnline() != null && staff.getIsOnline() && staff.getLastOnlineTime() != null) {
                long minutes = ChronoUnit.MINUTES.between(staff.getLastOnlineTime(), now);
                double hours = minutes / 60.0;

                // Calculate today's hours (from last reset to now)
                double todayHours = hours;
                if (staff.getLastOnlineTime().toLocalDate().equals(today)) {
                    // Staff went online today
                    todayHours = hours;
                } else {
                    // Staff was online from previous day - only count today's hours
                    LocalDateTime startOfToday = today.atStartOfDay();
                    if (staff.getLastOnlineTime().isBefore(startOfToday)) {
                        long todayMinutes = ChronoUnit.MINUTES.between(startOfToday, now);
                        todayHours = todayMinutes / 60.0;
                    }
                }

                // Update today's working hours (temporary calculation, not saved until they go offline)
                staff.setTodayWorkingHours(todayHours);
            }

            return ResponseEntity.ok(new ApiResponse("Hours calculated", toDto(staff)));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500)
                    .body(new ApiResponse("Error calculating hours: " + e.getMessage(), null));
        }
    }

    // -------------------------------------
    // 7️⃣ Upload staff photo
    // -------------------------------------
    @PostMapping(value = "/upload-photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadStaffPhoto(
            @RequestPart("staffId") String staffIdStr,
            @RequestPart("image") MultipartFile file) {
        try {
            // Validate file
            if (file == null || file.isEmpty()) {
                return ResponseEntity.badRequest().body(new ApiResponse("File is empty", null));
            }

            // Parse staffId from string
            Long staffId;
            try {
                staffId = Long.parseLong(staffIdStr);
            } catch (NumberFormatException e) {
                return ResponseEntity.badRequest().body(new ApiResponse("Invalid staff ID", null));
            }

            Staff staff = staffService.getStaffById(staffId);
            ensureStaffUploadDirExists();

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf(".")) 
                : ".jpg";
            String filename = UUID.randomUUID().toString() + extension;

            // Save file
            Path filePath = Paths.get(STAFF_UPLOAD_DIR + filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            // Update staff photo URL
            String photoUrl = "/uploads/staff/" + filename;
            staff.setPhotoUrl(photoUrl);
            Staff updated = staffService.updateStaff(staff);

            Map<String, String> response = new HashMap<>();
            response.put("photoUrl", photoUrl);

            return ResponseEntity.ok(new ApiResponse("Photo uploaded successfully", response));
        } catch (org.springframework.web.multipart.MaxUploadSizeExceededException e) {
            return ResponseEntity.badRequest().body(new ApiResponse("File size exceeds maximum limit (100MB)", null));
        } catch (IOException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(new ApiResponse("Failed to upload file: " + e.getMessage(), null));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(new ApiResponse("Failed to upload file: " + e.getMessage(), null));
        }
    }
}

