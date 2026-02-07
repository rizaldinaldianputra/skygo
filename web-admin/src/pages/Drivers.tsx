import React, { useEffect, useState } from 'react';
import { getPendingDrivers, updateDriverStatus } from '../services/driverService';
import { Check, X } from 'lucide-react';
import type { Column } from '../components/GenericTable';
import type { Driver } from '../interfaces/types';
import GenericTable from '../components/GenericTable';

const Drivers = () => {
    const [drivers, setDrivers] = useState<Driver[]>([]);
    const [loading, setLoading] = useState(false);
    const [totalItems, setTotalItems] = useState(0);
    const [page, setPage] = useState(0);
    const [pageSize] = useState(10);

    const fetchDrivers = async (p: number) => {
        setLoading(true);
        try {
            const response = await getPendingDrivers(p, pageSize);
            if (response.status) {
                setDrivers(response.data);
                setTotalItems(response.totalElements);
            }
        } catch (error) {
            console.error('Failed to fetch drivers', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchDrivers(page);
    }, [page]);

    const handleStatusUpdate = async (id: number, status: 'APPROVED' | 'REJECTED') => {
        if (!confirm(`Are you sure you want to ${status} this driver?`)) return;
        try {
            await updateDriverStatus(id, status);
            fetchDrivers(page); // Refresh list
        } catch (error) {
            alert('Failed to update status');
        }
    };

    const columns: Column<Driver>[] = [
        { header: 'ID', accessor: 'id', className: 'w-16' },
        { header: 'Name', accessor: 'name' },
        { header: 'Email', accessor: 'email' },
        { header: 'Phone', accessor: 'phone' },
        { header: 'Vehicle', accessor: (driver) => `${driver.vehicleType} - ${driver.vehiclePlate}` },
        {
            header: 'Status',
            accessor: (driver) => (
                <span className="px-2 py-1 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-800">
                    {driver.status}
                </span>
            )
        },
        {
            header: 'Actions',
            accessor: (driver) => (
                <div className="flex space-x-2">
                    <button
                        onClick={() => handleStatusUpdate(driver.id, 'APPROVED')}
                        className="p-1 bg-green-100 text-green-700 rounded hover:bg-green-200"
                        title="Approve"
                    >
                        <Check size={16} />
                    </button>
                    <button
                        onClick={() => handleStatusUpdate(driver.id, 'REJECTED')}
                        className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                        title="Reject"
                    >
                        <X size={16} />
                    </button>
                </div>
            )
        }
    ];

    return (
        <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-6">Pending Drivers</h1>
            <GenericTable
                data={drivers}
                columns={columns}
                totalItems={totalItems}
                page={page}
                pageSize={pageSize}
                onPageChange={setPage}
                onSearch={() => { }} // Search not implemented in backend pagination yet
                loading={loading}
            />
        </div>
    );
};

export default Drivers;
