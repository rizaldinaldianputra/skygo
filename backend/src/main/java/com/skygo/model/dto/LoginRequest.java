package com.skygo.model.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String phone;
    private String email;
    private String password;
}
