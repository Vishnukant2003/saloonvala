package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.auth.LoginRequest;
import com.salonvala.salonmanagement.dto.auth.LoginResponse;
import com.salonvala.salonmanagement.dto.auth.RegisterRequest;
import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.security.jwt.JwtTokenProvider;
import com.salonvala.salonmanagement.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {

    @Autowired
    private AuthService authService;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    // REGISTER
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        User newUser = authService.register(request);
        return ResponseEntity.ok(new ApiResponse("Registration successful", null));
    }

    // LOGIN
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        User user = authService.findByMobile(request.getMobile());

        // If user is blocked by admin, prevent login
        if (Boolean.FALSE.equals(user.getIsActive())) {
            return ResponseEntity
                    .status(403)
                    .body(new ApiResponse("Your account has been blocked by admin. Please contact support.", null));
        }

        String token = jwtTokenProvider.generateToken(user);

        LoginResponse response = new LoginResponse(
                user.getId(),
                user.getName(),
                user.getMobile(),
                user.getRole().name(),
                token
        );

        return ResponseEntity.ok(new ApiResponse("Login successful", response));
    }
}
