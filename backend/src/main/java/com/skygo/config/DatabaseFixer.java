package com.skygo.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Autowired;

@Component
public class DatabaseFixer implements CommandLineRunner {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) throws Exception {
        try {
            jdbcTemplate.execute("ALTER TABLE users ALTER COLUMN phone DROP NOT NULL");
            System.out.println("Successfully altered users table: phone column is now nullable.");
        } catch (Exception e) {
            System.out.println("Could not alter users table (might already be nullable): " + e.getMessage());
        }
    }
}
