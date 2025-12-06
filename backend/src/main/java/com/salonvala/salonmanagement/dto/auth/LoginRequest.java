package com.salonvala.salonmanagement.dto.auth;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LoginRequest {
    private String mobile;
    private String name;
    private String role;  // USER, OWNER, or ADMIN - used to validate correct login page
}
