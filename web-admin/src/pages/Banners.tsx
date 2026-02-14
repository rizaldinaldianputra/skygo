import CrudPage from '../components/CrudPage';

const Banners = () => {
    return (
        <CrudPage
            title="Banners"
            endpoint="/admin/banners"
            columns={[
                { key: 'imageUrl', label: 'Gambar', type: 'image' },
                { key: 'title', label: 'Judul' },
                { key: 'actionUrl', label: 'Action URL' },
                { key: 'displayOrder', label: 'Urutan' },
                { key: 'active', label: 'Status', type: 'boolean' },
            ]}
            fields={[
                { key: 'title', label: 'Judul Banner', type: 'text', required: true },
                { key: 'actionUrl', label: 'Action URL (link tujuan)', type: 'text' },
                { key: 'displayOrder', label: 'Urutan Tampil', type: 'number' },
                { key: 'imageUrl', label: 'Gambar Banner', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default Banners;
