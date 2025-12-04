package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.dto.auth.RegisterRequest;
import com.salonvala.salonmanagement.entity.User;

public interface AuthService {
    User register(RegisterRequest request);
    User findByMobile(String mobile);
}
