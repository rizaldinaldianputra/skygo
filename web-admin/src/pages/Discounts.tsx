import CrudPage from '../components/CrudPage';

const Discounts = () => {
    return (
        <CrudPage
            title="Discounts"
            endpoint="/admin/discounts"
            columns={[
                { key: 'id', label: 'ID' },
                { key: 'code', label: 'Code' },
                { key: 'description', label: 'Description' },
                { key: 'discountType', label: 'Type' },
                { key: 'discountValue', label: 'Value' },
                { key: 'minOrderAmount', label: 'Min Order' },
                { key: 'maxUsage', label: 'Max Usage' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
            fields={[
                { key: 'code', label: 'Discount Code', type: 'text', required: true },
                { key: 'description', label: 'Description', type: 'textarea' },
                {
                    key: 'discountType', label: 'Type', type: 'select', options: [
                        { value: 'PERCENTAGE', label: 'Percentage (%)' },
                        { value: 'FIXED', label: 'Fixed (Rp)' },
                    ]
                },
                { key: 'discountValue', label: 'Value', type: 'number', required: true },
                { key: 'minOrderAmount', label: 'Min Order Amount', type: 'number' },
                { key: 'maxUsage', label: 'Max Usage', type: 'number' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default Discounts;
