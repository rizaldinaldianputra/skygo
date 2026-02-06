import React, { useEffect, useState } from 'react';
import { Column } from '../components/GenericTable';
import { Driver } from '../interfaces/types';
import { MapPin } from 'lucide-react';

const Monitoring = () => {
    const [drivers, setDrivers] = useState<Driver[]>([]);
    // const [loading, setLoading] = useState(false); // Unused for now

    // Poll for online drivers every 5 seconds
    useEffect(() => {
        const fetchOnlineDrivers = async () => {
            try {
                // setLoading(true);
                // Mock data for now until backend endpoint is confirmed
                const mockDrivers: Driver[] = [
                    { id: 101, name: 'Budi Santoso', email: 'budi@skygo.com', phone: '08123', vehicleType: 'MOTOR', vehiclePlate: 'B 1234 CD', status: 'APPROVED', availability: 'ONLINE' },
                    { id: 102, name: 'Siti Aminah', email: 'siti@skygo.com', phone: '08124', vehicleType: 'CAR', vehiclePlate: 'B 5678 EF', status: 'APPROVED', availability: 'ON_TRIP' },
                ];

                setDrivers(mockDrivers);
            } catch (error) {
                console.error("Failed to fetch monitoring data", error);
            } finally {
                // setLoading(false);
            }
        };

        fetchOnlineDrivers();
        const interval = setInterval(fetchOnlineDrivers, 15000); // 15 seconds poll
        return () => clearInterval(interval);
    }, []);

    // Use Column to fix lint error about unused import if we were using it in a GenericTable
    // But here we are using a custom table layout. 
    // keeping the import if we switch back, or remove it.
    // The layout below is custom, not GenericTable.

    return (
        <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-6">Live Monitoring</h1>
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200 mb-6">
                        <h2 className="text-lg font-bold mb-4">Live Map</h2>
                        <div className="bg-slate-100 h-96 rounded-lg flex items-center justify-center text-gray-400">
                            {/* Map Component would go here */}
                            <p>Map Visualization Placeholder</p>
                        </div>
                    </div>
                </div>

                <div>
                    <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                        <div className="p-4 bg-gray-50 border-b border-gray-200">
                            <h3 className="font-bold text-gray-700">Online Drivers</h3>
                        </div>
                        <div className="max-h-[500px] overflow-y-auto">
                            <table className="w-full text-left text-sm">
                                <tbody className="divide-y divide-gray-100">
                                    {drivers.map(driver => (
                                        <tr key={driver.id} className="hover:bg-gray-50">
                                            <td className="p-3">
                                                <div className="font-medium text-gray-900">{driver.name}</div>
                                                <div className="text-xs text-gray-500">{driver.vehicleType} • {driver.vehiclePlate}</div>
                                            </td>
                                            <td className="p-3 text-right">
                                                <span className={`inline-block w-2 h-2 rounded-full ${driver.availability === 'ONLINE' ? 'bg-green-500' :
                                                        driver.availability === 'ON_TRIP' ? 'bg-blue-500' : 'bg-gray-500'
                                                    }`}></span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Monitoring;
