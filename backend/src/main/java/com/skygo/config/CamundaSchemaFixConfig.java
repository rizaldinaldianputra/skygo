package com.skygo.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Configuration
public class CamundaSchemaFixConfig {

    @Bean
    public CommandLineRunner fixCamundaSchema(JdbcTemplate jdbcTemplate) {
        return args -> {
            try {
                // Check if the column exists to avoid errors on repeated runs
                // This is a specific fix for the missing 'task_state_' column in Camunda 7.20+
                jdbcTemplate.execute("ALTER TABLE act_hi_taskinst ADD COLUMN IF NOT EXISTS task_state_ varchar(64);");
                System.out.println("✅ Successfully added 'task_state_' column to 'act_hi_taskinst' table.");
            } catch (Exception e) {
                System.err.println("⚠️ Error while attempting to add 'task_state_' column: " + e.getMessage());
                // Don't fail the startup, as it might already exist or be a different issue
            }
        };
    }
}
