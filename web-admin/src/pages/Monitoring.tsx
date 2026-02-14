import { useEffect, useState, useRef, useCallback } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import api from '../services/api';
import { RefreshCw, Car, Bike, MapPin, Wifi, Radio } from 'lucide-react';
import SockJS from 'sockjs-client';
import { Client } from '@stomp/stompjs';

// Fix default marker icons for Leaflet + bundler
delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

// Custom icons for different vehicle types
const motorIcon = L.divIcon({
    html: `<div style="background: linear-gradient(135deg, #2563eb, #38bdf8); width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.3);">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><circle cx="18" cy="17" r="3"/><circle cx="6" cy="17" r="3"/><path d="M6 17V5h4l4 4h4v4"/></svg>
    </div>`,
    className: '',
    iconSize: [32, 32],
    iconAnchor: [16, 16],
});

const carIcon = L.divIcon({
    html: `<div style="background: linear-gradient(135deg, #059669, #34d399); width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.3);">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9L18 10l-3-5H9L6 10l-2.5 1.1C2.7 11.3 2 12.1 2 13v3c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/></svg>
    </div>`,
    className: '',
    iconSize: [32, 32],
    iconAnchor: [16, 16],
});

interface OnlineDriver {
    id: number;
    name: string;
    phone: string;
    vehicleType: string;
    vehiclePlate: string;
    availability: string;
    rating: number;
    lat?: number;
    lng?: number;
}

// Component to auto-fit map bounds
const FitBounds = ({ drivers }: { drivers: OnlineDriver[] }) => {
    const map = useMap();
    useEffect(() => {
        const driversWithLocation = drivers.filter(d => d.lat && d.lng);
        if (driversWithLocation.length > 0) {
            const bounds = L.latLngBounds(
                driversWithLocation.map(d => [d.lat!, d.lng!] as [number, number])
            );
            map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 });
        }
    }, [drivers, map]);
    return null;
};

