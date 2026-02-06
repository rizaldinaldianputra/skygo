package com.skygo.controller;

import com.skygo.model.Driver;
import com.skygo.model.User;
import com.skygo.model.dto.ApiResponse;
import com.skygo.model.dto.LoginRequest;
import com.skygo.model.dto.RegisterDriverRequest;
import com.skygo.model.dto.RegisterUserRequest;
import com.skygo.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/user/register")
    public ResponseEntity<ApiResponse<User>> registerUser(@RequestBody RegisterUserRequest request) {
        try {
            User user = authService.registerUser(request);
            return ResponseEntity.ok(ApiResponse.success("User registered successfully", user));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/driver/register")
    public ResponseEntity<ApiResponse<Driver>> registerDriver(@RequestBody RegisterDriverRequest request) {
        try {
            Driver driver = authService.registerDriver(request);
            return ResponseEntity.ok(ApiResponse.success("Driver registered successfully", driver));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Object>> login(@RequestBody LoginRequest request) {
        try {
            Object response = authService.login(request);
            return ResponseEntity.ok(ApiResponse.success("Login successful", response));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<String>> verifyOtp(@RequestParam String phone, @RequestParam String otp) {
        if (authService.verifyOtp(phone, otp)) {
            return ResponseEntity.ok(ApiResponse.success("OTP verified", "Login Success"));
        }
        return ResponseEntity.badRequest().body(ApiResponse.error("Invalid OTP"));
    }
}
