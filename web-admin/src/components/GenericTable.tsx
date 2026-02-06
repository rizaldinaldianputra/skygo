import React, { useState } from 'react';
import { ChevronLeft, ChevronRight, Search } from 'lucide-react';

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
}

function GenericTable<T>({
    data,
    columns,
    totalItems,
    page,
    pageSize,
    onPageChange,
    onSearch,
    loading
}: GenericTableProps<T>) {
    const [searchQuery, setSearchQuery] = useState('');
    const totalPages = Math.ceil(totalItems / pageSize);

    const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
        setSearchQuery(e.target.value);
        if (onSearch) {
            // Debounce could be added here
            onSearch(e.target.value);
        }
    };

    return (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            {/* Header / Search */}
            {onSearch && (
                <div className="p-4 border-b border-gray-200 flex justify-between items-center bg-gray-50">
                    <div className="relative w-72">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
                        <input
                            type="text"
                            placeholder="Search..."
                            value={searchQuery}
                            onChange={handleSearch}
                            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-skycosmic-light focus:border-transparent text-sm"
                        />
                    </div>
                    <div className="text-sm text-gray-500">
                        Total Records: <span className="font-semibold text-gray-900">{totalItems}</span>
                    </div>
                </div>
            )}

            {/* Table */}
            <div className="overflow-x-auto">
                <table className="w-full text-left text-sm text-gray-600">
                    <thead className="bg-gray-50 text-gray-700 uppercase font-medium">
                        <tr>
                            {columns.map((col, index) => (
                                <th key={index} className={`px-6 py-4 ${col.className || ''}`}>
                                    {col.header}
                                </th>
                            ))}
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                        {loading ? (
                            <tr>
                                <td colSpan={columns.length} className="px-6 py-12 text-center text-gray-500">
                                    <div className="flex justify-center items-center space-x-2">
                                        <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-skycosmic-DEFAULT"></div>
                                        <span>Loading data...</span>
                                    </div>
                                </td>
                            </tr>
                        ) : data.length === 0 ? (
                            <tr>
                                <td colSpan={columns.length} className="px-6 py-12 text-center text-gray-400 italic">
                                    No data found
                                </td>
                            </tr>
                        ) : (
                            data.map((item, rowIndex) => (
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

            {/* Pagination */}
            <div className="px-6 py-4 border-t border-gray-200 flex items-center justify-between bg-gray-50">
                <span className="text-sm text-gray-500">
                    Page <span className="font-medium">{Math.min(page + 1, totalPages > 0 ? totalPages : 1)}</span> of{' '}
                    <span className="font-medium">{totalPages > 0 ? totalPages : 1}</span>
                </span>
                <div className="flex space-x-2">
                    <button
                        onClick={() => onPageChange(page - 1)}
                        disabled={page === 0 || loading}
                        className="p-2 rounded-lg border border-gray-300 bg-white text-gray-600 hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                        <ChevronLeft size={18} />
                    </button>
                    <button
                        onClick={() => onPageChange(page + 1)}
                        disabled={page >= totalPages - 1 || loading}
                        className="p-2 rounded-lg border border-gray-300 bg-white text-gray-600 hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    >
                        <ChevronRight size={18} />
                    </button>
                </div>
            </div>
        </div>
    );
}

export default GenericTable;
