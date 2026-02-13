package com.skygo.controller;

import com.skygo.dto.UserProfileResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.skygo.model.dto.ApiResponse;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/api/users")
@Slf4j
public class UserController {

    @org.springframework.beans.factory.annotation.Autowired
    private com.skygo.repository.UserRepository userRepository;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getMyProfile(@AuthenticationPrincipal Jwt jwt) {
        log.info("Fetching profile for user: {}", jwt.getSubject());

        UserProfileResponse profile = UserProfileResponse.builder()
                .id(jwt.getSubject())
                .username(jwt.getClaimAsString("preferred_username"))
                .email(jwt.getClaimAsString("email"))
                .firstName(jwt.getClaimAsString("given_name"))
                .lastName(jwt.getClaimAsString("family_name"))
                .build();

        return ResponseEntity.ok(ApiResponse.success("User profile fetched", profile));
    }

    @org.springframework.web.bind.annotation.PutMapping("/{id}/fcm-token")
    public ResponseEntity<ApiResponse<String>> updateFcmToken(
            @org.springframework.web.bind.annotation.PathVariable Long id,
            @org.springframework.web.bind.annotation.RequestParam String token) {
        try {
            com.skygo.model.User user = userRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            user.setFcmToken(token);
            userRepository.save(user);
            return ResponseEntity.ok(ApiResponse.success("FCM Token updated", "Success"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
