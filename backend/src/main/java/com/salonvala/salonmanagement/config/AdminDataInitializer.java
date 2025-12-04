package com.salonvala.salonmanagement.config;

import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.Role;
import com.salonvala.salonmanagement.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Slf4j
@Component
@RequiredArgsConstructor
public class AdminDataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${ADMIN_NAME:Salon Admin}")
    private String adminName;

    @Value("${ADMIN_EMAIL:aaaaditya82@gmail.com}")
    private String adminEmail;

    @Value("${ADMIN_MOBILE:8149230130}")
    private String adminMobile;

    @Value("${ADMIN_PASSWORD:Admin@123}")
    private String adminPassword;

    @Override
    public void run(String... args) {
        if (userRepository.countByRole(Role.ADMIN) > 0) {
            return;
        }

        if (!StringUtils.hasText(adminPassword)) {
            log.warn("Admin password is empty, skipping default admin creation");
            return;
        }

        User admin = new User();
        admin.setName(adminName);
        admin.setEmail(adminEmail);
        admin.setMobile(adminMobile);
        admin.setPassword(passwordEncoder.encode(adminPassword));
        admin.setRole(Role.ADMIN);
        admin.setIsActive(true);

        userRepository.save(admin);
        log.info("Inserted default admin user '{}'", adminMobile);
    }
}

