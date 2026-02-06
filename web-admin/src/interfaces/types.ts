export interface ApiResponse<T> {
    status: boolean;
    message: string;
    data: T;
}

export interface PaginatedResponse<T> extends ApiResponse<T> {
    page: number;
    size: number;
    totalElements: number;
    totalPages: number;
}

export interface User {
    id: string; // or number, depends on backend
    username: string;
    email: string;
    firstName?: string;
    lastName?: string;
    role: string;
}

export interface Driver {
    id: number;
    name: string;
    email: string;
    phone: string;
    vehicleType: string;
    vehiclePlate: string;
    status: 'PENDING' | 'APPROVED' | 'REJECTED';
    availability: 'ONLINE' | 'OFFLINE' | 'ON_TRIP';
    ktpUrl?: string;
    simUrl?: string;
    photoUrl?: string;
}

export interface LoginResponse {
    token: string;
    // add other fields if any
}
