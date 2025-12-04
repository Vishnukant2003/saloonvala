package com.salonvala.salonmanagement.dto.salon;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ServiceRequest {

    private Long serviceId;      // For update
    private Long salonId;        // Which salon this service belongs to

    private String serviceName;
    private Double price;
    private Integer durationMinutes;   // Example: 30, 45, 60
    private String description;
}
