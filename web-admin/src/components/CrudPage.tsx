import { useState, useEffect } from 'react';
import api from '../api';
import { Trash2, Plus } from 'lucide-react';

interface CrudPageProps {
    title: string;
    endpoint: string;
    columns: { key: string; label: string; type?: 'image' | 'text' | 'boolean' }[];
    fields: { key: string; label: string; type: 'text' | 'textarea' | 'image' | 'number' | 'boolean' }[];
}

const CrudPage: React.FC<CrudPageProps> = ({ title, endpoint, columns, fields }) => {
    const [data, setData] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [formData, setFormData] = useState<any>({});
    const [imageFile, setImageFile] = useState<File | null>(null);

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            const res = await api.get(endpoint);
            setData(res.data.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id: number) => {
        if (confirm('Are you sure?')) {
            await api.delete(`${endpoint}/${id}`);
            fetchData();
        }
    };

    const handleSave = async (e: React.FormEvent) => {
        e.preventDefault();
        let dataToSave = { ...formData };

        if (imageFile) {
            const uploadFormData = new FormData();
            uploadFormData.append('file', imageFile);
            try {
                const uploadRes = await api.post('/admin/upload', uploadFormData);
                dataToSave.imageUrl = uploadRes.data.data; // Assuming field is always imageUrl or iconUrl
                // If field is iconUrl, we might need logic.
                // For simplicity, let's look for the image field key in `fields`
                const imgField = fields.find(f => f.type === 'image');
                if (imgField) dataToSave[imgField.key] = uploadRes.data.data;

            } catch (err) {
                alert('Image upload failed');
                return;
            }
        }

        try {
            await api.post(endpoint, dataToSave);
            setIsModalOpen(false);
            setFormData({});
            setImageFile(null);
            fetchData();
        } catch (err) {
            console.error(err);
            alert('Failed to save');
        }
    };

    if (loading) return <div className="p-6">Loading...</div>;

    return (
        <div className="p-6">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">{title}</h1>
                <button
                    onClick={() => setIsModalOpen(true)}
                    className="bg-blue-600 text-white px-4 py-2 rounded flex items-center gap-2"
                >
                    <Plus size={20} /> Add New
                </button>
            </div>

            <div className="bg-white rounded-lg shadow overflow-hidden">
                <table className="w-full">
                    <thead>
                        <tr className="bg-gray-50 border-b">
                            {columns.map((col) => (
                                <th key={col.key} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                    {col.label}
                                </th>
                            ))}
                            <th className="px-6 py-3 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                        {data.map((item) => (
                            <tr key={item.id}>
                                {columns.map((col) => (
                                    <td key={col.key} className="px-6 py-4 whitespace-nowrap">
                                        {col.type === 'image' ? (
                                            <img src={item[col.key]} alt="" className="h-10 w-10 rounded object-cover" />
                                        ) : col.type === 'boolean' ? (
                                            item[col.key] ? 'Active' : 'Inactive'
                                        ) : (
                                            item[col.key]
                                        )}
                                    </td>
                                ))}
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <button onClick={() => handleDelete(item.id)} className="text-red-600 hover:text-red-900">
                                        <Trash2 size={18} />
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4">
                    <div className="bg-white rounded-lg max-w-md w-full p-6">
                        <h2 className="text-xl font-bold mb-4">Add New {title}</h2>
                        <form onSubmit={handleSave} className="space-y-4">
                            {fields.map((field) => (
                                <div key={field.key}>
                                    <label className="block text-sm font-medium text-gray-700">{field.label}</label>
                                    {field.type === 'textarea' ? (
                                        <textarea
                                            className="mt-1 block w-full rounded border-gray-300 shadow-sm p-2 border"
                                            onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                                        />
                                    ) : field.type === 'image' ? (
                                        <input
                                            type="file"
                                            className="mt-1 block w-full"
                                            onChange={(e) => setImageFile(e.target.files?.[0] || null)}
                                        />
                                    ) : field.type === 'boolean' ? (
                                        <input type="checkbox"
                                            onChange={(e) => setFormData({ ...formData, [field.key]: e.target.checked })}
                                        />
                                    ) : (
                                        <input
                                            type={field.type}
                                            className="mt-1 block w-full rounded border-gray-300 shadow-sm p-2 border"
                                            onChange={(e) => setFormData({ ...formData, [field.key]: e.target.value })}
                                        />
                                    )}
                                </div>
                            ))}
                            <div className="flex justify-end gap-2 mt-6">
                                <button
                                    type="button"
                                    onClick={() => setIsModalOpen(false)}
                                    className="px-4 py-2 text-gray-700 bg-gray-100 rounded hover:bg-gray-200"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="px-4 py-2 text-white bg-blue-600 rounded hover:bg-blue-700"
                                >
                                    Save
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
