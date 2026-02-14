import { useEffect, useState } from 'react';
import { Car, Users, ShoppingBag, Activity, Newspaper, Image, Tags, CreditCard, Ticket } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Legend, PieChart, Pie, Cell } from 'recharts';
import api from '../services/api';

interface DashboardStats {
    totalDrivers: number;
    totalUsers: number;
    totalOrders: number;
    totalDiscounts: number;
    totalBanners: number;
    totalNews: number;
    totalPromos: number;
    totalPaymentMethods: number;
    onlineDrivers: number;
    onTripDrivers: number;
    weeklyOrders: { name: string; date: string; orders: number }[];
}

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#6366f1', '#ec4899'];

const Dashboard = () => {
    const [stats, setStats] = useState<DashboardStats | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchStats();
    }, []);

    const fetchStats = async () => {
        try {
            const res = await api.get('/admin/dashboard-stats');
            if (res.data.status) {
                setStats(res.data.data);
            }
        } catch (error) {
            console.error('Failed to fetch dashboard stats', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="flex items-center gap-3">
                    <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                    <span className="text-gray-500">Loading dashboard...</span>
                </div>
            </div>
        );
    }

    const statCards = [
        { label: 'Total Drivers', value: stats?.totalDrivers ?? 0, icon: <Car size={22} />, color: 'text-blue-600', bg: 'bg-blue-50', border: 'border-blue-200' },
        { label: 'Online Drivers', value: stats?.onlineDrivers ?? 0, icon: <Activity size={22} />, color: 'text-green-600', bg: 'bg-green-50', border: 'border-green-200' },
        { label: 'Total Users', value: stats?.totalUsers ?? 0, icon: <Users size={22} />, color: 'text-purple-600', bg: 'bg-purple-50', border: 'border-purple-200' },
        { label: 'Total Orders', value: stats?.totalOrders ?? 0, icon: <ShoppingBag size={22} />, color: 'text-orange-600', bg: 'bg-orange-50', border: 'border-orange-200' },
    ];



    // Pie chart data for driver status
    const driverStatusData = [
        { name: 'Online', value: stats?.onlineDrivers ?? 0 },
        { name: 'On Trip', value: stats?.onTripDrivers ?? 0 },
        { name: 'Offline', value: Math.max(0, (stats?.totalDrivers ?? 0) - (stats?.onlineDrivers ?? 0) - (stats?.onTripDrivers ?? 0)) },
    ].filter(d => d.value > 0);

    const PIE_COLORS = ['#10b981', '#3b82f6', '#94a3b8'];

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-gray-800">Dashboard Overview</h1>
                <p className="text-sm text-gray-500 mt-1">Ringkasan data SkyGo</p>
            </div>

            {/* Main Stat Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
                {statCards.map((stat, index) => (
                    <div key={index} className={`bg-white p-5 rounded-xl shadow-sm border ${stat.border} flex items-center justify-between hover:shadow-md transition-shadow`}>
                        <div>
                            <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{stat.label}</p>
                            <p className="text-3xl font-bold text-gray-800 mt-1">{stat.value.toLocaleString()}</p>
                        </div>
                        <div className={`p-3.5 rounded-xl ${stat.bg} ${stat.color}`}>
                            {stat.icon}
                        </div>
                    </div>
                ))}
            </div>

       

            {/* Charts Section */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Orders Area Chart - 2/3 width */}
                <div className="lg:col-span-2 bg-white p-6 rounded-xl shadow-sm border border-gray-200">
                    <h3 className="text-lg font-bold text-gray-800 mb-1">Orders (Last 7 Days)</h3>
                    <p className="text-xs text-gray-400 mb-4">Jumlah order per hari</p>
                    <div className="h-72">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={stats?.weeklyOrders || []}>
                                <defs>
                                    <linearGradient id="colorOrders" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3} />
                                        <stop offset="95%" stopColor="#3b82f6" stopOpacity={0} />
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                                <XAxis dataKey="name" tick={{ fontSize: 12 }} stroke="#94a3b8" />
                                <YAxis tick={{ fontSize: 12 }} stroke="#94a3b8" allowDecimals={false} />
                                <Tooltip
                                    contentStyle={{ borderRadius: '8px', border: '1px solid #e2e8f0', fontSize: '13px' }}
                                />
                                <Area type="monotone" dataKey="orders" stroke="#3b82f6" strokeWidth={2.5} fill="url(#colorOrders)" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Driver Status Pie Chart - 1/3 width */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
                    <h3 className="text-lg font-bold text-gray-800 mb-1">Driver Status</h3>
                    <p className="text-xs text-gray-400 mb-4">Status driver saat ini</p>
                    <div className="h-56">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={driverStatusData}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={55}
                                    outerRadius={80}
                                    paddingAngle={5}
                                    dataKey="value"
                                >
                                    {driverStatusData.map((_entry, index) => (
                                        <Cell key={`cell-${index}`} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                                    ))}
                                </Pie>
                                <Tooltip contentStyle={{ borderRadius: '8px', border: '1px solid #e2e8f0', fontSize: '13px' }} />
                            </PieChart>
                        </ResponsiveContainer>
                    </div>
                    {/* Legend */}
                    <div className="flex flex-wrap justify-center gap-4 mt-2">
                        {driverStatusData.map((entry, index) => (
                            <div key={entry.name} className="flex items-center gap-1.5 text-xs text-gray-600">
                                <span className="w-3 h-3 rounded-full" style={{ backgroundColor: PIE_COLORS[index] }}></span>
                                {entry.name}: <span className="font-semibold">{entry.value}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            {/* Bar Chart for weekly comparison */}
            <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
                <h3 className="text-lg font-bold text-gray-800 mb-1">Weekly Order Comparison</h3>
                <p className="text-xs text-gray-400 mb-4">Perbandingan jumlah order harian</p>
                <div className="h-72">
                    <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={stats?.weeklyOrders || []}>
                            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                            <XAxis dataKey="name" tick={{ fontSize: 12 }} stroke="#94a3b8" />
                            <YAxis tick={{ fontSize: 12 }} stroke="#94a3b8" allowDecimals={false} />
                            <Tooltip contentStyle={{ borderRadius: '8px', border: '1px solid #e2e8f0', fontSize: '13px' }} />
                            <Legend />
                            <Bar dataKey="orders" fill="#6366f1" name="Orders" radius={[4, 4, 0, 0]} />
                        </BarChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
