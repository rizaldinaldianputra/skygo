import api from './api';
import { Driver, PaginatedResponse, ApiResponse } from '../interfaces/types';

export const getPendingDrivers = async (page: number, size: number) => {
    const response = await api.get<PaginatedResponse<Driver[]>>(`/drivers/pending/paginated`, {
        params: { page, size }
    });
    return response.data;
};

export const updateDriverStatus = async (id: number, status: 'APPROVED' | 'REJECTED') => {
    const response = await api.put<ApiResponse<Driver>>(`/drivers/${id}/status`, null, {
        params: { status }
    });
    return response.data;
};
