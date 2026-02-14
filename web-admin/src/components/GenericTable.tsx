import React, { useState, useMemo } from 'react';
import { Search } from 'lucide-react';
import ReactPaginate from 'react-paginate';

export interface Column<T> {
    header: string;
    accessor: keyof T | ((item: T) => React.ReactNode);
    className?: string;
}

interface GenericTableProps<T> {
    data: T[];
    columns: Column<T>[];
    totalItems: number;
    page: number;
    pageSize: number;
    onPageChange: (newPage: number) => void;
    onSearch?: (query: string) => void;
    loading?: boolean;
    searchPlaceholder?: string;
}

function GenericTable<T>({
    data,
    columns,
    totalItems,
    page,
    pageSize,
    onPageChange,
    loading,
    searchPlaceholder = 'Cari data...'
}: GenericTableProps<T>) {
    const [searchQuery, setSearchQuery] = useState('');
    const totalPages = Math.ceil(totalItems / pageSize);

    // Client-side search filter
    const filteredData = useMemo(() => {
        if (!searchQuery.trim()) return data;
        const q = searchQuery.toLowerCase();
        return data.filter(item =>
            columns.some(col => {
                if (typeof col.accessor === 'function') return false;
                const val = item[col.accessor];
                if (val == null) return false;
                return String(val).toLowerCase().includes(q);
            })
        );
    }, [data, searchQuery, columns]);

    const handlePageChange = (event: { selected: number }) => {
        onPageChange(event.selected);
    };

    return (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            {/* Search */}
            <div className="p-4 border-b border-gray-200 flex items-center justify-between bg-gray-50">
                <div className="relative max-w-sm flex-1">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
                    <input
                        type="text"
                        placeholder={searchPlaceholder}
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-9 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400"
                    />
                </div>
                <span className="text-sm text-gray-500 ml-4">
                    {searchQuery ? `${filteredData.length} hasil` : `${totalItems} total`}
                </span>
            </div>

            {/* Table */}
            <div className="overflow-x-auto">
                <table className="w-full text-left text-sm text-gray-600">
                    <thead className="bg-gray-50 border-b border-gray-200">
                        <tr>
                            {columns.map((col, index) => (
                                <th key={index} className={`px-6 py-3 text-xs font-semibold text-gray-500 uppercase tracking-wider ${col.className || ''}`}>
                                    {col.header}
                                </th>
                            ))}
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {loading ? (
                            <tr>
                                <td colSpan={columns.length} className="px-6 py-12 text-center text-gray-500">
                                    <div className="flex justify-center items-center gap-2">
                                        <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                                        <span>Loading data...</span>
                                    </div>
                                </td>
                            </tr>
                        ) : filteredData.length === 0 ? (
                            <tr>
                                <td colSpan={columns.length} className="px-6 py-12 text-center text-gray-400">
                                    {searchQuery ? `Tidak ada hasil untuk "${searchQuery}"` : 'Tidak ada data'}
                                </td>
                            </tr>
                        ) : (
                            filteredData.map((item, rowIndex) => (
                                <tr key={rowIndex} className="hover:bg-gray-50 transition-colors">
                                    {columns.map((col, colIndex) => (
                                        <td key={colIndex} className="px-6 py-4 whitespace-nowrap">
                                            {typeof col.accessor === 'function'
                                                ? col.accessor(item)
                                                : (item[col.accessor] as React.ReactNode)}
                                        </td>
                                    ))}
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
    );
}

export default GenericTable;
