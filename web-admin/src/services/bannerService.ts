import type { ApiResponse, SpringPage } from '../interfaces/types';
import api from './api';

export const getBanners = async (page: number, size: number) => {
    const response = await api.get<ApiResponse<SpringPage<any>>>('/admin/banners', {
        params: { page, size }
    });
    return response.data;
};

export const createBanner = async (data: any) => {
    const response = await api.post<ApiResponse<any>>('/admin/banners', data);
    return response.data;
};

export const updateBanner = async (id: number, data: any) => {
    const response = await api.put<ApiResponse<any>>(`/admin/banners/${id}`, data);
    return response.data;
};

export const deleteBanner = async (id: number) => {
    const response = await api.delete<ApiResponse<void>>(`/admin/banners/${id}`);
    return response.data;
};

export const uploadImage = async (file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await api.post<ApiResponse<string>>('/admin/upload', formData);
    return response.data;
};
