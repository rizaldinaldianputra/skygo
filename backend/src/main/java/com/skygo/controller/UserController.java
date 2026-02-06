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
}
