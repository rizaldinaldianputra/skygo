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

    @PostMapping(value = "/driver/register", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Driver>> registerDriver(
            @RequestPart("data") RegisterDriverRequest request,
            @RequestPart("ktpImage") org.springframework.web.multipart.MultipartFile ktpImage,
            @RequestPart("simImage") org.springframework.web.multipart.MultipartFile simImage) {
        try {
            Driver driver = authService.registerDriver(request, ktpImage, simImage);
            return ResponseEntity.ok(ApiResponse.success("Driver registered successfully", driver));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Object>> login(@RequestBody LoginRequest request) {
        try {
            String token = authService.login(request);
            return ResponseEntity.ok(ApiResponse.success("Login successful", java.util.Map.of("token", token)));
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

    @PostMapping("/google-sync")
    public ResponseEntity<ApiResponse<User>> syncGoogleUser(
            @org.springframework.security.core.annotation.AuthenticationPrincipal org.springframework.security.oauth2.jwt.Jwt jwt) {
        try {
            String email = jwt.getClaimAsString("email");
            String name = jwt.getClaimAsString("name");

            if (email == null) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Email claim missing in token"));
            }

            User user = authService.syncUser(email, name);
            return ResponseEntity.ok(ApiResponse.success("User synced successfully", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Sync failed: " + e.getMessage()));
        }
    }
}
