package com.skygo.service;

import com.skygo.model.Role;
import com.skygo.model.User;
import com.skygo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class AdminSeeder implements ApplicationRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        if (userRepository.findByEmail("admin").isEmpty() && userRepository.findByPhone("admin").isEmpty()) {
            User admin = new User();
            admin.setName("Super Admin");
            admin.setEmail("admin");
            admin.setPhone("admin");
            admin.setPassword(passwordEncoder.encode("admin"));
            admin.setRole(Role.SUPER_ADMIN);

            userRepository.save(admin);
            System.out.println("Default Admin user initialized successfully.");
        }
    }
}
