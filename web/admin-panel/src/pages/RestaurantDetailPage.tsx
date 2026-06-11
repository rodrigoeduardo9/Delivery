import { useState, useMemo } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useApi, useMutation } from '../hooks/useApi';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import StatusBadge from '../components/ui/StatusBadge';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import { formatCurrency, formatDate, formatNumber } from '../utils/formatters';
import { Star, ArrowLeft, Clock, Utensils, MapPin, BarChart3, TrendingUp, ShoppingCart } from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';
import type { Restaurant, Product } from '../types';

type DetailTab = 'overview' | 'menu' | 'hours' | 'zones' | 'reports';

const TABS: { key: DetailTab; label: string; icon: React.ElementType }[] = [
  { key: 'overview', label: 'Overview', icon: BarChart3 },
  { key: 'menu', label: 'Menu', icon: Utensils },
  { key: 'hours', label: 'Hours', icon: Clock },
  { key: 'zones', label: 'Zones', icon: MapPin },
  { key: 'reports', label: 'Reports', icon: TrendingUp },
];

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

export default function RestaurantDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<DetailTab>('overview');

  const { data: restaurant, isLoading, error, refetch } = useApi<Restaurant>(`/restaurants/${id}`);

  if (isLoading) return <LoadingSpinner size="lg" />;

  if (error || !restaurant) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-danger-600 mb-4">{error || 'Restaurant not found'}</p>
        <button onClick={() => navigate('/restaurants')} className="btn-primary">Back to Restaurants</button>
      </div>
    );
  }

  return (
    <ErrorBoundary>
      <div className="space-y-6">
        <button onClick={() => navigate('/restaurants')} className="btn-secondary">
          <ArrowLeft className="h-4 w-4" /> Back to Restaurants
        </button>

        <div className="card p-6">
          <div className="flex flex-wrap items-start justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary-50 text-2xl font-bold text-primary-600">
                {restaurant.name.charAt(0)}
              </div>
              <div>
                <div className="flex items-center gap-3">
                  <h1 className="text-2xl font-bold text-admin-900">{restaurant.name}</h1>
                  <StatusBadge status={restaurant.status} />
                </div>
                <p className="text-admin-500">{restaurant.category} • {restaurant.owner}</p>
                <div className="mt-1 flex items-center gap-4 text-sm">
                  <span className="flex items-center gap-1"><Star className="h-4 w-4 text-warning-500 fill-warning-500" /> {restaurant.rating?.toFixed(1) || '-'}</span>
                  <span className="text-admin-400">{restaurant.total_orders} total orders</span>
                  <span className="text-admin-400">{formatCurrency(restaurant.total_revenue)} total revenue</span>
                </div>
              </div>
            </div>
            <div className="text-right text-sm">
              <p className="text-admin-500">Commission: <span className="font-semibold text-admin-900">{restaurant.commission_rate}%</span></p>
              <p className="text-admin-500">Delivery fee: <span className="font-semibold text-admin-900">{formatCurrency(restaurant.delivery_fee)}</span></p>
              <p className="text-admin-500">Min order: <span className="font-semibold text-admin-900">{formatCurrency(restaurant.min_order)}</span></p>
            </div>
          </div>
        </div>

        <div className="flex gap-1 rounded-xl bg-admin-100 p-1">
          {TABS.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
                  activeTab === tab.key
                    ? 'bg-white text-primary-700 shadow-sm'
                    : 'text-admin-600 hover:text-admin-900'
                }`}
              >
                <Icon className="h-4 w-4" />
                {tab.label}
              </button>
            );
          })}
        </div>

        {activeTab === 'overview' && (
          <div className="grid gap-6 md:grid-cols-3">
            <div className="card p-6">
              <div className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-success-50 text-success-600">
                  <ShoppingCart className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-sm text-admin-500">Orders Today</p>
                  <p className="text-2xl font-bold">{formatNumber(restaurant.orders_today)}</p>
                </div>
              </div>
            </div>
            <div className="card p-6">
              <div className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary-50 text-primary-600">
                  <TrendingUp className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-sm text-admin-500">Revenue Today</p>
                  <p className="text-2xl font-bold">{formatCurrency(restaurant.revenue_today)}</p>
                </div>
              </div>
            </div>
            <div className="card p-6">
              <div className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-warning-50 text-warning-600">
                  <Star className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-sm text-admin-500">Rating</p>
                  <p className="text-2xl font-bold">{restaurant.rating?.toFixed(1) || '-'}</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'menu' && (
          <div className="card">
            <div className="card-header flex items-center justify-between">
              <h3 className="text-lg font-semibold">Menu Items ({restaurant.menu?.length || 0})</h3>
              <button className="btn-primary btn-sm">Add Item</button>
            </div>
            <div className="divide-y">
              {restaurant.menu?.map((item: Product) => (
                <div key={item.id} className="flex items-center justify-between p-4 hover:bg-admin-50">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-admin-100 text-admin-600">
                      <Utensils className="h-5 w-5" />
                    </div>
                    <div>
                      <p className="font-medium text-admin-900">{item.name}</p>
                      <p className="text-xs text-admin-500">{item.category} • {item.preparation_time ? `${item.preparation_time} min` : '-'}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <span className={`badge ${item.is_available ? 'bg-success-100 text-success-800' : 'bg-danger-100 text-danger-800'}`}>
                      {item.is_available ? 'Available' : 'Unavailable'}
                    </span>
                    <span className="font-semibold text-admin-900">{formatCurrency(item.price)}</span>
                    <div className="flex gap-1">
                      <button className="btn-secondary btn-sm">Edit</button>
                      <button className="btn-danger btn-sm">Delete</button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'hours' && (
          <div className="card">
            <div className="card-header">
              <h3 className="text-lg font-semibold">Opening Hours</h3>
            </div>
            <div className="divide-y">
              {DAYS.map((day) => {
                const hours = restaurant.opening_hours?.find((h) => h.day === day);
                return (
                  <div key={day} className="flex items-center justify-between p-4">
                    <span className="font-medium text-admin-900">{day}</span>
                    <span className="text-admin-600">
                      {hours?.is_closed ? (
                        <span className="text-danger-500 font-medium">Closed</span>
                      ) : hours ? (
                        `${hours.open} - ${hours.close}`
                      ) : (
                        <span className="text-admin-400">Not set</span>
                      )}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {activeTab === 'zones' && (
          <div className="grid gap-6 md:grid-cols-2">
            {restaurant.zones?.map((zone) => (
              <div key={zone.id} className="card p-6">
                <h4 className="font-semibold text-admin-900">{zone.name}</h4>
                <div className="mt-3 space-y-2 text-sm text-admin-600">
                  <p>Base fee: <span className="font-medium text-admin-900">{formatCurrency(zone.base_fee)}</span></p>
                  <p>Per km: <span className="font-medium text-admin-900">{formatCurrency(zone.per_km_rate)}</span></p>
                  <p>Est. time: <span className="font-medium text-admin-900">{zone.estimated_time} min</span></p>
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'reports' && (
          <div className="grid gap-6 lg:grid-cols-2">
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Sales Overview</h3>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={[
                  { month: 'Jan', orders: 120, revenue: 15000 },
                  { month: 'Feb', orders: 145, revenue: 18200 },
                  { month: 'Mar', orders: 132, revenue: 16800 },
                  { month: 'Apr', orders: 158, revenue: 20100 },
                  { month: 'May', orders: 175, revenue: 22300 },
                  { month: 'Jun', orders: 190, revenue: 24100 },
                ]}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="month" stroke="#94a3b8" />
                  <YAxis stroke="#94a3b8" />
                  <Tooltip />
                  <Bar dataKey="revenue" fill="#6366f1" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Order Count</h3>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={[
                  { month: 'Jan', orders: 120 }, { month: 'Feb', orders: 145 },
                  { month: 'Mar', orders: 132 }, { month: 'Apr', orders: 158 },
                  { month: 'May', orders: 175 }, { month: 'Jun', orders: 190 },
                ]}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="month" stroke="#94a3b8" />
                  <YAxis stroke="#94a3b8" />
                  <Tooltip />
                  <Line type="monotone" dataKey="orders" stroke="#10b981" strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        )}
      </div>
    </ErrorBoundary>
  );
}
