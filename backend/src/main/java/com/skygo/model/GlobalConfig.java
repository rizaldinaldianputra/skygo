package com.skygo.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Entity
@Table(name = "global_configs")
@AllArgsConstructor
@NoArgsConstructor
public class GlobalConfig {

    @Id
    private String configKey;
    private String configValue;
}
