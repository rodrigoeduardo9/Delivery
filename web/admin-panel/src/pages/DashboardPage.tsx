import { useApi } from '../hooks/useApi';
import StatCard from '../components/ui/StatCard';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import StatusBadge from '../components/ui/StatusBadge';
import { formatCurrency, formatDateTime, formatNumber } from '../utils/formatters';
import { ShoppingCart, DollarSign, Bike, Store, TrendingUp } from 'lucide-react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
  Legend,
} from 'recharts';
import type { ReportOverview } from '../types';

const COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

export default function DashboardPage() {
  const { data, isLoading, error, refetch } = useApi<ReportOverview>('/reports/admin/overview');

  if (isLoading) return <LoadingSpinner size="lg" />;

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-danger-600 mb-4">{error}</p>
        <button onClick={refetch} className="btn-primary">Retry</button>
      </div>
    );
  }

  const d = (data as any)?.data;
  if (!d) return null;

  return (
    <ErrorBoundary>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-admin-900">Dashboard</h1>
          <p className="text-admin-500">Overview of your platform today</p>
        </div>

        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <StatCard
            label="Total Orders Today"
            value={formatNumber(d.total_orders_today)}
            icon={<ShoppingCart className="h-6 w-6" />}
            trend={{ value: d.orders_change_percent, isPositive: d.orders_change_percent >= 0 }}
          />
          <StatCard
            label="Revenue Today"
            value={formatCurrency(d.total_revenue_today)}
            icon={<DollarSign className="h-6 w-6" />}
            trend={{ value: d.revenue_change_percent, isPositive: d.revenue_change_percent >= 0 }}
          />
          <StatCard
            label="Active Drivers"
            value={formatNumber(d.active_drivers)}
            icon={<Bike className="h-6 w-6" />}
            trend={{ value: d.drivers_change_percent, isPositive: d.drivers_change_percent >= 0 }}
          />
          <StatCard
            label="Active Restaurants"
            value={formatNumber(d.active_restaurants)}
            icon={<Store className="h-6 w-6" />}
            trend={{ value: d.restaurants_change_percent, isPositive: d.restaurants_change_percent >= 0 }}
          />
        </div>

        <div className="grid gap-6 lg:grid-cols-2">
          <div className="card p-6">
            <h3 className="mb-4 text-lg font-semibold text-admin-900">Orders Over Time</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={d.orders_over_time}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis dataKey="label" tick={{ fontSize: 12 }} stroke="#94a3b8" />
                <YAxis tick={{ fontSize: 12 }} stroke="#94a3b8" />
                <Tooltip
                  contentStyle={{
                    borderRadius: '12px',
                    border: '1px solid #e2e8f0',
                    boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="value"
                  stroke="#6366f1"
                  strokeWidth={2}
                  dot={{ fill: '#6366f1', strokeWidth: 2 }}
                  activeDot={{ r: 6 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="card p-6">
            <h3 className="mb-4 text-lg font-semibold text-admin-900">Revenue Breakdown</h3>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={d.revenue_breakdown}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {d.revenue_breakdown.map((entry: any, index: number) => (
                    <Cell key={entry.name} fill={entry.color || COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    borderRadius: '12px',
                    border: '1px solid #e2e8f0',
                  }}
                  formatter={(value: number) => formatCurrency(value)}
                />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="grid gap-6 lg:grid-cols-2">
          <div className="card">
            <div className="card-header">
              <h3 className="text-lg font-semibold text-admin-900">Recent Orders</h3>
            </div>
            <div className="p-0">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-admin-50">
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">ID</th>
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Customer</th>
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Status</th>
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Total</th>
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Time</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-admin-100">
                  {(d.recent_orders || []).slice(0, 10).map((order: any) => (
                    <tr key={order.id} className="hover:bg-admin-50">
                      <td className="px-4 py-3 font-medium text-admin-900">#{order.order_number}</td>
                      <td className="px-4 py-3 text-admin-700">{order.customer_name}</td>
                      <td className="px-4 py-3">
                        <StatusBadge status={order.status} type="order" />
                      </td>
                      <td className="px-4 py-3 font-medium text-admin-900">{formatCurrency(order.total)}</td>
                      <td className="px-4 py-3 text-admin-500">{formatDateTime(order.created_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div className="card p-6">
            <h3 className="mb-4 text-lg font-semibold text-admin-900">Top Restaurants</h3>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={(d.top_restaurants || []).slice(0, 8)}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis dataKey="name" tick={{ fontSize: 11 }} stroke="#94a3b8" angle={-20} textAnchor="end" />
                <YAxis tick={{ fontSize: 12 }} stroke="#94a3b8" />
                <Tooltip
                  contentStyle={{
                    borderRadius: '12px',
                    border: '1px solid #e2e8f0',
                  }}
                  formatter={(value: number) => formatCurrency(value)}
                />
                <Bar dataKey="revenue" fill="#6366f1" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </ErrorBoundary>
  );
}
