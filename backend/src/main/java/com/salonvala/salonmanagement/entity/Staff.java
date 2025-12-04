package com.salonvala.salonmanagement.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "staff")
public class Staff {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
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

    private Boolean available = true;

    private Boolean isOnline = false;

    private LocalDateTime lastOnlineTime;

    private LocalDateTime lastOfflineTime;

    private Double totalWorkingHours = 0.0;

    private Double todayWorkingHours = 0.0;

    private LocalDateTime lastResetDate;

    @ManyToOne
    @JoinColumn(name = "salon_id")
    private Salon salon;
}

