import { Car, Users, ShoppingBag, Activity } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Legend } from 'recharts';

interface DashboardStats {
    totalDrivers: number;
    activeDrivers: number;
    onlineDrivers: number;
    totalUsers: number;
    totalOrders: number;
}

const Dashboard = () => {



    // Mock data for charts (Backend chart API pending)
    const data = [
        { name: 'Mon', orders: 12, drivers: 5 },
        { name: 'Tue', orders: 19, drivers: 10 },
        { name: 'Wed', orders: 15, drivers: 8 },
        { name: 'Thu', orders: 25, drivers: 15 },
        { name: 'Fri', orders: 32, drivers: 20 },
        { name: 'Sat', orders: 45, drivers: 25 },
        { name: 'Sun', orders: 38, drivers: 22 },
    ];

    const statCards = [
        { label: 'Total Drivers', value: 200, icon: <Car />, color: 'text-blue-500', bg: 'bg-blue-100' },
        { label: 'Online Drivers', value: 201, icon: <Activity />, color: 'text-green-500', bg: 'bg-green-100' },
        { label: 'Total Users', value: 202, icon: <Users />, color: 'text-purple-500', bg: 'bg-purple-100' },
        { label: 'Total Orders', value: 203, icon: <ShoppingBag />, color: 'text-orange-500', bg: 'bg-orange-100' },
    ];

    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold text-gray-800">Dashboard Overiew</h1>

            {/* 4 Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {statCards.map((stat, index) => (
                    <div key={index} className="bg-white p-6 rounded-xl shadow-sm border border-gray-200 flex items-center justify-between">
                        <div>
                            <p className="text-sm font-medium text-gray-500 uppercase">{stat.label}</p>
                            <p className="text-3xl font-bold text-gray-800 mt-2">{stat.value}</p>
                        </div>
                        <div className={`p-4 rounded-full ${stat.bg} ${stat.color}`}>
                            {stat.icon}
                        </div>
                    </div>
                ))}
            </div>

            {/* Charts Section */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Orders Chart */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
                    <h3 className="text-lg font-bold text-gray-800 mb-4">Orders Overview</h3>
                    <div className="h-80">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={data}>
                                <CartesianGrid strokeDasharray="3 3" />
                                <XAxis dataKey="name" />
                                <YAxis />
                                <Tooltip />
                                <Area type="monotone" dataKey="orders" stroke="#00BFFF" fill="#87CEEB" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Driver Activity Chart */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
                    <h3 className="text-lg font-bold text-gray-800 mb-4">Driver Activity</h3>
                    <div className="h-80">
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={data}>
                                <CartesianGrid strokeDasharray="3 3" />
                                <XAxis dataKey="name" />
                                <YAxis />
                                <Tooltip />
                                <Legend />
                                <Bar dataKey="drivers" fill="#00008B" name="Active Drivers" />
                            </BarChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
