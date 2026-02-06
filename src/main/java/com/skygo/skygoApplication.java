package com.skygo;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@OpenAPIDefinition(info = @Info(title = "Ojek Online API", version = "1.0", description = "API for Ojek Online Backend"))
public class skygoApplication {

    public static void main(String[] args) {
        SpringApplication.run(skygoApplication.class, args);
    }

}
