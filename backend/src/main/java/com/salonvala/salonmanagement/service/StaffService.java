package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.Staff;
import com.salonvala.salonmanagement.entity.Salon;

import java.util.List;

public interface StaffService {
    Staff addStaff(Staff staff);
    Staff updateStaff(Staff staff);
    void deleteStaff(Long staffId);
    List<Staff> listStaffBySalon(Salon salon);
    Staff getStaffById(Long staffId);
}

