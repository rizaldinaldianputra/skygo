import { NavLink, useLocation } from 'react-router-dom';
import {
    LayoutDashboard, Car, Users, LogOut, Tag, Image,
    Newspaper, CreditCard, Activity, X, ChevronRight,
    ShoppingBag, Ticket
} from 'lucide-react';
import { useAuth } from '../hooks/useAuth';

interface SidebarProps {
    onClose?: () => void;
}

const Sidebar = ({ onClose }: SidebarProps) => {
    const { logout } = useAuth();
    const location = useLocation();

    const navSections = [
        {
            label: 'Main',
            items: [
                { name: 'Dashboard', path: '/', icon: <LayoutDashboard size={20} /> },
                { name: 'Monitoring', path: '/monitoring', icon: <Activity size={20} /> },
            ]
        },
        {
            label: 'Manajemen',
            items: [
                { name: 'Drivers', path: '/drivers', icon: <Car size={20} /> },
                { name: 'Users', path: '/users', icon: <Users size={20} /> },
                { name: 'Orders', path: '/orders', icon: <ShoppingBag size={20} /> },
                { name: 'Discounts', path: '/discounts', icon: <Ticket size={20} /> },
            ]
        },
        {
            label: 'Konten',
            items: [
                { name: 'Promo', path: '/promos', icon: <Tag size={20} /> },
                { name: 'Banners', path: '/banners', icon: <Image size={20} /> },
                { name: 'News', path: '/news', icon: <Newspaper size={20} /> },
                { name: 'Payment Methods', path: '/payment-methods', icon: <CreditCard size={20} /> },
            ]
        },
    ];

    return (
        <div className="h-full flex flex-col text-white shadow-2xl">
            {/* Header */}
            <div className="p-6 flex items-center justify-between border-b border-slate-700/50">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-sky-400 flex items-center justify-center shadow-lg shadow-blue-500/20">
                        <span className="text-lg font-black text-white">S</span>
                    </div>
                    <div>
                        <h1 className="text-lg font-bold tracking-tight text-blue-400">SkyGo</h1>
                        <p className="text-[10px] text-slate-400 uppercase tracking-widest">Admin Panel</p>
                    </div>
                </div>
                {onClose && (
                    <button onClick={onClose} className="lg:hidden p-2 rounded-lg hover:bg-slate-700/50 transition-colors">
                        <X size={20} className="text-slate-400" />
                    </button>
                )}
            </div>

            {/* Navigation */}
            <nav className="flex-1 px-3 py-4 space-y-6 overflow-y-auto">
                {navSections.map((section) => (
                    <div key={section.label}>
                        <p className="px-4 mb-2 text-[10px] font-semibold text-slate-500 uppercase tracking-widest">
                            {section.label}
                        </p>
                        <div className="space-y-1">
                            {section.items.map((item) => {
                                const isActive = location.pathname === item.path ||
                                    (item.path !== '/' && location.pathname.startsWith(item.path));

                                return (
                                    <NavLink
                                        key={item.path}
                                        to={item.path}
                                        onClick={onClose}
                                        className={`
                                            flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group
                                            ${isActive
                                                ? 'bg-gradient-to-r from-blue-600/80 to-sky-500/80 text-white shadow-lg shadow-blue-500/20'
                                                : 'text-slate-400 hover:bg-slate-700/40 hover:text-white'
                                            }
                                        `}
                                    >
                                        <span className={isActive ? 'text-white' : 'text-slate-500 group-hover:text-slate-300'}>
                                            {item.icon}
                                        </span>
                                        <span className="flex-1">{item.name}</span>
                                        {isActive && <ChevronRight size={14} className="text-white/60" />}
                                    </NavLink>
                                );
                            })}
                        </div>
                    </div>
                ))}
            </nav>

            {/* Footer */}
            <div className="p-4 border-t border-slate-700/50">
                <button
                    onClick={logout}
                    className="flex items-center gap-3 px-4 py-2.5 w-full text-slate-400 hover:text-red-400 hover:bg-red-500/10 rounded-xl transition-all duration-200 text-sm font-medium"
                >
                    <LogOut size={20} />
                    <span>Logout</span>
                </button>
            </div>
        </div>
    );
};

export default Sidebar;
