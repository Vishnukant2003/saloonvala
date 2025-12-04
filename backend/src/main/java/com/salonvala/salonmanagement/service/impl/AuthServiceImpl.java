package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.dto.auth.RegisterRequest;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.Role;
import com.salonvala.salonmanagement.repository.UserRepository;
import com.salonvala.salonmanagement.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public AuthServiceImpl(UserRepository userRepository,
                           PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public User register(RegisterRequest request) {

        // Check if mobile already exists
        if (userRepository.existsByMobile(request.getMobile())) {
            throw new IllegalArgumentException("Mobile number already registered");
        }

        // Create new user
        User user = new User();
        user.setName(request.getName());
        user.setMobile(request.getMobile());   // Login ID
        user.setEmail(request.getEmail());     // Optional field

        String rawPassword = request.getPassword();
        if (!StringUtils.hasText(rawPassword)) {
            rawPassword = java.util.UUID.randomUUID().toString();
        }

        user.setPassword(passwordEncoder.encode(rawPassword));

        // Set role
        Role role;
        try {
            role = Role.valueOf(request.getRole().toUpperCase());
        } catch (Exception e) {
            role = Role.USER;
        }
        user.setRole(role);

        user.setIsActive(true);

        return userRepository.save(user);
    }

    @Override
    public User findByMobile(String mobile) {
        return userRepository.findByMobile(mobile)
                .orElseThrow(() -> new IllegalArgumentException("Mobile not registered"));
    }
}
