import CrudPage from '../components/CrudPage';

const NewsPage = () => {
    return (
        <CrudPage
            title="News"
            endpoint="/admin/news"
            columns={[
                { key: 'imageUrl', label: 'Gambar', type: 'image' },
                { key: 'title', label: 'Judul' },
                { key: 'active', label: 'Status', type: 'boolean' },
            ]}
            fields={[
                { key: 'title', label: 'Judul Berita', type: 'text', required: true },
                { key: 'content', label: 'Konten', type: 'textarea', required: true },
                { key: 'imageUrl', label: 'Gambar', type: 'image' },
                { key: 'active', label: 'Active', type: 'boolean' },
            ]}
        />
    );
};

export default NewsPage;
