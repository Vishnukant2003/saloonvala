package com.salonvala.salonmanagement.dto.salon;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SalonResponse {

    private Long id;
    private String salonName;
    private String address;
    private String city;
    private String state;
    private String pincode;

    private String contactNumber;
    private String imageUrl;

    private String approvalStatus;

    private String openTime;
    private String closeTime;

    private Long ownerId;
    
    private Boolean isLive;

    // Geographic location
    private Double latitude;

    private Double longitude;

    // Salon category (e.g., "Men's Salon", "Women's Salon", "Unisex", "Makeup", "Facial", "Hair Care")
    private String category;

    // Additional business details
    private String establishedYear;
    private String description;
    private Integer numberOfStaff;
    private String specialities;
    private String languages;

    // Service coverage area description
    private String serviceArea;
}
