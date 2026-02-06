package com.skygo.controller;

import com.skygo.model.Driver;
import com.skygo.model.User;
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
    public ResponseEntity<?> registerUser(@RequestBody RegisterUserRequest request) {
        try {
            User user = authService.registerUser(request);
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/driver/register")
    public ResponseEntity<?> registerDriver(@RequestBody RegisterDriverRequest request) {
        try {
            Driver driver = authService.registerDriver(request);
            return ResponseEntity.ok(driver);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            Object response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestParam String phone, @RequestParam String otp) {
        if (authService.verifyOtp(phone, otp)) {
            // Should return JWT token here
            return ResponseEntity.ok("Login Success");
        }
        return ResponseEntity.badRequest().body("Invalid OTP");
    }
}
