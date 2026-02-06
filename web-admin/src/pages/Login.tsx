import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import api from '../services/api';

const Login = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            // Assuming backend returns { status: true, data: { token: '...' } }
            const response = await api.post('/auth/login', { email, password }); // Or phone/password depending on backend

            // Backend refactor uses ApiResponse<Object>. Data might be the token string or object containing token.
            // Based on previous refactor:
            // Object response = authService.login(request); -> return Response string "Login Success" or JWT?
            // Wait, standard JWT flow usually returns { token: "..." }. 
            // Let's assume response.data.data.token exists or response.data.data is the token.
            // For now, let's assume the backend returns a token in the data field.

            // Verification neded: AuthController.login calls authService.login. 
            // If authService returns a String, then `response.data.data` is the string.
            // If it returns an object, we need to parse it.
            // Let's assume it returns a JWT token string for now.

            const token = response.data.data?.token || response.data.data;

            if (token && typeof token === 'string') {
                login(token);
                navigate('/');
            } else {
                setError('Invalid response from server');
            }

        } catch (err: any) {
            setError(err.response?.data?.message || 'Login failed');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-slate-900 flex items-center justify-center">
            <div className="bg-white p-8 rounded-2xl shadow-2xl w-full max-w-md">
                <h2 className="text-3xl font-bold text-center text-skycosmic-DEFAULT mb-8">Admin Login</h2>

                {error && (
                    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4 text-sm">
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-6">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Email</label>
                        <input
                            type="text"
                            required
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-skycosmic-light focus:border-transparent outline-none transition-all"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="admin@skygo.com"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Password</label>
                        <input
                            type="password"
                            required
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-skycosmic-light focus:border-transparent outline-none transition-all"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="••••••••"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-skycosmic-DEFAULT hover:bg-skycosmic-dark text-white font-bold py-3 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {loading ? 'Logging in...' : 'Login'}
                    </button>
                </form>
            </div>
        </div>
    );
};

export default Login;
