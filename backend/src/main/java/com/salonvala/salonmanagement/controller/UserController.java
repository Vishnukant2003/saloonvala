package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.security.jwt.CustomUserDetails;
import com.salonvala.salonmanagement.security.jwt.JwtTokenProvider;
import com.salonvala.salonmanagement.service.UserService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/user")
@CrossOrigin
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    // Convert to simple map DTO
    private Map<String, Object> toDto(User u) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", u.getId());
        m.put("name", u.getName());
        m.put("email", u.getEmail());
        m.put("mobile", u.getMobile());
        m.put("role", u.getRole().name());
        m.put("isActive", u.getIsActive());
        m.put("gender", u.getGender());
        m.put("address", u.getAddress());
        m.put("latitude", u.getLatitude());
        m.put("longitude", u.getLongitude());
        return m;
    }

    // ---------------------------------------------
    // 1️⃣ Get User Profile
    // ---------------------------------------------
    @GetMapping("/{userId}")
    public ResponseEntity<?> getUser(@PathVariable Long userId) {
        User u = userService.getUserById(userId);
        return ResponseEntity.ok(toDto(u));
    }

    // ---------------------------------------------
    // 2️⃣ Update User Profile
    // ---------------------------------------------
    @PutMapping("/update/{userId}")
    public ResponseEntity<?> updateUser(
            @PathVariable Long userId,
            @RequestBody Map<String, Object> req) {

        User u = userService.getUserById(userId);

        if (req.containsKey("name")) u.setName((String) req.get("name"));
        if (req.containsKey("email")) u.setEmail((String) req.get("email"));
        if (req.containsKey("mobile")) u.setMobile((String) req.get("mobile"));
        if (req.containsKey("gender")) u.setGender((String) req.get("gender"));
        if (req.containsKey("address")) u.setAddress((String) req.get("address"));

        if (req.containsKey("latitude")) {
            Object latObj = req.get("latitude");
            if (latObj instanceof Number) {
                u.setLatitude(((Number) latObj).doubleValue());
            } else if (latObj instanceof String && !((String) latObj).isEmpty()) {
                try {
                    u.setLatitude(Double.parseDouble((String) latObj));
                } catch (NumberFormatException ignored) {}
            }
        }

        if (req.containsKey("longitude")) {
            Object lngObj = req.get("longitude");
            if (lngObj instanceof Number) {
                u.setLongitude(((Number) lngObj).doubleValue());
            } else if (lngObj instanceof String && !((String) lngObj).isEmpty()) {
                try {
                    u.setLongitude(Double.parseDouble((String) lngObj));
                } catch (NumberFormatException ignored) {}
            }
        }

        User updated = userService.updateUser(u);

        return ResponseEntity.ok(new ApiResponse("User updated", toDto(updated)));
    }

    // ---------------------------------------------
    // 3️⃣ List all users (Admin)
    // ---------------------------------------------
    @GetMapping("/all")
    public ResponseEntity<?> listAllUsers() {
        List<Map<String, Object>> list =
                userService.listAllUsers()
                        .stream()
                        .map(this::toDto)
                        .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }

    // ---------------------------------------------
    // 4️⃣ Delete user (Admin)
    // ---------------------------------------------
    @DeleteMapping("/delete/{userId}")
    public ResponseEntity<?> deleteUser(@PathVariable Long userId) {
        userService.deleteUser(userId);
        return ResponseEntity.ok(new ApiResponse("User deleted", null));
    }

    @GetMapping("/me")
    public ResponseEntity<?> getLoggedInUser() {

        var authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body(new ApiResponse("Not authenticated", null));
        }

        Object principal = authentication.getPrincipal();

        // If anonymous (token missing or invalid)
        if (principal.equals("anonymousUser")) {
            return ResponseEntity.status(401).body(new ApiResponse("Invalid token", null));
        }

        CustomUserDetails userDetails = (CustomUserDetails) principal;

        Long userId = userDetails.getId();
        User user = userService.getUserById(userId);

        return ResponseEntity.ok(new ApiResponse("User fetched", toDto(user)));
    }

}
