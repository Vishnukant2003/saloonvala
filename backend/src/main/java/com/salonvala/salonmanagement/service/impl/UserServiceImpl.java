package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.repository.UserRepository;
import com.salonvala.salonmanagement.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Autowired
    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // -------------------------------------
    // Get user by ID
    // -------------------------------------
    @Override
    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    // -------------------------------------
    // List all users (Admin)
    // -------------------------------------
    @Override
    public List<User> listAllUsers() {
        return userRepository.findAll();
    }

    // -------------------------------------
    // Update user profile
    // -------------------------------------
    @Override
    @Transactional
    public User updateUser(User user) {

        User existing = getUserById(user.getId());

        if (user.getName() != null)
            existing.setName(user.getName());

        if (user.getEmail() != null)
            existing.setEmail(user.getEmail());

        if (user.getMobile() != null)
            existing.setMobile(user.getMobile());

        if (user.getGender() != null)
            existing.setGender(user.getGender());

        if (user.getAddress() != null)
            existing.setAddress(user.getAddress());

        if (user.getLatitude() != null)
            existing.setLatitude(user.getLatitude());

        if (user.getLongitude() != null)
            existing.setLongitude(user.getLongitude());

        // Do NOT update password here.

        return userRepository.save(existing);
    }

    // -------------------------------------
    // Delete User (Admin)
    // -------------------------------------
    @Override
    @Transactional
    public void deleteUser(Long id) {
        User existing = getUserById(id);
        userRepository.delete(existing);
    }

    // -------------------------------------
    // Block User (Admin)
    // -------------------------------------
    @Override
    @Transactional
    public void blockUser(Long id) {
        User u = getUserById(id);
        u.setIsActive(false);
        userRepository.save(u);
    }

    // -------------------------------------
    // Unblock User (Admin)
    // -------------------------------------
    @Override
    @Transactional
    public void unblockUser(Long id) {
        User u = getUserById(id);
        u.setIsActive(true);
        userRepository.save(u);
    }
}
