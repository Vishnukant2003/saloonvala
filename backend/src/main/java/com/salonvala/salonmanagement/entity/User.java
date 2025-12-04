package com.salonvala.salonmanagement.entity;

import com.salonvala.salonmanagement.enums.Role;
import jakarta.persistence.*;
import lombok.*;

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

    // User's last known location (for nearby salons)
    private Double latitude;

    private Double longitude;
}
