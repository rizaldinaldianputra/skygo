import CrudPage from '../components/CrudPage';

const PaymentMethods = () => {
    return (
        <CrudPage
            title="Payment Methods"
            endpoint="/admin/payment-methods"
            columns={[
                { key: 'imageUrl', label: 'Icon', type: 'image' },
                { key: 'name', label: 'Name' },
                { key: 'code', label: 'Code' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
            fields={[
                { key: 'name', label: 'Name', type: 'text' },
                { key: 'code', label: 'Code (e.g. WALLET)', type: 'text' },
                { key: 'description', label: 'Description', type: 'textarea' },
                { key: 'instructions', label: 'Instructions', type: 'textarea' },
                { key: 'imageUrl', label: 'Icon', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default PaymentMethods;
