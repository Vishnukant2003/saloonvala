package com.salonvala.salonmanagement.dto.auth;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterRequest {
    private String name;
    private String mobile;  // primary login id
    private String email;   // optional
    private String password;
    private String role;
}
