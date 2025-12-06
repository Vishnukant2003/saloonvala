package com.salonvala.salonmanagement.entity;

import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.SalonApprovalStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "salons")
public class Salon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String salonName;

    private String address;

    private String city;

    private String state;

    private String pincode;

    private String contactNumber;

    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String imageUrl;

    @Enumerated(EnumType.STRING)
    private SalonApprovalStatus approvalStatus = SalonApprovalStatus.PENDING;

    @ManyToOne
    @JoinColumn(name = "owner_id")
    private User owner;

    private String openTime;

    private String closeTime;

    private Boolean isLive = false;

    // Geographic location (for maps / directions)
    private Double latitude;

    private Double longitude;

    // Salon category (e.g., "Men's Salon", "Women's Salon", "Unisex", "Makeup", "Facial", "Hair Care")
    private String category;

    // Additional business details
    private String establishedYear;

    @Column(length = 2000)
    private String description;

    private Integer numberOfStaff;

    private String specialities;

    private String languages;

    // Service coverage area description
    private String serviceArea;
    
    // Landmark for location
    private String landmark;
    
    // Home service availability
    private Boolean homeServiceAvailable = false;
    
    // Working days (e.g., "Mon,Tue,Wed,Thu,Fri,Sat")
    private String workingDays;
    
    // Rejection reason (when rejected by admin)
    @Column(length = 1000)
    private String rejectionReason;
    
    // ==================== OWNER DETAILS ====================
    private String ownerName;
    private String ownerPhone;
    private String ownerEmail;
    private String ownerAge;
    private String ownerGender;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String ownerProfileImageUrl;
    
    // ==================== DOCUMENTS ====================
    // Aadhaar
    private String aadhaarNumber;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String aadhaarFrontImageUrl;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String aadhaarBackImageUrl;
    
    // PAN Card
    private String panNumber;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String panCardImageUrl;
    
    // Shop License
    private String shopLicenseNumber;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String shopLicenseImageUrl;
    
    // GST
    private String gstNumber;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String gstCertificateImageUrl;
    
    // ==================== PHOTOS ====================
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String liveSelfieImageUrl;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String shopFrontImageUrl;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String shopInsideImage1Url;
    
    @Lob
    @Column(columnDefinition = "LONGTEXT")
    private String shopInsideImage2Url;

    // Timestamp when salon was registered
    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    // Timestamp when salon was reviewed by admin
    private LocalDateTime reviewedAt;

    // Admin who reviewed the salon
    private Long reviewedBy;
}
