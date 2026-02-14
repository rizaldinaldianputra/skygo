import type { ReactNode } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './hooks/useAuth';
import Layout from './components/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Drivers from './pages/Drivers';
import Users from './pages/Users';
import Monitoring from './pages/Monitoring';
import Promos from './pages/Promos';
import Banners from './pages/Banners';
import News from './pages/News';
import PaymentMethods from './pages/PaymentMethods';
import Orders from './pages/Orders';
import Discounts from './pages/Discounts';

const ProtectedRoute = ({ children }: { children: ReactNode }) => {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  return children;
};

const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      <Route path="/" element={
        <ProtectedRoute>
          <Layout />
        </ProtectedRoute>
      }>
        <Route index element={<Dashboard />} />
        <Route path="drivers" element={<Drivers />} />
        <Route path="users" element={<Users />} />
        <Route path="monitoring" element={<Monitoring />} />
        <Route path="promos" element={<Promos />} />
        <Route path="banners" element={<Banners />} />
        <Route path="news" element={<News />} />
        <Route path="payment-methods" element={<PaymentMethods />} />
        <Route path="orders" element={<Orders />} />
        <Route path="discounts" element={<Discounts />} />
      </Route>
    </Routes>
  );
};

const App = () => {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  );
};

export default App;
