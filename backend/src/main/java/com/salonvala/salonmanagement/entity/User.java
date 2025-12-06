package com.salonvala.salonmanagement.entity;

import com.salonvala.salonmanagement.enums.Role;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name="users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String email;  // Optional

    @Column(unique = true, nullable = false)
    private String mobile;

    @Column(unique = true)

    private String password;

    @Enumerated(EnumType.STRING)
    private Role role;

    private Boolean isActive = true;

    // Optional profile details
    private String gender;

    private String address;

    private String city;

    private String state;

    // User's last known location (for nearby salons)
    private Double latitude;

    private Double longitude;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
