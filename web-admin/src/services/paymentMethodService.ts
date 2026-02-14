import type { ApiResponse, SpringPage } from '../interfaces/types';
import api from './api';

export const getPaymentMethods = async (page: number, size: number) => {
    const response = await api.get<ApiResponse<SpringPage<any>>>('/admin/payment-methods', {
        params: { page, size }
    });
    return response.data;
};

export const createPaymentMethod = async (data: any) => {
    const response = await api.post<ApiResponse<any>>('/admin/payment-methods', data);
    return response.data;
};

export const updatePaymentMethod = async (id: number, data: any) => {
    const response = await api.put<ApiResponse<any>>(`/admin/payment-methods/${id}`, data);
    return response.data;
};

export const deletePaymentMethod = async (id: number) => {
    const response = await api.delete<ApiResponse<void>>(`/admin/payment-methods/${id}`);
    return response.data;
};
