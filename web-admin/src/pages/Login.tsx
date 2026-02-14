import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import api from '../services/api';
import { Eye, EyeOff, LogIn } from 'lucide-react';

const Login = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const response = await api.post('/auth/login', { email, password });
            const token = response.data.data?.token || response.data.data;

            if (token && typeof token === 'string') {
                login(token);
                navigate('/');
            } else {
                setError('Invalid response from server');
            }
        } catch (err: any) {
            setError(err.response?.data?.message || 'Login gagal. Periksa email dan password.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center relative overflow-hidden"
            style={{
                background: 'linear-gradient(135deg, #0f172a 0%, #1e3a5f 25%, #2563eb 50%, #38bdf8 75%, #7dd3fc 100%)',
            }}
        >
            {/* Animated background blobs */}
            <div className="absolute inset-0 overflow-hidden">
                <div className="absolute top-[-10%] left-[-5%] w-72 h-72 bg-blue-400/20 rounded-full blur-3xl animate-pulse"></div>
                <div className="absolute bottom-[-15%] right-[-10%] w-96 h-96 bg-sky-300/15 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }}></div>
                <div className="absolute top-[40%] right-[20%] w-64 h-64 bg-cyan-400/10 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '2s' }}></div>
            </div>

            <div className="relative z-10 w-full max-w-md px-4">
                {/* Logo / Brand */}
                <div className="text-center mb-8">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-white/10 backdrop-blur-sm border border-white/20 mb-4 shadow-lg">
                        <span className="text-3xl font-black text-white">S</span>
                    </div>
                    <h1 className="text-3xl font-bold text-white tracking-tight">SkyGo Admin</h1>
                    <p className="text-blue-200/80 text-sm mt-1">Dashboard Management System</p>
                </div>

                {/* Card */}
                <div className="bg-white/10 backdrop-blur-xl border border-white/20 rounded-2xl shadow-2xl p-8">
                    <h2 className="text-xl font-semibold text-white mb-6">Masuk ke Dashboard</h2>

                    {error && (
                        <div className="bg-red-500/20 border border-red-400/30 text-red-200 px-4 py-3 rounded-xl mb-5 text-sm backdrop-blur-sm">
                            {error}
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-5">
                        <div>
                            <label className="block text-sm font-medium text-blue-100 mb-2">Email</label>
                            <input
                                type="text"
                                required
                                className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-sky-400/50 focus:border-sky-400/50 transition-all backdrop-blur-sm"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="admin@skygo.com"
                            />
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-blue-100 mb-2">Password</label>
                            <div className="relative">
                                <input
                                    type={showPassword ? 'text' : 'password'}
                                    required
                                    className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-sky-400/50 focus:border-sky-400/50 transition-all backdrop-blur-sm pr-12"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    placeholder="••••••••"
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-blue-300/60 hover:text-white transition-colors"
                                >
                                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                </button>
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full py-3 px-4 rounded-xl font-semibold text-white transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 shadow-lg hover:shadow-xl"
                            style={{
                                background: 'linear-gradient(135deg, #2563eb 0%, #38bdf8 100%)',
                            }}
                        >
                            {loading ? (
                                <>
                                    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                                    Memproses...
                                </>
                            ) : (
                                <>
                                    <LogIn size={18} />
                                    Masuk
                                </>
                            )}
                        </button>
                    </form>
                </div>

                <p className="text-center text-blue-300/40 text-xs mt-6">
                    © 2026 SkyGo. All rights reserved.
                </p>
            </div>
        </div>
    );
};

export default Login;
