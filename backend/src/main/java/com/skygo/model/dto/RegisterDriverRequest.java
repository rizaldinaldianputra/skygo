package com.skygo.model.dto;

import lombok.Data;

@Data
public class RegisterDriverRequest {
    private String name;
    private String phone;
    private String email;
    private String password;
    private String vehicleType;
    private String vehiclePlate;
}