const Monitoring = () => {
    const [drivers, setDrivers] = useState<OnlineDriver[]>([]);
    const [loading, setLoading] = useState(true);
    const [lastUpdate, setLastUpdate] = useState<Date>(new Date());
    const [selectedDriver, setSelectedDriver] = useState<OnlineDriver | null>(null);
    const [wsConnected, setWsConnected] = useState(false);
    const stompClientRef = useRef<Client | null>(null);
    const refreshIntervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

    // Fetch full driver list via REST (for initial load + periodic refresh)
    const fetchOnlineDrivers = useCallback(async () => {
        try {
            const res = await api.get('/admin/online-drivers');
            if (res.data.status) {
                setDrivers(res.data.data || []);
            }
            setLastUpdate(new Date());
        } catch (error) {
            console.error('Failed to fetch online drivers', error);
        } finally {
            setLoading(false);
        }
    }, []);

    // Connect to WebSocket for real-time location updates
    useEffect(() => {
        // Initial fetch
        fetchOnlineDrivers();

        // Build WebSocket URL from API base URL
        const apiBase = api.defaults.baseURL || '';
        const url = new URL(apiBase);
        const sockJsUrl = `${url.protocol}//${url.host}/ws-ojek`;

        console.log('[Monitoring] Connecting WebSocket to', sockJsUrl);

        const client = new Client({
            webSocketFactory: () => new SockJS(sockJsUrl),
            reconnectDelay: 5000,
            heartbeatIncoming: 10000,
            heartbeatOutgoing: 10000,
            onConnect: () => {
                console.log('[Monitoring] WebSocket connected!');
                setWsConnected(true);

                // Subscribe to all driver location updates
                client.subscribe('/topic/drivers', (message) => {
                    // Message format: "driverId:lat,lng"
                    const body = message.body;
                    const parts = body.split(':');
                    if (parts.length === 2) {
                        const driverId = parseInt(parts[0]);
                        const coords = parts[1].split(',');
                        if (coords.length === 2) {
                            const lat = parseFloat(coords[0]);
                            const lng = parseFloat(coords[1]);

                            // Update driver location in state
                            setDrivers(prev => {
                                const existing = prev.find(d => d.id === driverId);
                                if (existing) {
                                    // Update existing driver's location
                                    return prev.map(d =>
                                        d.id === driverId ? { ...d, lat, lng } : d
                                    );
                                }
                                // Unknown driver — will be picked up on next REST refresh
                                return prev;
                            });
                            setLastUpdate(new Date());
                        }
                    }
                });
            },
            onDisconnect: () => {
                console.log('[Monitoring] WebSocket disconnected');
                setWsConnected(false);
            },
            onStompError: (frame) => {
                console.error('[Monitoring] STOMP error:', frame.body);
                setWsConnected(false);
            },
            onWebSocketError: (error) => {
                console.error('[Monitoring] WebSocket error:', error);
                setWsConnected(false);
            },
        });

        client.activate();
        stompClientRef.current = client;

        // Periodic REST refresh every 30s for driver join/leave
        refreshIntervalRef.current = setInterval(fetchOnlineDrivers, 30000);

        return () => {
            if (stompClientRef.current) {
                stompClientRef.current.deactivate();
            }
            if (refreshIntervalRef.current) {
                clearInterval(refreshIntervalRef.current);
            }
        };
    }, [fetchOnlineDrivers]);

    const driversWithLocation = drivers.filter(d => d.lat && d.lng);
    const onlineCount = drivers.filter(d => d.availability === 'ONLINE').length;
    const onTripCount = drivers.filter(d => d.availability === 'ON_TRIP').length;

    return (
        <div>
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Live Monitoring</h1>
                    <p className="text-sm text-gray-500 mt-1">
                        Terakhir update: {lastUpdate.toLocaleTimeString('id-ID')}
                    </p>
                </div>
                <div className="flex items-center gap-3">
                    {/* WebSocket status indicator */}
                    <div className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium ${wsConnected
                        ? 'bg-green-50 text-green-700 border border-green-200'
                        : 'bg-red-50 text-red-700 border border-red-200'
                        }`}>
                        <Radio size={12} className={wsConnected ? 'text-green-500 animate-pulse' : 'text-red-500'} />
                        {wsConnected ? 'Real-time' : 'Disconnected'}
                    </div>
                    <button
                        onClick={fetchOnlineDrivers}
                        className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-xl hover:bg-blue-700 transition-colors shadow-sm text-sm font-medium"
                    >
                        <RefreshCw size={16} className={loading ? 'animate-spin' : ''} />
                        Refresh
                    </button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                            <Wifi size={20} className="text-blue-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold text-gray-800">{drivers.length}</p>
                            <p className="text-xs text-gray-500">Total Aktif</p>
                        </div>
                    </div>
                </div>
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center">
                            <MapPin size={20} className="text-green-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold text-gray-800">{onlineCount}</p>
                            <p className="text-xs text-gray-500">Online (Standby)</p>
                        </div>
                    </div>
                </div>
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center">
                            <Car size={20} className="text-purple-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold text-gray-800">{onTripCount}</p>
                            <p className="text-xs text-gray-500">Dalam Perjalanan</p>
                        </div>
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Map - 2/3 width */}
                <div className="lg:col-span-2">
                    <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                        <div className="p-4 border-b border-gray-100 flex items-center justify-between">
                            <h2 className="text-sm font-semibold text-gray-700">Live Map</h2>
                            <span className="text-xs text-gray-400">{driversWithLocation.length} drivers on map</span>
                        </div>
                        <div style={{ height: '500px' }}>
                            <MapContainer
                                center={[-6.2088, 106.8456]}
                                zoom={12}
                                style={{ height: '100%', width: '100%' }}
                                zoomControl={true}
                            >
                                <TileLayer
                                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                                />
                                {drivers.length > 0 && <FitBounds drivers={drivers} />}
                                {driversWithLocation.map((driver) => (
                                    <Marker
                                        key={driver.id}
                                        position={[driver.lat!, driver.lng!]}
                                        icon={driver.vehicleType === 'CAR' ? carIcon : motorIcon}
                                        eventHandlers={{
                                            click: () => setSelectedDriver(driver),
                                        }}
                                    >
                                        <Popup>
                                            <div className="text-sm">
                                                <p className="font-bold">{driver.name}</p>
                                                <p className="text-gray-500">{driver.vehicleType} • {driver.vehiclePlate}</p>
                                                <p className="text-gray-500">Rating: ⭐{driver.rating?.toFixed(1)}</p>
                                                <p className={`font-medium ${driver.availability === 'ONLINE' ? 'text-green-600' : 'text-blue-600'}`}>
                                                    {driver.availability === 'ONLINE' ? '🟢 Online' : '🔵 Dalam Perjalanan'}
                                                </p>
                                            </div>
                                        </Popup>
                                    </Marker>
                                ))}
                            </MapContainer>
                        </div>
                    </div>
                </div>

                {/* Driver List - 1/3 width */}
                <div>
                    <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                        <div className="p-4 bg-gray-50 border-b border-gray-200">
                            <h3 className="font-semibold text-gray-700 text-sm">Driver Aktif</h3>
                        </div>
                        <div className="max-h-[500px] overflow-y-auto divide-y divide-gray-100">
                            {drivers.length === 0 ? (
                                <div className="p-8 text-center text-gray-400 text-sm">
                                    Tidak ada driver aktif saat ini
                                </div>
                            ) : (
                                drivers.map((driver) => (
                                    <div
                                        key={driver.id}
                                        className={`p-3 hover:bg-gray-50 cursor-pointer transition-colors ${selectedDriver?.id === driver.id ? 'bg-blue-50 border-l-2 border-l-blue-500' : ''
                                            }`}
                                        onClick={() => setSelectedDriver(driver)}
                                    >
                                        <div className="flex items-center gap-3">
                                            <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${driver.vehicleType === 'CAR' ? 'bg-green-50' : 'bg-blue-50'
                                                }`}>
                                                {driver.vehicleType === 'CAR' ?
                                                    <Car size={16} className="text-green-600" /> :
                                                    <Bike size={16} className="text-blue-600" />
                                                }
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <p className="font-medium text-gray-900 text-sm truncate">{driver.name}</p>
                                                <p className="text-xs text-gray-500">{driver.vehiclePlate}</p>
                                            </div>
                                            <div className="flex flex-col items-end">
                                                <span className={`inline-block w-2.5 h-2.5 rounded-full ${driver.availability === 'ONLINE' ? 'bg-green-500' : 'bg-blue-500'
                                                    }`}></span>
                                                <span className="text-[10px] text-gray-400 mt-0.5">
                                                    {driver.availability === 'ONLINE' ? 'Online' : 'Trip'}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Monitoring;
