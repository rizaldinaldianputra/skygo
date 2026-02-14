import CrudPage from '../components/CrudPage';

const PaymentMethods = () => {
    return (
        <CrudPage
            title="Payment Methods"
            endpoint="/admin/payment-methods"
            columns={[
                { key: 'imageUrl', label: 'Icon', type: 'image' },
                { key: 'name', label: 'Nama' },
                { key: 'code', label: 'Code' },
                { key: 'type', label: 'Type' },
                { key: 'active', label: 'Status', type: 'boolean' },
            ]}
            fields={[
                { key: 'name', label: 'Nama', type: 'text', required: true },
                { key: 'code', label: 'Code (e.g. GOPAY, BCA)', type: 'text', required: true },
                {
                    key: 'type',
                    label: 'Tipe Pembayaran',
                    type: 'select',
                    required: true,
                    options: [
                        { value: 'CASH', label: 'Cash' },
                        { value: 'WALLET', label: 'E-Wallet' },
                        { value: 'BANK', label: 'Bank Transfer' },
                    ],
                },
                { key: 'description', label: 'Deskripsi', type: 'textarea' },
                { key: 'instructions', label: 'Instruksi Pembayaran', type: 'textarea' },
                { key: 'imageUrl', label: 'Icon / Logo', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default PaymentMethods;
