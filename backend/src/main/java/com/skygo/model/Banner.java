package com.skygo.model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "banners")
public class Banner {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String imageUrl;
    private String actionUrl; // Deep link or web link

    private int displayOrder;
    private boolean active = true;
}
