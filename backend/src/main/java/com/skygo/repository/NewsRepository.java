package com.skygo.repository;

import com.skygo.model.News;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NewsRepository extends JpaRepository<News, Long> {
    java.util.List<News> findAllByActiveTrueOrderByPublishedAtDesc();
}
