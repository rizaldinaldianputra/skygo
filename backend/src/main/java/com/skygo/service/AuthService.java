package com.skygo.service;

import com.skygo.model.Driver;
import com.skygo.model.User;
import com.skygo.model.dto.RegisterDriverRequest;
import com.skygo.model.dto.RegisterUserRequest;
import com.skygo.repository.DriverRepository;
import com.skygo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private MinioService minioService;

    @Autowired
    private JwtService jwtService;

    public User registerUser(RegisterUserRequest request) {
        // Phone check removed as it is optional now

        if (request.getEmail() != null && userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered");
        }

        User user = new User();
        user.setName(request.getName());
        // user.setPhone(request.getPhone()); // Removed as requested
        user.setEmail(request.getEmail());
        if (request.getPassword() != null) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        return userRepository.save(user);
    }

    public Driver registerDriver(RegisterDriverRequest request,
            org.springframework.web.multipart.MultipartFile ktpImage,
            org.springframework.web.multipart.MultipartFile simImage) {

        if (request.getEmail() != null && driverRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered");
        }

        String ktpUrl = minioService.uploadFile(ktpImage, "driver/ktp");
        String simUrl = minioService.uploadFile(simImage, "driver/sim");

        Driver driver = new Driver();
        driver.setName(request.getName());
        driver.setPhone(request.getPhone());
        driver.setEmail(request.getEmail());
        if (request.getPassword() != null) {
            driver.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        driver.setVehicleType(request.getVehicleType());
        driver.setVehiclePlate(request.getVehiclePlate());

        driver.setKtpNumber(request.getKtpNumber());
        driver.setSimNumber(request.getSimNumber());
        driver.setKtpUrl(ktpUrl);
        driver.setSimUrl(simUrl);

        return driverRepository.save(driver);
    }

    public String generateOtp(String phone) {
        // Mock OTP for now
        return "123456";
    }

    public boolean verifyOtp(String phone, String otp) {
        // Mock Verification
        return "123456".equals(otp);
    }

    public Optional<User> findUserByPhone(String phone) {
        return userRepository.findByPhone(phone);
    }

    public Optional<Driver> findDriverByPhone(String phone) {
        return driverRepository.findByPhone(phone);
    }

    public Map<String, Object> login(com.skygo.model.dto.LoginRequest request) {
        if (request.getEmail() == null || request.getPassword() == null) {
            throw new RuntimeException("Email and Password are required");
        }

        // 1. Try Email/Password for User
        Optional<User> user = userRepository.findByEmail(request.getEmail());
        if (user.isPresent() && passwordEncoder.matches(request.getPassword(), user.get().getPassword())) {
            String token = jwtService.generateToken(user.get().getEmail(), Map.of("role", user.get().getRole()));
            return Map.of(
                    "token", token,
                    "id", user.get().getId(),
                    "name", user.get().getName(),
                    "role", "USER");
        }

        // 2. Try Email/Password for Driver
        Optional<Driver> driver = driverRepository.findByEmail(request.getEmail());
        if (driver.isPresent() && passwordEncoder.matches(request.getPassword(), driver.get().getPassword())) {
            String token = jwtService.generateToken(driver.get().getEmail(), Map.of("role", "DRIVER"));
            return Map.of(
                    "token", token,
                    "id", driver.get().getId(),
                    "name", driver.get().getName(),
                    "role", "DRIVER");
        }

        throw new RuntimeException("Invalid email or password");
    }

    public User syncUser(String email, String name) {
        Optional<User> existingUser = userRepository.findByEmail(email);
        if (existingUser.isPresent()) {
            return existingUser.get();
        }

        User newUser = new User();
        newUser.setEmail(email);
        newUser.setName(name != null ? name : "SkyGo User");
        newUser.setPassword(""); // No password for social login users
        newUser.setRole(com.skygo.model.Role.USER);

        return userRepository.save(newUser);
    }
}
