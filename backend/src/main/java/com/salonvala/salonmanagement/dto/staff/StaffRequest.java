package com.salonvala.salonmanagement.dto.staff;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StaffRequest {

    private Long staffId;        // For update operations
    private Long salonId;        // Salon to which this staff belongs

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
}

