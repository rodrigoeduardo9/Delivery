import { useState, useMemo, useCallback } from 'react';
import {
  BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import { BarChart3, TrendingUp, DollarSign, Bike, Store } from 'lucide-react';
import DateRangePicker from '../components/ui/DateRangePicker';
import ExportButton from '../components/ui/ExportButton';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import { formatCurrency, formatNumber } from '../utils/formatters';
import { exportToCSV } from '../utils/exportHelpers';

type ReportTab = 'overview' | 'orders' | 'revenue' | 'drivers' | 'restaurants';

const TABS: { key: ReportTab; label: string }[] = [
  { key: 'overview', label: 'Overview' },
  { key: 'orders', label: 'Orders' },
  { key: 'revenue', label: 'Revenue' },
  { key: 'drivers', label: 'Drivers' },
  { key: 'restaurants', label: 'Restaurants' },
];

const COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6', '#f97316'];
const PIE_COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899'];

const monthlyData = [
  { month: 'Jan', orders: 1250, revenue: 185000, delivery_time: 32 },
  { month: 'Feb', orders: 1380, revenue: 202000, delivery_time: 30 },
  { month: 'Mar', orders: 1420, revenue: 218000, delivery_time: 31 },
  { month: 'Apr', orders: 1510, revenue: 235000, delivery_time: 29 },
  { month: 'May', orders: 1680, revenue: 252000, delivery_time: 28 },
  { month: 'Jun', orders: 1750, revenue: 271000, delivery_time: 27 },
];

const orderStatusData = [
  { name: 'Delivered', value: 65 },
  { name: 'In Transit', value: 15 },
  { name: 'Preparing', value: 10 },
  { name: 'Pending', value: 7 },
  { name: 'Cancelled', value: 3 },
];

const revenueSplitData = [
  { name: 'Platform', value: 75 },
  { name: 'Restaurant', value: 25 },
];

const paymentMethods = [
  { name: 'Card', value: 55 },
  { name: 'Cash', value: 30 },
  { name: 'Wallet', value: 15 },
];

const topDrivers = [
  { name: 'Carlos López', deliveries: 145, rating: 4.9, earnings: 28500 },
  { name: 'María García', deliveries: 132, rating: 4.8, earnings: 26100 },
  { name: 'Juan Martínez', deliveries: 128, rating: 4.7, earnings: 24300 },
  { name: 'Ana Rodríguez', deliveries: 115, rating: 4.9, earnings: 22800 },
  { name: 'Pedro Sánchez', deliveries: 108, rating: 4.6, earnings: 21400 },
];

const topRestaurants = [
  { name: 'Pizza Express', orders: 1230, revenue: 184500, rating: 4.7 },
  { name: 'Sushi Master', orders: 980, revenue: 156800, rating: 4.8 },
  { name: 'Burger House', orders: 875, revenue: 131250, rating: 4.5 },
  { name: 'Taco Loco', orders: 820, revenue: 114800, rating: 4.6 },
  { name: 'Pasta Bella', orders: 740, revenue: 111000, rating: 4.7 },
];

export default function ReportsPage() {
  const [activeTab, setActiveTab] = useState<ReportTab>('overview');
  const [dateRange, setDateRange] = useState<{ start: Date | null; end: Date | null }>({ start: null, end: null });

  const handleExport = useCallback((format: 'csv' | 'pdf' | 'excel') => {
    const headers = ['Metric', 'Value'];
    const data = [
      { Metric: 'Total Orders', Value: '1,750' },
      { Metric: 'Total Revenue', Value: '$271,000' },
      { Metric: 'Avg Delivery Time', Value: '27 min' },
      { Metric: 'Active Drivers', Value: '48' },
      { Metric: 'Active Restaurants', Value: '156' },
    ];
    exportToCSV(data, headers, `report-${activeTab}`);
  }, [activeTab]);

  return (
    <ErrorBoundary>
      <div className="space-y-6">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-admin-900">Reports & Analytics</h1>
            <p className="text-admin-500">Platform performance metrics</p>
          </div>
          <div className="flex items-center gap-3">
            <DateRangePicker value={dateRange} onChange={setDateRange} />
            <ExportButton onExport={handleExport} />
          </div>
        </div>

        <div className="flex gap-1 rounded-xl bg-admin-100 p-1">
          {TABS.map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
                activeTab === tab.key
                  ? 'bg-white text-primary-700 shadow-sm'
                  : 'text-admin-600 hover:text-admin-900'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {activeTab === 'overview' && (
          <div className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <div className="card p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary-50 text-primary-600">
                    <BarChart3 className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm text-admin-500">Total Orders</p>
                    <p className="text-2xl font-bold">{formatNumber(1750)}</p>
                  </div>
                </div>
              </div>
              <div className="card p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-success-50 text-success-600">
                    <DollarSign className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm text-admin-500">Total Revenue</p>
                    <p className="text-2xl font-bold">{formatCurrency(271000)}</p>
                  </div>
                </div>
              </div>
              <div className="card p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-warning-50 text-warning-600">
                    <Bike className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm text-admin-500">Active Drivers</p>
                    <p className="text-2xl font-bold">48</p>
                  </div>
                </div>
              </div>
              <div className="card p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-50 text-indigo-600">
                    <Store className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm text-admin-500">Restaurants</p>
                    <p className="text-2xl font-bold">156</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="grid gap-6 lg:grid-cols-2">
              <div className="card p-6">
                <h3 className="mb-4 text-lg font-semibold">Orders & Revenue</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={monthlyData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                    <XAxis dataKey="month" stroke="#94a3b8" />
                    <YAxis stroke="#94a3b8" />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="orders" fill="#6366f1" radius={[4, 4, 0, 0]} name="Orders" />
                    <Bar dataKey="revenue" fill="#10b981" radius={[4, 4, 0, 0]} name="Revenue" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <div className="card p-6">
                <h3 className="mb-4 text-lg font-semibold">Average Delivery Time</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={monthlyData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                    <XAxis dataKey="month" stroke="#94a3b8" />
                    <YAxis stroke="#94a3b8" domain={[0, 40]} />
                    <Tooltip />
                    <Line type="monotone" dataKey="delivery_time" stroke="#f59e0b" strokeWidth={2} name="Minutes" />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'orders' && (
          <div className="grid gap-6 lg:grid-cols-2">
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Orders by Status</h3>
              <ResponsiveContainer width="100%" height={350}>
                <PieChart>
                  <Pie
                    data={orderStatusData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={120}
                    dataKey="value"
                    label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  >
                    {orderStatusData.map((_, index) => (
                      <Cell key={index} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Orders Over Time</h3>
              <ResponsiveContainer width="100%" height={350}>
                <LineChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="month" stroke="#94a3b8" />
                  <YAxis stroke="#94a3b8" />
                  <Tooltip />
                  <Line type="monotone" dataKey="orders" stroke="#6366f1" strokeWidth={2} dot={{ fill: '#6366f1' }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="card p-6 lg:col-span-2">
              <h3 className="mb-4 text-lg font-semibold">Average Delivery Time</h3>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="month" stroke="#94a3b8" />
                  <YAxis stroke="#94a3b8" />
                  <Tooltip />
                  <Bar dataKey="delivery_time" fill="#f59e0b" radius={[4, 4, 0, 0]} name="Avg minutes" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        )}

        {activeTab === 'revenue' && (
          <div className="grid gap-6 lg:grid-cols-2">
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Revenue Over Time</h3>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={monthlyData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="month" stroke="#94a3b8" />
                  <YAxis stroke="#94a3b8" />
                  <Tooltip formatter={(value: number) => formatCurrency(value)} />
                  <Line type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Revenue by Restaurant</h3>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={topRestaurants} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis type="number" stroke="#94a3b8" />
                  <YAxis dataKey="name" type="category" stroke="#94a3b8" width={100} />
                  <Tooltip formatter={(value: number) => formatCurrency(value)} />
                  <Bar dataKey="revenue" fill="#6366f1" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Payment Methods</h3>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie data={paymentMethods} cx="50%" cy="50%" outerRadius={100} dataKey="value" label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}>
                    {paymentMethods.map((_, index) => (
                      <Cell key={index} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Platform vs Restaurant Split</h3>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie data={revenueSplitData} cx="50%" cy="50%" innerRadius={60} outerRadius={100} dataKey="value" label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}>
                    {revenueSplitData.map((_, index) => (
                      <Cell key={index} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>
        )}

        {activeTab === 'drivers' && (
          <div className="space-y-6">
            <div className="card">
              <div className="card-header">
                <h3 className="text-lg font-semibold">Top Drivers</h3>
              </div>
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-admin-50">
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Driver</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Deliveries</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Rating</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Earnings</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {topDrivers.map((driver) => (
                    <tr key={driver.name} className="hover:bg-admin-50">
                      <td className="px-4 py-3 font-medium">{driver.name}</td>
                      <td className="px-4 py-3 text-right">{formatNumber(driver.deliveries)}</td>
                      <td className="px-4 py-3 text-right">{driver.rating.toFixed(1)}</td>
                      <td className="px-4 py-3 text-right font-medium">{formatCurrency(driver.earnings)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {activeTab === 'restaurants' && (
          <div className="space-y-6">
            <div className="card">
              <div className="card-header">
                <h3 className="text-lg font-semibold">Top Restaurants</h3>
              </div>
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-admin-50">
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Restaurant</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Orders</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Revenue</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Rating</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {topRestaurants.map((r) => (
                    <tr key={r.name} className="hover:bg-admin-50">
                      <td className="px-4 py-3 font-medium">{r.name}</td>
                      <td className="px-4 py-3 text-right">{formatNumber(r.orders)}</td>
                      <td className="px-4 py-3 text-right font-medium">{formatCurrency(r.revenue)}</td>
                      <td className="px-4 py-3 text-right">{r.rating.toFixed(1)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </ErrorBoundary>
  );
}
