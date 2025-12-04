package com.salonvala.salonmanagement.security.config;

import com.salonvala.salonmanagement.security.jwt.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.web.cors.CorsConfigurationSource;

@Configuration
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtFilter;

    @Autowired
    private CorsConfigurationSource corsConfigurationSource;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth

                        // PUBLIC AUTH ENDPOINT
                        .requestMatchers("/api/auth/**").permitAll()

                        // ADMIN PANEL STATIC UI & ASSETS
                        .requestMatchers("/", "/favicon.ico", "/admin-panel/**", "/static/**", "/uploads/**").permitAll()

                        // Swagger
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()

                        // Public Salon APIs (order matters - more specific first)
                        // Allow public access to view staff for booking - customers need to see staff
                        // MUST be before any /api/staff/** patterns
                        .requestMatchers("/api/staff/salon/**").permitAll()
                        .requestMatchers("/api/salon/all", "/api/salon/city/**", "/api/salon/{id}", "/api/service/salon/**", "/api/salon/gallery/{salonId}").permitAll()

                        // Logged-in User
                        .requestMatchers("/api/user/me").authenticated()

                        // Admin
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")

                        // Owner (staff management endpoints except public viewing)
                        .requestMatchers("/api/owner/**", "/api/salon/gallery/**", "/api/staff/add", "/api/staff/update", "/api/staff/delete/**", "/api/staff/toggle-online/**").hasAnyRole("OWNER", "ADMIN")
                        
                        // Booking endpoints - owners need to see their salon bookings
                        .requestMatchers("/api/booking/salon/**").hasAnyRole("OWNER", "ADMIN", "USER")

                        // Payments
                        .requestMatchers("/api/payment/**").hasAnyRole("OWNER", "ADMIN", "USER")

                        // All other endpoints require authentication
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
