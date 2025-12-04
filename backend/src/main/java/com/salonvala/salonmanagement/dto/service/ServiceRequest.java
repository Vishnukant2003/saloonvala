package com.salonvala.salonmanagement.dto.service;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ServiceRequest {

    private Long serviceId;        // For update operations
    private Long salonId;          // Salon to which this service belongs

    private String serviceName;    // Example: Hair Cut, Beard Trim
    private Double price;          // Service price
    private Integer durationMinutes;   // Example: 30, 45, 60
    private String description;    // Optional: details about service
    private String category;      // Main category: "Haircut", "Hair Colors", "Hair Treatment", "Hair Styling", "Groom Package"
    private String subCategory;    // Sub-category based on the main category
}
