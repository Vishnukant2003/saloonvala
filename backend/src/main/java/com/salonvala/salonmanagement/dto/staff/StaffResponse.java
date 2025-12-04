package com.salonvala.salonmanagement.dto.staff;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StaffResponse {

    private Long id;
    private String name;
    private String mobileNumber;
    private String email;
    private String role;
    private String specialties;
    private Integer experience;
    private String gender;
    private String photoUrl;
    private String workingDays;
    private String shift;
    private Integer age;
    private Boolean isAvailable;
    private Boolean isOnline;
    private Double totalWorkingHours;
    private Double todayWorkingHours;
    private Long salonId;
}

