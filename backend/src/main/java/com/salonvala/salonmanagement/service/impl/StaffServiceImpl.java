package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.Staff;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.repository.StaffRepository;
import com.salonvala.salonmanagement.service.StaffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class StaffServiceImpl implements StaffService {

    private final StaffRepository staffRepository;

    @Autowired
    public StaffServiceImpl(StaffRepository staffRepository) {
        this.staffRepository = staffRepository;
    }

    @Override
    @Transactional
    public Staff addStaff(Staff staff) {
        return staffRepository.save(staff);
    }

    @Override
    @Transactional
    public Staff updateStaff(Staff staff) {
        Staff existing = staffRepository.findById(staff.getId())
                .orElseThrow(() -> new IllegalArgumentException("Staff not found"));
        
        existing.setName(staff.getName());
        existing.setMobileNumber(staff.getMobileNumber());
        existing.setEmail(staff.getEmail());
        existing.setRole(staff.getRole());
        existing.setSpecialties(staff.getSpecialties());
        existing.setExperience(staff.getExperience());
        existing.setGender(staff.getGender());
        if (staff.getPhotoUrl() != null) {
            existing.setPhotoUrl(staff.getPhotoUrl());
        }
        if (staff.getWorkingDays() != null) {
            existing.setWorkingDays(staff.getWorkingDays());
        }
        if (staff.getShift() != null) {
            existing.setShift(staff.getShift());
        }
        if (staff.getAge() != null) {
            existing.setAge(staff.getAge());
        }
        if (staff.getAvailable() != null) {
            existing.setAvailable(staff.getAvailable());
        }
        // Always update online status and related fields to ensure persistence
        if (staff.getIsOnline() != null) {
            existing.setIsOnline(staff.getIsOnline());
        }
        if (staff.getLastOnlineTime() != null) {
            existing.setLastOnlineTime(staff.getLastOnlineTime());
        }
        if (staff.getLastOfflineTime() != null) {
            existing.setLastOfflineTime(staff.getLastOfflineTime());
        }
        if (staff.getTotalWorkingHours() != null) {
            existing.setTotalWorkingHours(staff.getTotalWorkingHours());
        }
        if (staff.getTodayWorkingHours() != null) {
            existing.setTodayWorkingHours(staff.getTodayWorkingHours());
        }
        if (staff.getLastResetDate() != null) {
            existing.setLastResetDate(staff.getLastResetDate());
        }
        
        // Save to database - this ensures persistence even if app is closed
        return staffRepository.save(existing);
    }

    @Override
    @Transactional
    public void deleteStaff(Long staffId) {
        staffRepository.deleteById(staffId);
    }

    @Override
    public List<Staff> listStaffBySalon(Salon salon) {
        return staffRepository.findBySalon(salon);
    }

    @Override
    public Staff getStaffById(Long staffId) {
        return staffRepository.findById(staffId)
                .orElseThrow(() -> new IllegalArgumentException("Staff not found"));
    }
}

