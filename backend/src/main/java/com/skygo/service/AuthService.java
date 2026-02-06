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

import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DriverRepository driverRepository;

    public User registerUser(RegisterUserRequest request) {
        if (userRepository.findByPhone(request.getPhone()).isPresent()) {
            throw new RuntimeException("Phone already registered");
        }
        if (request.getEmail() != null && userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered");
        }

        User user = new User();
        user.setName(request.getName());
        user.setPhone(request.getPhone());
        user.setEmail(request.getEmail());
        if (request.getPassword() != null) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        return userRepository.save(user);
    }

    public Driver registerDriver(RegisterDriverRequest request) {
        if (driverRepository.findByPhone(request.getPhone()).isPresent()) {
            throw new RuntimeException("Phone already registered");
        }
        if (request.getEmail() != null && driverRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already registered");
        }

        Driver driver = new Driver();
        driver.setName(request.getName());
        driver.setPhone(request.getPhone());
        driver.setEmail(request.getEmail());
        if (request.getPassword() != null) {
            driver.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        driver.setVehicleType(request.getVehicleType());
        driver.setVehiclePlate(request.getVehiclePlate());
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

    public Object login(com.skygo.model.dto.LoginRequest request) {
        // 1. Try Email/Password for User
        if (request.getEmail() != null && request.getPassword() != null) {
            Optional<User> user = userRepository.findByEmail(request.getEmail());
            if (user.isPresent() && passwordEncoder.matches(request.getPassword(), user.get().getPassword())) {
                return user.get();
            }
            // 2. Try Email/Password for Driver
            Optional<Driver> driver = driverRepository.findByEmail(request.getEmail());
            if (driver.isPresent() && passwordEncoder.matches(request.getPassword(), driver.get().getPassword())) {
                return driver.get();
            }
            throw new RuntimeException("Invalid email or password");
        }

        // 3. Fallback to Phone/OTP check (Check existance only)
        if (request.getPhone() != null) {
            if (userRepository.findByPhone(request.getPhone()).isPresent()) {
                return "OTP Sent to User";
            }
            if (driverRepository.findByPhone(request.getPhone()).isPresent()) {
                return "OTP Sent to Driver";
            }
        }

        throw new RuntimeException("User/Driver not found");
    }
}
