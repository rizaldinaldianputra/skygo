import CrudPage from '../components/CrudPage';

const Orders = () => {
    return (
        <CrudPage
            title="Orders"
            endpoint="/admin/orders"
            columns={[
                { key: 'id', label: 'ID' },
                { key: 'serviceType', label: 'Service' },
                { key: 'pickupAddress', label: 'Pickup' },
                { key: 'destinationAddress', label: 'Destination' },
                { key: 'distanceKm', label: 'Distance (KM)' },
                { key: 'estimatedPrice', label: 'Price' },
                { key: 'paymentMethod', label: 'Payment' },
                { key: 'status', label: 'Status' },
            ]}
            fields={[
                {
                    key: 'serviceType', label: 'Service Type', type: 'select', options: [
                        { value: 'CAR', label: 'Car' },
                        { value: 'MOTOR', label: 'Motor' },
                    ]
                },
                { key: 'pickupAddress', label: 'Pickup Address', type: 'text' },
                { key: 'destinationAddress', label: 'Destination Address', type: 'text' },
                { key: 'distanceKm', label: 'Distance (KM)', type: 'number' },
                { key: 'estimatedPrice', label: 'Price', type: 'number' },
                { key: 'paymentMethod', label: 'Payment Method', type: 'text' },
                {
                    key: 'status', label: 'Status', type: 'select', options: [
                        { value: 'REQUESTED', label: 'Requested' },
                        { value: 'ACCEPTED', label: 'Accepted' },
                        { value: 'ONGOING', label: 'Ongoing' },
                        { value: 'COMPLETED', label: 'Completed' },
                        { value: 'CANCELLED', label: 'Cancelled' },
                    ]
                },
            ]}
        />
    );
};

export default Orders;
