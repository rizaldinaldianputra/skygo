import type { ApiResponse, SpringPage } from '../interfaces/types';
import api from './api';

export const getNews = async (page: number, size: number) => {
    const response = await api.get<ApiResponse<SpringPage<any>>>('/admin/news', {
        params: { page, size }
    });
    return response.data;
};

export const createNews = async (data: any) => {
    const response = await api.post<ApiResponse<any>>('/admin/news', data);
    return response.data;
};

export const updateNews = async (id: number, data: any) => {
    const response = await api.put<ApiResponse<any>>(`/admin/news/${id}`, data);
    return response.data;
};

export const deleteNews = async (id: number) => {
    const response = await api.delete<ApiResponse<void>>(`/admin/news/${id}`);
    return response.data;
};
