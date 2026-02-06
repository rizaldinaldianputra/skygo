package com.skygo.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class DriverRegistrationRequest {
    private String name;
    private String email;
    private String password;
    private String phone;
    private String vehicleType;
    private String vehiclePlate;
    private MultipartFile sim;
    private MultipartFile ktp;
    private MultipartFile photo;
}
