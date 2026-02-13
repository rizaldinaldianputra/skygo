import CrudPage from '../components/CrudPage';

const Services = () => {
    return (
        <CrudPage
            title="Services"
            endpoint="/admin/services"
            columns={[
                { key: 'iconUrl', label: 'Icon', type: 'image' },
                { key: 'name', label: 'Name' },
                { key: 'code', label: 'Code' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
            fields={[
                { key: 'name', label: 'Name', type: 'text' },
                { key: 'code', label: 'Code (e.g. MOTOR, CAR)', type: 'text' },
                { key: 'description', label: 'Description', type: 'textarea' },
                { key: 'displayOrder', label: 'Order', type: 'number' },
                { key: 'iconUrl', label: 'Icon', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default Services;
