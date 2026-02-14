import type { ApiResponse, SpringPage } from '../interfaces/types';
import api from './api';

export const getDiscounts = async (page: number, size: number) => {
    const response = await api.get<ApiResponse<SpringPage<any>>>('/admin/discounts', {
        params: { page, size }
    });
    return response.data;
};

export const createDiscount = async (data: any) => {
    const response = await api.post<ApiResponse<any>>('/discounts', data);
    return response.data;
};

export const updateDiscount = async (id: number, data: any) => {
    const response = await api.put<ApiResponse<any>>(`/discounts/${id}`, data);
    return response.data;
};

export const deleteDiscount = async (id: number) => {
    const response = await api.delete<ApiResponse<void>>(`/discounts/${id}`);
    return response.data;
};
