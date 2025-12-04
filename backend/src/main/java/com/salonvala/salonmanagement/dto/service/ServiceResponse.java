package com.salonvala.salonmanagement.dto.service;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ServiceResponse {

    private Long id;
    private String serviceName;
    private Double price;
    private Integer durationMinutes;
    private String description;
    private String category;
    private String subCategory;
}
