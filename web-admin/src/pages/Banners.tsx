import CrudPage from '../components/CrudPage';

const Banners = () => {
    return (
        <CrudPage
            title="Banners"
            endpoint="/admin/banners"
            columns={[
                { key: 'imageUrl', label: 'Image', type: 'image' },
                { key: 'title', label: 'Title' },
                { key: 'displayOrder', label: 'Order' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
            fields={[
                { key: 'title', label: 'Title', type: 'text' },
                { key: 'actionUrl', label: 'Action URL', type: 'text' },
                { key: 'displayOrder', label: 'Display Order', type: 'number' },
                { key: 'imageUrl', label: 'Image', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default Banners;
