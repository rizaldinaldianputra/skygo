package com.skygo.controller;

import com.skygo.model.dto.ApiResponse;
import com.skygo.service.MinioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/files")
public class FileController {

    @Autowired
    private MinioService minioService;

    @PostMapping("/upload")
    public ResponseEntity<ApiResponse<String>> uploadFile(@RequestParam("file") MultipartFile file) {
        String url = minioService.uploadFile(file, "payment-proofs");
        return ResponseEntity.ok(ApiResponse.success("File uploaded successfully", url));
    }
}
