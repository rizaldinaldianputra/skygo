package com.skygo.model.dto;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class PaginatedResponse<T> extends ApiResponse<T> {
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;

    public PaginatedResponse(boolean status, String message, T data, int page, int size, long totalElements,
            int totalPages) {
        super(status, message, data);
        this.page = page;
        this.size = size;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
    }
}
