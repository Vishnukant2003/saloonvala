package com.salonvala.salonmanagement.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "services")
public class ServiceEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String serviceName;

    private Double price;

    private Integer durationMinutes;

    private String description;
    
    private String category;  // e.g., "Haircut", "Hair Colors", "Hair Treatment", "Hair Styling", "Groom Package"
    
    private String subCategory;  // Sub-category based on the main category

    @ManyToOne
    @JoinColumn(name = "salon_id")
    private Salon salon;
}
