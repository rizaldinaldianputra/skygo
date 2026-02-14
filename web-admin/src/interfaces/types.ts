export interface ApiResponse<T> {
    status: boolean;
    message: string;
    data: T;
}

/** Spring Page<T> format — the standard pagination wrapper from Spring Data */
export interface SpringPage<T> {
    content: T[];
    totalElements: number;
    totalPages: number;
    size: number;
    number: number;
    first: boolean;
    last: boolean;
    empty: boolean;
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
