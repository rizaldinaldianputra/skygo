import type { ApiResponse, SpringPage } from '../interfaces/types';
import api from './api';

export const getPromos = async (page: number, size: number) => {
    const response = await api.get<ApiResponse<SpringPage<any>>>('/admin/promos', {
        params: { page, size }
    });
    return response.data;
};

export const createPromo = async (data: any) => {
    const response = await api.post<ApiResponse<any>>('/admin/promos', data);
    return response.data;
};

export const updatePromo = async (id: number, data: any) => {
    const response = await api.put<ApiResponse<any>>(`/admin/promos/${id}`, data);
    return response.data;
};

export const deletePromo = async (id: number) => {
    const response = await api.delete<ApiResponse<void>>(`/admin/promos/${id}`);
    return response.data;
};
