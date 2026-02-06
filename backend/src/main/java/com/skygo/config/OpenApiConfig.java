package com.skygo.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI ojekOrnlneOpenAPI() {
        return new OpenAPI()
                .info(new Info().title("Ojek Online API")
                        .description("API Documentation for Ojek Online System")
                        .version("v0.0.1"));
    }
}
