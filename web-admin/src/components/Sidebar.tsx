import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Car, Users, LogOut } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';

const Sidebar = () => {
    const { logout } = useAuth();

    const navItems = [
        { name: 'Dashboard', path: '/', icon: <LayoutDashboard size={20} /> },
        { name: 'Monitoring', path: '/monitoring', icon: <Car size={20} /> },
        { name: 'Drivers', path: '/drivers', icon: <Users size={20} /> },
        { name: 'Users', path: '/users', icon: <Users size={20} /> },
        { name: 'Promos', path: '/promos', icon: <LayoutDashboard size={20} /> },
        { name: 'Banners', path: '/banners', icon: <LayoutDashboard size={20} /> },
        { name: 'News', path: '/news', icon: <LayoutDashboard size={20} /> },
        { name: 'Services', path: '/services', icon: <LayoutDashboard size={20} /> },
        { name: 'Payment Methods', path: '/payment-methods', icon: <LayoutDashboard size={20} /> },
    ];

    return (
        <div className="h-screen w-64 bg-slate-900 text-white flex flex-col fixed left-0 top-0">
            <div className="p-6">
                <h1 className="text-2xl font-bold text-skycosmic-light">SkyGo Admin</h1>
            </div>

            <nav className="flex-1 px-4 space-y-2">
                {navItems.map((item) => (
                    <NavLink
                        key={item.path}
                        to={item.path}
                        className={({ isActive }) =>
                            `flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${isActive
                                ? 'bg-skycosmic text-white'
                                : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                            }`
                        }
                    >
                        {item.icon}
                        <span>{item.name}</span>
                    </NavLink>
                ))}
            </nav>

            <div className="p-4 border-t border-slate-800">
                <button
                    onClick={logout}
                    className="flex items-center space-x-3 px-4 py-3 w-full text-slate-400 hover:text-red-400 hover:bg-slate-800 rounded-lg transition-colors"
                >
                    <LogOut size={20} />
                    <span>Logout</span>
                </button>
            </div>
        </div>
    );
};

export default Sidebar;
