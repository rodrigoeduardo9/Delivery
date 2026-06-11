import { useState, useMemo, useCallback, useEffect } from 'react';
import type { ColumnDef } from '@tanstack/react-table';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useApi, useMutation } from '../hooks/useApi';
import DataTable from '../components/ui/DataTable';
import StatusBadge from '../components/ui/StatusBadge';
import Modal from '../components/ui/Modal';
import ConfirmDialog from '../components/ui/ConfirmDialog';
import SearchInput from '../components/ui/SearchInput';
import FilterBar from '../components/ui/FilterBar';
import DateRangePicker from '../components/ui/DateRangePicker';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { formatCurrency, formatDateTime, formatRelativeTime } from '../utils/formatters';
import { Store, Bike, CreditCard, Clock, User } from 'lucide-react';
import type { Order, PaginatedResponse } from '../types';

const ORDER_STATUSES = ['pending', 'confirmed', 'preparing', 'picked_up', 'in_transit', 'delivered', 'cancelled', 'refunded'];

export default function OrdersPage() {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string | null>(null);
  const [dateRange, setDateRange] = useState<{ start: Date | null; end: Date | null }>({ start: null, end: null });
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [showDetail, setShowDetail] = useState(false);
  const [showCancel, setShowCancel] = useState(false);
  const [cancelReason, setCancelReason] = useState('');
  const [reassignDriver, setReassignDriver] = useState(false);
  const [selectedDriverId, setSelectedDriverId] = useState('');

  const { data, isLoading, error, refetch } = useApi<PaginatedResponse<Order>>('/orders', {
    params: {
      search,
      status: statusFilter,
      start_date: dateRange.start?.toISOString(),
      end_date: dateRange.end?.toISOString(),
    },
  });

  const { data: driversData } = useApi<PaginatedResponse<{ id: string; name: string }>>('/drivers', {
    params: { status: 'online', per_page: 100 },
  });

  const { mutate: updateOrder } = useMutation();

  useEffect(() => {
    const interval = setInterval(() => {
      refetch();
    }, 15000);
    return () => clearInterval(interval);
  }, [refetch]);

  const orders = useMemo(() => data?.data || [], [data]);
  const drivers = useMemo(() => driversData?.data || [], [driversData]);

  const handleCancel = useCallback(async () => {
    if (!selectedOrder || !cancelReason) return;
    try {
      await updateOrder('post', `/orders/${selectedOrder.id}/cancel`, {
        reason: cancelReason,
      });
      toast.success('Order cancelled');
      setShowCancel(false);
      setCancelReason('');
      refetch();
    } catch {
      toast.error('Failed to cancel order');
    }
  }, [selectedOrder, cancelReason, updateOrder, refetch]);

  const handleReassign = useCallback(async () => {
    if (!selectedOrder || !selectedDriverId) return;
    try {
      await updateOrder('post', `/orders/${selectedOrder.id}/reassign`, {
        driver_id: selectedDriverId,
      });
      toast.success('Driver reassigned');
      setReassignDriver(false);
      setSelectedDriverId('');
      refetch();
    } catch {
      toast.error('Failed to reassign driver');
    }
  }, [selectedOrder, selectedDriverId, updateOrder, refetch]);

  const statusChips = ORDER_STATUSES.map((status) => ({
    label: status.replace(/_/g, ' '),
    value: status,
    active: statusFilter === status,
    onClick: () => setStatusFilter(statusFilter === status ? null : status),
  }));

  const columns = useMemo<ColumnDef<Order>[]>(
    () => [
      {
        accessorKey: 'order_number',
        header: 'Order ID',
        cell: ({ getValue }) => (
          <span className="font-medium text-primary-600">#{getValue() as string}</span>
        ),
      },
      {
        accessorKey: 'customer_name',
        header: 'Customer',
        cell: ({ getValue }) => (
          <div className="flex items-center gap-2">
            <User className="h-4 w-4 text-admin-400" />
            <span>{getValue() as string}</span>
          </div>
        ),
      },
      {
        accessorKey: 'restaurant_name',
        header: 'Restaurant',
        cell: ({ getValue }) => (
          <div className="flex items-center gap-2">
            <Store className="h-4 w-4 text-admin-400" />
            <span>{getValue() as string}</span>
          </div>
        ),
      },
      {
        accessorKey: 'driver_name',
        header: 'Driver',
        cell: ({ getValue }) => (
          <div className="flex items-center gap-2">
            <Bike className="h-4 w-4 text-admin-400" />
            <span>{(getValue() as string) || '-'}</span>
          </div>
        ),
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ getValue }) => <StatusBadge status={getValue() as string} type="order" />,
      },
      {
        accessorKey: 'total',
        header: 'Total',
        cell: ({ getValue }) => <span className="font-semibold">{formatCurrency(getValue() as number)}</span>,
      },
      {
        accessorKey: 'created_at',
        header: 'Time',
        cell: ({ getValue }) => (
          <span className="text-admin-500 text-xs">{formatRelativeTime(getValue() as string)}</span>
        ),
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className="flex items-center gap-2">
            <button
              onClick={(e) => { e.stopPropagation(); setSelectedOrder(row.original); setShowDetail(true); }}
              className="btn-secondary btn-sm"
            >
              View
            </button>
            {(row.original.status === 'pending' || row.original.status === 'confirmed') ? (
              <button
                onClick={(e) => { e.stopPropagation(); setSelectedOrder(row.original); setShowCancel(true); }}
                className="btn-danger btn-sm"
              >
                Cancel
              </button>
            ) : null}
            {(row.original.status === 'confirmed' || row.original.status === 'preparing') ? (
              <button
                onClick={(e) => { e.stopPropagation(); setSelectedOrder(row.original); setReassignDriver(true); setSelectedDriverId(row.original.driver_id || ''); }}
                className="btn-secondary btn-sm"
              >
                Reassign
              </button>
            ) : null}
          </div>
        ),
      },
    ],
    []
  );

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-20">
        <p className="text-danger-600 mb-4">{error}</p>
        <button onClick={refetch} className="btn-primary">Retry</button>
      </div>
    );
  }

  return (
    <ErrorBoundary>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-admin-900">Orders</h1>
            <p className="text-admin-500">Track and manage all orders</p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-4">
          <div className="w-full sm:w-72">
            <SearchInput value={search} onChange={setSearch} placeholder="Search by order ID..." />
          </div>
          <DateRangePicker value={dateRange} onChange={setDateRange} />
        </div>

        <FilterBar chips={statusChips} onClearAll={() => setStatusFilter(null)} />

        <DataTable
          columns={columns}
          data={orders}
          isLoading={isLoading}
          emptyTitle="No orders found"
          emptyMessage="No orders match your current filters."
        />
      </div>

      <Modal
        isOpen={showDetail}
        onClose={() => setShowDetail(false)}
        title={`Order #${selectedOrder?.order_number || ''}`}
        size="xl"
      >
        {selectedOrder && (
          <div className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              <div className="rounded-lg bg-admin-50 p-4">
                <p className="text-xs text-admin-500 uppercase mb-1">Customer</p>
                <p className="font-medium">{selectedOrder.customer_name}</p>
                <p className="text-sm text-admin-500">{selectedOrder.customer_phone}</p>
              </div>
              <div className="rounded-lg bg-admin-50 p-4">
                <p className="text-xs text-admin-500 uppercase mb-1">Restaurant</p>
                <p className="font-medium">{selectedOrder.restaurant_name}</p>
              </div>
              <div className="rounded-lg bg-admin-50 p-4">
                <p className="text-xs text-admin-500 uppercase mb-1">Driver</p>
                <p className="font-medium">{selectedOrder.driver_name || 'Not assigned'}</p>
              </div>
              <div className="rounded-lg bg-admin-50 p-4">
                <p className="text-xs text-admin-500 uppercase mb-1">Payment</p>
                <p className="font-medium capitalize">{selectedOrder.payment_method}</p>
                <StatusBadge status={selectedOrder.payment_status} />
              </div>
              <div className="rounded-lg bg-admin-50 p-4">
                <p className="text-xs text-admin-500 uppercase mb-1">Status</p>
                <StatusBadge status={selectedOrder.status} type="order" />
              </div>
              <div className="rounded-lg bg-admin-50 p-4">
                <p className="text-xs text-admin-500 uppercase mb-1">Total</p>
                <p className="text-xl font-bold">{formatCurrency(selectedOrder.total)}</p>
              </div>
            </div>

            <div>
              <h4 className="font-semibold mb-3">Order Items</h4>
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-admin-50">
                    <th className="px-4 py-2 text-left text-xs font-semibold uppercase text-admin-500">Item</th>
                    <th className="px-4 py-2 text-right text-xs font-semibold uppercase text-admin-500">Qty</th>
                    <th className="px-4 py-2 text-right text-xs font-semibold uppercase text-admin-500">Price</th>
                    <th className="px-4 py-2 text-right text-xs font-semibold uppercase text-admin-500">Total</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {selectedOrder.items.map((item) => (
                    <tr key={item.id}>
                      <td className="px-4 py-2">{item.product_name}</td>
                      <td className="px-4 py-2 text-right">{item.quantity}</td>
                      <td className="px-4 py-2 text-right">{formatCurrency(item.unit_price)}</td>
                      <td className="px-4 py-2 text-right font-medium">{formatCurrency(item.total_price)}</td>
                    </tr>
                  ))}
                </tbody>
                <tfoot className="border-t font-medium">
                  <tr>
                    <td colSpan={3} className="px-4 py-2 text-right">Subtotal</td>
                    <td className="px-4 py-2 text-right">{formatCurrency(selectedOrder.subtotal)}</td>
                  </tr>
                  <tr className="text-admin-500">
                    <td colSpan={3} className="px-4 py-2 text-right">Delivery</td>
                    <td className="px-4 py-2 text-right">{formatCurrency(selectedOrder.delivery_fee)}</td>
                  </tr>
                  <tr className="text-admin-500">
                    <td colSpan={3} className="px-4 py-2 text-right">Discount</td>
                    <td className="px-4 py-2 text-right">-{formatCurrency(selectedOrder.discount)}</td>
                  </tr>
                  <tr className="text-lg">
                    <td colSpan={3} className="px-4 py-2 text-right">Total</td>
                    <td className="px-4 py-2 text-right">{formatCurrency(selectedOrder.total)}</td>
                  </tr>
                </tfoot>
              </table>
            </div>

            <div>
              <h4 className="font-semibold mb-3">Status Timeline</h4>
              <div className="space-y-3">
                {selectedOrder.timeline?.map((entry, idx) => (
                  <div key={idx} className="flex items-start gap-3">
                    <div className="flex flex-col items-center">
                      <div className={`h-3 w-3 rounded-full ${
                        idx === selectedOrder.timeline.length - 1 ? 'bg-primary-500' : 'bg-admin-300'
                      }`} />
                      {idx < selectedOrder.timeline.length - 1 && (
                        <div className="w-0.5 flex-1 bg-admin-200" />
                      )}
                    </div>
                    <div>
                      <p className="font-medium text-sm capitalize">{entry.status.replace(/_/g, ' ')}</p>
                      <p className="text-xs text-admin-500">{formatDateTime(entry.timestamp)}</p>
                      {entry.note && <p className="text-xs text-admin-600">{entry.note}</p>}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div>
              <h4 className="font-semibold mb-3">Delivery Address</h4>
              <p className="text-sm text-admin-700">{selectedOrder.customer_address}</p>
            </div>
          </div>
        )}
      </Modal>

      <Modal isOpen={showCancel} onClose={() => setShowCancel(false)} title="Cancel Order" size="sm">
        <div className="space-y-4">
          <div>
            <label className="label">Cancellation reason</label>
            <textarea
              value={cancelReason}
              onChange={(e) => setCancelReason(e.target.value)}
              className="input h-24 resize-none"
              placeholder="Enter reason for cancellation..."
            />
          </div>
          <div className="flex justify-end gap-3">
            <button onClick={() => setShowCancel(false)} className="btn-secondary">Keep Order</button>
            <button
              onClick={handleCancel}
              className="btn-danger"
              disabled={!cancelReason.trim()}
            >
              Cancel Order
            </button>
          </div>
        </div>
      </Modal>

      <Modal isOpen={reassignDriver} onClose={() => setReassignDriver(false)} title="Reassign Driver" size="sm">
        <div className="space-y-4">
          <div>
            <label className="label">Select Driver</label>
            <select
              value={selectedDriverId}
              onChange={(e) => setSelectedDriverId(e.target.value)}
              className="select"
            >
              <option value="">Choose a driver...</option>
              {drivers.map((d: any) => (
                <option key={d.id} value={d.id}>{d.name}</option>
              ))}
            </select>
          </div>
          <div className="flex justify-end gap-3">
            <button onClick={() => setReassignDriver(false)} className="btn-secondary">Cancel</button>
            <button
              onClick={handleReassign}
              className="btn-primary"
              disabled={!selectedDriverId}
            >
              Reassign
            </button>
          </div>
        </div>
      </Modal>
    </ErrorBoundary>
  );
}
