import { useEffect, useState, useMemo } from 'react';
import { getUsers } from '../services/userService';
import ReactPaginate from 'react-paginate';
import { Users as UsersIcon, Search, Mail, Phone, Star, Calendar } from 'lucide-react';

interface UserData {
    id: number;
    name: string;
    email: string;
    phone: string;
    role: string;
    points: number;
    createdAt: string;
}

const Users = () => {
    const [users, setUsers] = useState<UserData[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);
    const [totalElements, setTotalElements] = useState(0);
    const pageSize = 10;

    useEffect(() => {
        fetchUsers();
    }, [page]);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            const res = await getUsers(page, pageSize);
            if (res.status) {
                setUsers(res.data.content || []);
                setTotalPages(res.data.totalPages || 1);
                setTotalElements(res.data.totalElements || 0);
            }
        } catch (error) {
            console.error('Failed to fetch users', error);
        } finally {
            setLoading(false);
        }
    };

    // Client-side search filter
    const filtered = useMemo(() => {
        if (!searchQuery.trim()) return users;
        const q = searchQuery.toLowerCase();
        return users.filter(
            (u) =>
                u.name?.toLowerCase().includes(q) ||
                u.email?.toLowerCase().includes(q) ||
                u.phone?.includes(searchQuery)
        );
    }, [users, searchQuery]);

    const formatDate = (dateStr: string) => {
        if (!dateStr) return '-';
        return new Date(dateStr).toLocaleDateString('id-ID', {
            year: 'numeric', month: 'short', day: 'numeric'
        });
    };

    const handlePageChange = (event: { selected: number }) => {
        setPage(event.selected);
    };

    return (
        <div>
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Users</h1>
                    <p className="text-sm text-gray-500 mt-1">{totalElements} user terdaftar</p>
                </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center">
                            <UsersIcon size={20} className="text-blue-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold text-gray-800">{totalElements}</p>
                            <p className="text-xs text-gray-500">Total Users</p>
                        </div>
                    </div>
                </div>
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center">
                            <Star size={20} className="text-green-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold text-gray-800">
                                {users.reduce((sum, u) => sum + (u.points || 0), 0)}
                            </p>
                            <p className="text-xs text-gray-500">Total Points</p>
                        </div>
                    </div>
                </div>
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center">
                            <Calendar size={20} className="text-purple-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold text-gray-800">
                                {users.filter(u => {
                                    if (!u.createdAt) return false;
                                    const d = new Date(u.createdAt);
                                    const now = new Date();
                                    return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
                                }).length}
                            </p>
                            <p className="text-xs text-gray-500">User Baru Bulan Ini</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Table */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                {/* Search */}
                <div className="p-4 border-b border-gray-200 flex items-center gap-3 bg-gray-50">
                    <div className="relative flex-1 max-w-sm">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
                        <input
                            type="text"
                            placeholder="Cari nama, email, atau telepon..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="w-full pl-9 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400"
                        />
                    </div>
                    <span className="text-sm text-gray-500">{filtered.length} hasil</span>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-gray-50 text-gray-500 uppercase text-xs font-semibold">
                            <tr>
                                <th className="px-6 py-3">No</th>
                                <th className="px-6 py-3">Nama</th>
                                <th className="px-6 py-3">Email</th>
                                <th className="px-6 py-3">Telepon</th>
                                <th className="px-6 py-3">Role</th>
                                <th className="px-6 py-3">Points</th>
                                <th className="px-6 py-3">Terdaftar</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {loading ? (
                                <tr>
                                    <td colSpan={7} className="px-6 py-12 text-center text-gray-400">
                                        <div className="flex items-center justify-center gap-2">
                                            <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                                            <span>Loading...</span>
                                        </div>
                                    </td>
                                </tr>
                            ) : filtered.length === 0 ? (
                                <tr>
                                    <td colSpan={7} className="px-6 py-12 text-center text-gray-400">
                                        {searchQuery ? `Tidak ada hasil untuk "${searchQuery}"` : 'Tidak ada user'}
                                    </td>
                                </tr>
                            ) : (
                                filtered.map((user, index) => (
                                    <tr key={user.id} className="hover:bg-gray-50 transition-colors">
                                        <td className="px-6 py-4 text-gray-500">{page * pageSize + index + 1}</td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-sky-400 flex items-center justify-center text-white text-xs font-bold">
                                                    {user.name?.charAt(0)?.toUpperCase() || '?'}
                                                </div>
                                                <span className="font-medium text-gray-900">{user.name || '-'}</span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-1.5 text-gray-600">
                                                <Mail size={14} className="text-gray-400" />
                                                {user.email || '-'}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-1.5 text-gray-600">
                                                <Phone size={14} className="text-gray-400" />
                                                {user.phone || '-'}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`px-2.5 py-0.5 rounded-full text-xs font-medium ${user.role === 'ADMIN' ? 'bg-red-100 text-red-700' :
                                                user.role === 'DRIVER' ? 'bg-blue-100 text-blue-700' :
                                                    'bg-green-100 text-green-700'
                                                }`}>
                                                {user.role || 'USER'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-1 text-gray-600">
                                                <Star size={14} className="text-yellow-500" />
                                                {user.points || 0}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-gray-500 text-xs">
                                            {formatDate(user.createdAt)}
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>

                {/* React Paginate */}
                {totalPages > 1 && (
                    <div className="flex items-center justify-between px-6 py-4 border-t border-gray-200 bg-gray-50">
                        <p className="text-sm text-gray-600">
                            Halaman <span className="font-semibold">{page + 1}</span> dari <span className="font-semibold">{totalPages}</span>
                            {' '}({totalElements} total)
                        </p>
                        <ReactPaginate
                            pageCount={totalPages}
                            forcePage={page}
                            onPageChange={handlePageChange}
                            previousLabel="← Prev"
                            nextLabel="Next →"
                            pageRangeDisplayed={3}
                            marginPagesDisplayed={1}
                            containerClassName="flex items-center gap-1"
                            pageLinkClassName="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors"
                            activeLinkClassName="!bg-blue-600 !text-white !border-blue-600"
                            previousLinkClassName="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors"
                            nextLinkClassName="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors"
                            disabledClassName="opacity-50 cursor-not-allowed"
                            breakLabel="..."
                            breakLinkClassName="px-3 py-1.5 text-sm text-gray-500"
                        />
                    </div>
                )}
            </div>
        </div>
    );
};

export default Users;
