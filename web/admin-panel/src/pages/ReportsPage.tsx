import { useState, useMemo, useCallback, useEffect } from 'react';
import {
  BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend,
} from 'recharts';
import { BarChart3, TrendingUp, DollarSign, Bike, Store } from 'lucide-react';
import DateRangePicker from '../components/ui/DateRangePicker';
import ExportButton from '../components/ui/ExportButton';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import { useApi } from '../hooks/useApi';
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

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export default function ReportsPage() {
  const [activeTab, setActiveTab] = useState<ReportTab>('overview');
  const [dateRange, setDateRange] = useState<{ start: Date | null; end: Date | null }>({ start: null, end: null });
  const params = dateRange.start && dateRange.end ? `?start_date=${dateRange.start.toISOString()}&end_date=${dateRange.end.toISOString()}` : '';

  const { data: overview, isLoading: loadingOverview } = useApi<any>(activeTab === 'overview' ? `/reports/admin/overview` : null);
  const { data: revenueReport, isLoading: loadingRevenue } = useApi<any>(activeTab === 'revenue' ? `/reports/admin/revenue${params}` : null);
  const { data: driverData } = useApi<any>(activeTab === 'drivers' ? '/reports/admin/drivers' : null);
  const { data: restaurantData } = useApi<any>(activeTab === 'restaurants' ? '/reports/admin/restaurants' : null);
  const { data: orderReport } = useApi<any>(activeTab === 'orders' ? `/reports/admin/orders${params}` : null);

  const overviewData = overview?.data;
  const revenueData = revenueReport?.data;
  const drivers = driverData?.data || [];
  const restaurantsData = restaurantData?.data || [];
  const ordersReportData = orderReport?.data || [];

  const monthlyChartData = useMemo(() => {
    if (!revenueData?.daily) return [];
    return revenueData.daily.map((d: any) => {
      const date = new Date(d.date);
      return {
        month: MONTHS[date.getMonth()],
        orders: Number(d.order_count),
        revenue: Number(d.revenue),
      };
    }).reverse();
  }, [revenueData]);

  const handleExport = useCallback((format: 'csv' | 'pdf' | 'excel') => {
    const headers = ['Metric', 'Value'];
    const data = overviewData
      ? [
          { Metric: 'Total Orders', Value: String(overviewData.orders_last_7d || 0) },
          { Metric: 'Total Revenue (30d)', Value: formatCurrency(overviewData.revenue_last_30d || 0) },
          { Metric: 'Pending Orders', Value: String(overviewData.pending_orders || 0) },
          { Metric: 'Active Drivers', Value: String(overviewData.available_drivers || 0) },
          { Metric: 'Restaurants', Value: String(overviewData.total_restaurants || 0) },
        ]
      : [{ Metric: 'N/A', Value: 'N/A' }];
    exportToCSV(data, headers, `report-${activeTab}`);
  }, [activeTab, overviewData]);

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

        {loadingOverview && activeTab === 'overview' ? <LoadingSpinner /> : activeTab === 'overview' && (
          <div className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              <div className="card p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary-50 text-primary-600">
                    <BarChart3 className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm text-admin-500">Orders (7d)</p>
                    <p className="text-2xl font-bold">{formatNumber(overviewData?.orders_last_7d || 0)}</p>
                  </div>
                </div>
              </div>
              <div className="card p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-success-50 text-success-600">
                    <DollarSign className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm text-admin-500">Revenue (30d)</p>
                    <p className="text-2xl font-bold">{formatCurrency(overviewData?.revenue_last_30d || 0)}</p>
                  </div>
                </div>
              </div>
              <div className="card p-6">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-warning-50 text-warning-600">
                    <Bike className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm text-admin-500">Available Drivers</p>
                    <p className="text-2xl font-bold">{overviewData?.available_drivers || 0}</p>
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
                    <p className="text-2xl font-bold">{overviewData?.total_restaurants || 0}</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="grid gap-6 lg:grid-cols-2">
              <div className="card p-6">
                <h3 className="mb-4 text-lg font-semibold">Orders & Revenue (Daily)</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={monthlyChartData}>
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
                <h3 className="mb-4 text-lg font-semibold">Revenue Summary</h3>
                {revenueData?.summary && (
                  <div className="space-y-3">
                    <div className="flex justify-between">
                      <span className="text-admin-500">Total Orders</span>
                      <span className="font-semibold">{formatNumber(revenueData.summary.total_orders)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-admin-500">Total Revenue</span>
                      <span className="font-semibold">{formatCurrency(revenueData.summary.total_revenue)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-admin-500">Platform Fees</span>
                      <span className="font-semibold">{formatCurrency(revenueData.summary.total_platform_fees)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-admin-500">Avg Order Value</span>
                      <span className="font-semibold">{formatCurrency(revenueData.summary.avg_order_value)}</span>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {activeTab === 'orders' && (
          <div className="grid gap-6 lg:grid-cols-2">
            <div className="card p-6 lg:col-span-2">
              <h3 className="mb-4 text-lg font-semibold">Recent Orders</h3>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="bg-admin-50">
                      <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Order #</th>
                      <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Customer</th>
                      <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Restaurant</th>
                      <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Total</th>
                      <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Status</th>
                      <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Date</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y">
                    {ordersReportData.length === 0 && (
                      <tr><td colSpan={6} className="px-4 py-8 text-center text-admin-400">No orders found</td></tr>
                    )}
                    {ordersReportData.map((o: any) => (
                      <tr key={o.id} className="hover:bg-admin-50">
                        <td className="px-4 py-3 font-medium">{o.order_number}</td>
                        <td className="px-4 py-3">{o.customer_name}</td>
                        <td className="px-4 py-3">{o.restaurant_name}</td>
                        <td className="px-4 py-3 text-right font-medium">{formatCurrency(o.total)}</td>
                        <td className="px-4 py-3">
                          <span className="badge badge-{o.status}">{o.status}</span>
                        </td>
                        <td className="px-4 py-3 text-admin-500">{new Date(o.created_at).toLocaleDateString()}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'revenue' && (
          <div className="grid gap-6 lg:grid-cols-2">
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Revenue Over Time</h3>
              {loadingRevenue ? <LoadingSpinner /> : (
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart data={monthlyChartData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                    <XAxis dataKey="month" stroke="#94a3b8" />
                    <YAxis stroke="#94a3b8" />
                    <Tooltip formatter={(value: number) => formatCurrency(value)} />
                    <Line type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={2} />
                  </LineChart>
                </ResponsiveContainer>
              )}
            </div>
            <div className="card p-6">
              <h3 className="mb-4 text-lg font-semibold">Revenue Summary</h3>
              {revenueData?.summary && (
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-admin-500">Total Orders</span>
                    <span className="font-semibold">{formatNumber(revenueData.summary.total_orders)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-admin-500">Total Revenue</span>
                    <span className="font-semibold">{formatCurrency(revenueData.summary.total_revenue)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-admin-500">Platform Fees</span>
                    <span className="font-semibold">{formatCurrency(revenueData.summary.total_platform_fees)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-admin-500">Avg Order Value</span>
                    <span className="font-semibold">{formatCurrency(revenueData.summary.avg_order_value)}</span>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'drivers' && (
          <div className="space-y-6">
            <div className="card">
              <div className="card-header">
                <h3 className="text-lg font-semibold">Driver Performance</h3>
              </div>
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-admin-50">
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Driver</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Deliveries</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Rating</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Earnings</th>
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {drivers.length === 0 && (
                    <tr><td colSpan={5} className="px-4 py-8 text-center text-admin-400">No drivers found</td></tr>
                  )}
                  {drivers.map((d: any) => (
                    <tr key={d.id} className="hover:bg-admin-50">
                      <td className="px-4 py-3 font-medium">{`${d.first_name || ''} ${d.last_name || ''}`.trim()}</td>
                      <td className="px-4 py-3 text-right">{formatNumber(d.total_deliveries || 0)}</td>
                      <td className="px-4 py-3 text-right">{d.rating ? Number(d.rating).toFixed(1) : 'N/A'}</td>
                      <td className="px-4 py-3 text-right font-medium">{formatCurrency(d.total_earned || 0)}</td>
                      <td className="px-4 py-3">{d.status}</td>
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
                <h3 className="text-lg font-semibold">Restaurant Performance</h3>
              </div>
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-admin-50">
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Restaurant</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Orders</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Revenue</th>
                    <th className="px-4 py-3 text-right text-xs font-semibold uppercase text-admin-500">Rating</th>
                    <th className="px-4 py-3 text-left text-xs font-semibold uppercase text-admin-500">Owner</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {restaurantsData.length === 0 && (
                    <tr><td colSpan={5} className="px-4 py-8 text-center text-admin-400">No restaurants found</td></tr>
                  )}
                  {restaurantsData.map((r: any) => (
                    <tr key={r.id} className="hover:bg-admin-50">
                      <td className="px-4 py-3 font-medium">{r.name}</td>
                      <td className="px-4 py-3 text-right">{formatNumber(r.total_orders || 0)}</td>
                      <td className="px-4 py-3 text-right font-medium">{formatCurrency(r.total_revenue || 0)}</td>
                      <td className="px-4 py-3 text-right">{r.rating ? Number(r.rating).toFixed(1) : 'N/A'}</td>
                      <td className="px-4 py-3">{r.owner_name}</td>
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
