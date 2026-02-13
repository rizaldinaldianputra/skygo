import CrudPage from '../components/CrudPage';

const Promos = () => {
    return (
        <CrudPage
            title="Promos"
            endpoint="/admin/promos"
            columns={[
                { key: 'imageUrl', label: 'Image', type: 'image' },
                { key: 'title', label: 'Title' },
                { key: 'code', label: 'Code' },
                { key: 'discountAmount', label: 'Discount' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
            fields={[
                { key: 'title', label: 'Title', type: 'text' },
                { key: 'description', label: 'Description', type: 'textarea' },
                { key: 'code', label: 'Promo Code', type: 'text' },
                { key: 'discountAmount', label: 'Discount Amount', type: 'number' },
                { key: 'discountType', label: 'Discount Type (FIXED/PERCENTAGE)', type: 'text' },
                { key: 'imageUrl', label: 'Image', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default Promos;
