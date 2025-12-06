package com.salonvala.salonmanagement.dto.salon;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SalonRequest {

    private Long salonId;      // For update
    private Long ownerId;

    private String salonName;
    private String address;
    private String city;
    private String state;
    private String pincode;

    private String contactNumber;
    private String imageUrl;

    private String openTime;
    private String closeTime;
    
    private Boolean isLive;

    // Geographic location
    private Double latitude;
    private Double longitude;

    // Salon category
    private String category;

    // Additional business details
    private String establishedYear;
    private String description;
    private Integer numberOfStaff;
    private String specialities;
    private String languages;
    private String serviceArea;
    private String landmark;
    private Boolean homeServiceAvailable;
    private String workingDays;
    
    // ==================== OWNER DETAILS ====================
    private String ownerName;
    private String ownerPhone;
    private String ownerEmail;
    private String ownerAge;
    private String ownerGender;
    private String ownerProfileImageUrl;
    
    // ==================== DOCUMENTS ====================
    private String aadhaarNumber;
    private String aadhaarFrontImageUrl;
    private String aadhaarBackImageUrl;
    private String panNumber;
    private String panCardImageUrl;
    private String shopLicenseNumber;
    private String shopLicenseImageUrl;
    private String gstNumber;
    private String gstCertificateImageUrl;
    
    // ==================== PHOTOS ====================
    private String liveSelfieImageUrl;
    private String shopFrontImageUrl;
    private String shopInsideImage1Url;
    private String shopInsideImage2Url;
}
