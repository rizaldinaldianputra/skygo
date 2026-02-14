import { useState, useEffect, useMemo } from 'react';
import api from '../services/api';
import ReactPaginate from 'react-paginate';
import { Trash2, Plus, Pencil, X, Upload, Eye, Search } from 'lucide-react';

interface SelectOption {
    value: string;
    label: string;
}

interface FieldDefinition {
    key: string;
    label: string;
    type: 'text' | 'textarea' | 'image' | 'number' | 'boolean' | 'select';
    options?: SelectOption[];
    required?: boolean;
}

interface ColumnDefinition {
    key: string;
    label: string;
    type?: 'image' | 'text' | 'boolean';
}

interface CrudPageProps {
    title: string;
    endpoint: string;
    columns: ColumnDefinition[];
    fields: FieldDefinition[];
    pageSize?: number;
}

const CrudPage: React.FC<CrudPageProps> = ({ title, endpoint, columns, fields, pageSize = 10 }) => {
    const [data, setData] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [formData, setFormData] = useState<any>({});
    const [imageFile, setImageFile] = useState<File | null>(null);
    const [imagePreview, setImagePreview] = useState<string | null>(null);
    const [editingId, setEditingId] = useState<number | null>(null);
    const [saving, setSaving] = useState(false);
    const [deleting, setDeleting] = useState<number | null>(null);

    // Pagination state
    const [page, setPage] = useState(0);
    const [totalPages, setTotalPages] = useState(0);
    const [totalElements, setTotalElements] = useState(0);

    // Search state
    const [searchQuery, setSearchQuery] = useState('');

    useEffect(() => {
        fetchData();
    }, [page]);

    const fetchData = async () => {
        try {
            setLoading(true);
            const res = await api.get(endpoint, { params: { page, size: pageSize } });
            const responseData = res.data;
            // Spring Page format: { status, message, data: { content, totalElements, totalPages, ... } }
            if (responseData.data?.content !== undefined) {
                setData(responseData.data.content || []);
                setTotalPages(responseData.data.totalPages || 1);
                setTotalElements(responseData.data.totalElements || 0);
            } else {
                // Fallback for non-paginated responses
                const items = Array.isArray(responseData.data) ? responseData.data : [];
                setData(items);
                setTotalPages(1);
                setTotalElements(items.length);
            }
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    // Client-side search filter
    const filteredData = useMemo(() => {
        if (!searchQuery.trim()) return data;
        const q = searchQuery.toLowerCase();
        return data.filter(item =>
            columns.some(col => {
                const val = item[col.key];
                if (val == null) return false;
                return String(val).toLowerCase().includes(q);
            })
        );
    }, [data, searchQuery, columns]);

    const handlePageChange = (event: { selected: number }) => {
        setPage(event.selected);
    };

    const openCreateModal = () => {
        setFormData({});
        setImageFile(null);
        setImagePreview(null);
        setEditingId(null);
        setIsModalOpen(true);
    };

    const openEditModal = (item: any) => {
        setFormData({ ...item });
        setImageFile(null);
        const imgField = fields.find(f => f.type === 'image');
        if (imgField && item[imgField.key]) {
            setImagePreview(item[imgField.key]);
        } else {
            setImagePreview(null);
        }
        setEditingId(item.id);
        setIsModalOpen(true);
    };

    const closeModal = () => {
        setIsModalOpen(false);
        setFormData({});
        setImageFile(null);
        setImagePreview(null);
        setEditingId(null);
    };

    const handleDelete = async (id: number) => {
        if (!confirm('Apakah Anda yakin ingin menghapus data ini?')) return;
        try {
            setDeleting(id);
            await api.delete(`${endpoint}/${id}`);
            fetchData();
        } catch (err) {
            console.error(err);
            alert('Gagal menghapus data');
        } finally {
            setDeleting(null);
        }
    };

    const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0] || null;
        setImageFile(file);
        if (file) {
            const reader = new FileReader();
            reader.onload = (ev) => setImagePreview(ev.target?.result as string);
            reader.readAsDataURL(file);
        }
    };

    const handleSave = async (e: React.FormEvent) => {
        e.preventDefault();
        setSaving(true);

        let dataToSave = { ...formData };

        if (imageFile) {
            const uploadFormData = new FormData();
            uploadFormData.append('file', imageFile);
            try {
                const uploadRes = await api.post('/admin/upload', uploadFormData);
                const imgField = fields.find(f => f.type === 'image');
                if (imgField) {
                    dataToSave[imgField.key] = uploadRes.data.data;
                }
            } catch (err) {
                alert('Gagal upload gambar');
                setSaving(false);
                return;
            }
        }

        try {
            if (editingId) {
                await api.put(`${endpoint}/${editingId}`, dataToSave);
            } else {
                await api.post(endpoint, dataToSave);
            }
            closeModal();
            fetchData();
        } catch (err) {
            console.error(err);
            alert('Gagal menyimpan data');
        } finally {
            setSaving(false);
        }
    };

    const renderFieldInput = (field: FieldDefinition) => {
        const baseInputClass = "mt-1 block w-full rounded-lg border border-gray-300 shadow-sm p-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors";

        switch (field.type) {
            case 'textarea':
                return (
                    <textarea
                        rows={3}
                        className={baseInputClass}
                        value={formData[field.key] || ''}
                        onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                        required={field.required}
                    />
                );

            case 'image':
                return (
                    <div>
                        <div className="flex items-center gap-3 mt-1">
                            <label className="flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg cursor-pointer hover:bg-gray-200 transition-colors border border-gray-300">
                                <Upload size={16} />
                                <span className="text-sm">{imageFile ? 'Ganti Gambar' : 'Pilih Gambar'}</span>
                                <input
                                    type="file"
                                    className="hidden"
                                    accept="image/*"
                                    onChange={handleImageChange}
                                />
                            </label>
                            {imageFile && <span className="text-sm text-gray-500 truncate max-w-[200px]">{imageFile.name}</span>}
                        </div>
                        {imagePreview && (
                            <div className="mt-2 relative inline-block">
                                <img src={imagePreview} alt="Preview" className="h-20 w-20 rounded-lg object-cover border border-gray-200" />
                            </div>
                        )}
                    </div>
                );

            case 'boolean':
                return (
                    <div className="mt-1">
                        <label className="relative inline-flex items-center cursor-pointer">
                            <input
                                type="checkbox"
                                className="sr-only peer"
                                checked={formData[field.key] ?? true}
                                onChange={(e) => setFormData({ ...formData, [field.key]: e.target.checked })}
                            />
                            <div className="w-11 h-6 bg-gray-200 peer-focus:ring-2 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            <span className="ml-3 text-sm text-gray-600">{formData[field.key] !== false ? 'Active' : 'Inactive'}</span>
                        </label>
                    </div>
                );

            case 'select':
                return (
                    <select
                        className={baseInputClass}
                        value={formData[field.key] || ''}
                        onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                        required={field.required}
                    >
                        <option value="">-- Pilih {field.label} --</option>
                        {field.options?.map((opt) => (
                            <option key={opt.value} value={opt.value}>{opt.label}</option>
                        ))}
                    </select>
                );

            case 'number':
                return (
                    <input
                        type="number"
                        step="any"
                        className={baseInputClass}
                        value={formData[field.key] || ''}
                        onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                        required={field.required}
                    />
                );

            default:
                return (
                    <input
                        type="text"
                        className={baseInputClass}
                        value={formData[field.key] || ''}
                        onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                        required={field.required}
                    />
                );
        }
    };

    if (loading && data.length === 0) {
        return (
            <div className="p-6 flex items-center justify-center h-64">
                <div className="flex items-center gap-3">
                    <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                    <span className="text-gray-500">Loading {title}...</span>
                </div>
            </div>
        );
    }

    return (
        <div className="p-6">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">{title}</h1>
                    <p className="text-sm text-gray-500 mt-1">{totalElements} item(s)</p>
                </div>
                <button
                    onClick={openCreateModal}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2.5 rounded-lg flex items-center gap-2 shadow-sm transition-colors"
                >
                    <Plus size={18} /> Tambah {title}
                </button>
            </div>

            {/* Table */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                {/* Search Bar */}
                <div className="p-4 border-b border-gray-200 bg-gray-50">
                    <div className="relative max-w-sm">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
                        <input
                            type="text"
                            placeholder={`Cari ${title.toLowerCase()}...`}
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="w-full pl-9 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400"
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead>
                            <tr className="bg-gray-50 border-b border-gray-200">
                                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">No</th>
                                {columns.map((col) => (
                                    <th key={col.key} className="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                                        {col.label}
                                    </th>
                                ))}
                                <th className="px-6 py-3 text-center text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {filteredData.length === 0 ? (
                                <tr>
                                    <td colSpan={columns.length + 2} className="px-6 py-12 text-center text-gray-400">
                                        {searchQuery ? `Tidak ada hasil untuk "${searchQuery}"` : `Belum ada data. Klik "Tambah ${title}" untuk menambahkan.`}
                                    </td>
                                </tr>
                            ) : (
                                filteredData.map((item, index) => (
                                    <tr key={item.id} className="hover:bg-gray-50 transition-colors">
                                        <td className="px-6 py-4 text-sm text-gray-500">{page * pageSize + index + 1}</td>
                                        {columns.map((col) => (
                                            <td key={col.key} className="px-6 py-4 whitespace-nowrap">
                                                {col.type === 'image' ? (
                                                    item[col.key] ? (
                                                        <img
                                                            src={item[col.key]}
                                                            alt={item.name || item.title || ''}
                                                            className="h-12 w-12 rounded-lg object-cover border border-gray-200 shadow-sm"
                                                            onError={(e) => { (e.target as HTMLImageElement).src = 'https://via.placeholder.com/48'; }}
                                                        />
                                                    ) : (
                                                        <div className="h-12 w-12 rounded-lg bg-gray-100 flex items-center justify-center text-gray-400">
                                                            <Eye size={16} />
                                                        </div>
                                                    )
                                                ) : col.type === 'boolean' ? (
                                                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${item[col.key] ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                                        }`}>
                                                        {item[col.key] ? '✓ Active' : '✗ Inactive'}
                                                    </span>
                                                ) : (
                                                    <span className="text-sm text-gray-700">{item[col.key]}</span>
                                                )}
                                            </td>
                                        ))}
                                        <td className="px-6 py-4 whitespace-nowrap text-center">
                                            <div className="flex items-center justify-center gap-2">
                                                <button
                                                    onClick={() => openEditModal(item)}
                                                    className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                                    title="Edit"
                                                >
                                                    <Pencil size={16} />
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(item.id)}
                                                    disabled={deleting === item.id}
                                                    className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
                                                    title="Delete"
                                                >
                                                    {deleting === item.id ? (
                                                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-red-600"></div>
                                                    ) : (
                                                        <Trash2 size={16} />
                                                    )}
                                                </button>
                                            </div>
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
                            pageClassName=""
                            pageLinkClassName="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors"
                            activeClassName=""
                            activeLinkClassName="!bg-blue-600 !text-white !border-blue-600"
                            previousClassName=""
                            previousLinkClassName="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors"
                            nextClassName=""
                            nextLinkClassName="px-3 py-1.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-100 transition-colors"
                            disabledClassName="opacity-50 cursor-not-allowed"
                            breakLabel="..."
                            breakClassName=""
                            breakLinkClassName="px-3 py-1.5 text-sm text-gray-500"
                        />
                    </div>
                )}
            </div>

            {/* Modal */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50" onClick={(e) => { if (e.target === e.currentTarget) closeModal(); }}>
                    <div className="bg-white rounded-xl max-w-lg w-full shadow-2xl max-h-[90vh] overflow-y-auto">
                        {/* Modal Header */}
                        <div className="flex items-center justify-between p-5 border-b border-gray-200">
                            <h2 className="text-xl font-bold text-gray-800">
                                {editingId ? 'Edit' : 'Tambah'} {title}
                            </h2>
                            <button
                                onClick={closeModal}
                                className="p-1 text-gray-400 hover:text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
                            >
                                <X size={20} />
                            </button>
                        </div>

                        {/* Modal Body */}
                        <form onSubmit={handleSave} className="p-5 space-y-4">
                            {fields.map((field) => (
                                <div key={field.key}>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        {field.label}
                                        {field.required && <span className="text-red-500 ml-1">*</span>}
                                    </label>
                                    {renderFieldInput(field)}
                                </div>
                            ))}

                            {/* Modal Footer */}
                            <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="px-5 py-2.5 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors font-medium"
                                >
                                    Batal
                                </button>
                                <button
                                    type="submit"
                                    disabled={saving}
                                    className="px-5 py-2.5 text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition-colors font-medium disabled:opacity-50 flex items-center gap-2"
                                >
                                    {saving ? (
                                        <>
                                            <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                                            Menyimpan...
                                        </>
                                    ) : (
                                        editingId ? 'Update' : 'Simpan'
                                    )}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default CrudPage;
