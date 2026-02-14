import type { ApiResponse, SpringPage } from '../interfaces/types';
import api from './api';

export const getOrders = async (page: number, size: number) => {
    const response = await api.get<ApiResponse<SpringPage<any>>>('/admin/orders', {
        params: { page, size }
    });
    return response.data;
};
