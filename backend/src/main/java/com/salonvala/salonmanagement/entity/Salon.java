package com.salonvala.salonmanagement.entity;

import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.SalonApprovalStatus;
import jakarta.persistence.*;
import lombok.*;

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
}
