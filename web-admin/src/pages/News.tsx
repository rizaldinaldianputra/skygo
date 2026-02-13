import CrudPage from '../components/CrudPage';

const NewsPage = () => {
    return (
        <CrudPage
            title="News"
            endpoint="/admin/news"
            columns={[
                { key: 'imageUrl', label: 'Image', type: 'image' },
                { key: 'title', label: 'Title' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
            fields={[
                { key: 'title', label: 'Title', type: 'text' },
                { key: 'content', label: 'Content', type: 'textarea' },
                { key: 'imageUrl', label: 'Image', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default NewsPage;
