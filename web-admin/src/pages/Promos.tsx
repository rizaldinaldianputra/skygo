import CrudPage from '../components/CrudPage';

const Promos = () => {
    return (
        <CrudPage
            title="Promos"
            endpoint="/admin/promos"
            columns={[
                { key: 'imageUrl', label: 'Gambar', type: 'image' },
                { key: 'title', label: 'Judul' },
                { key: 'code', label: 'Kode Promo' },
                { key: 'discountAmount', label: 'Diskon' },
                { key: 'discountType', label: 'Tipe' },
                { key: 'active', label: 'Status', type: 'boolean' },
            ]}
            fields={[
                { key: 'title', label: 'Judul Promo', type: 'text', required: true },
                { key: 'description', label: 'Deskripsi', type: 'textarea' },
                { key: 'code', label: 'Kode Promo', type: 'text', required: true },
                { key: 'discountAmount', label: 'Jumlah Diskon', type: 'number', required: true },
                {
                    key: 'discountType',
                    label: 'Tipe Diskon',
                    type: 'select',
                    required: true,
                    options: [
                        { value: 'FIXED', label: 'Fixed (Rp)' },
                        { value: 'PERCENTAGE', label: 'Percentage (%)' },
                    ],
                },
                { key: 'imageUrl', label: 'Gambar Promo', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default Promos;
