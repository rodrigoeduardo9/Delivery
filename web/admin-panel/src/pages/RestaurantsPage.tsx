import { useState, useMemo, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import type { ColumnDef } from '@tanstack/react-table';
import { Star } from 'lucide-react';
import toast from 'react-hot-toast';
import { useApi, useMutation } from '../hooks/useApi';
import DataTable from '../components/ui/DataTable';
import StatusBadge from '../components/ui/StatusBadge';
import Modal from '../components/ui/Modal';
import ConfirmDialog from '../components/ui/ConfirmDialog';
import SearchInput from '../components/ui/SearchInput';
import FilterBar from '../components/ui/FilterBar';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import { formatCurrency, formatNumber } from '../utils/formatters';
import { RESTAURANT_CATEGORIES } from '../config/constants';
import type { Restaurant, PaginatedResponse } from '../types';

export default function RestaurantsPage() {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string | null>(null);
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null);
  const [selectedRestaurant, setSelectedRestaurant] = useState<Restaurant | null>(null);
  const [showDetail, setShowDetail] = useState(false);
  const [showCommission, setShowCommission] = useState(false);
  const [commissionValue, setCommissionValue] = useState(0);
  const [confirmAction, setConfirmAction] = useState<{ type: string; id: string } | null>(null);
  const [detailTab, setDetailTab] = useState<'info' | 'hours' | 'menu' | 'zones'>('info');

  const { data, isLoading, error, refetch } = useApi<PaginatedResponse<Restaurant>>('/restaurants', {
    params: { status: statusFilter, category: categoryFilter, search },
  });

  const { mutate: updateStatus } = useMutation();
  const { mutate: updateCommission } = useMutation();

  const restaurants = useMemo(() => data?.data || [], [data]);

  const handleStatusAction = useCallback(
    async (action: 'approve' | 'suspend' | 'activate') => {
      if (!confirmAction) return;
      try {
        const endpoint = {
          approve: `/restaurants/${confirmAction.id}/approve`,
          suspend: `/restaurants/${confirmAction.id}/suspend`,
          activate: `/restaurants/${confirmAction.id}/activate`,
        }[action];
        await updateStatus('post', endpoint);
        toast.success(`Restaurant ${action}d successfully`);
        refetch();
      } catch {
        toast.error(`Failed to ${action} restaurant`);
      } finally {
        setConfirmAction(null);
      }
    },
    [confirmAction, updateStatus, refetch]
  );

  const handleCommissionSave = useCallback(async () => {
    if (!selectedRestaurant) return;
    try {
      await updateCommission('patch', `/restaurants/${selectedRestaurant.id}/commission`, {
        commission_rate: commissionValue,
      });
      toast.success('Commission updated');
      setShowCommission(false);
      refetch();
    } catch {
      toast.error('Failed to update commission');
    }
  }, [selectedRestaurant, commissionValue, updateCommission, refetch]);

  const statusChips = [
    { label: 'All', value: '', active: !statusFilter, onClick: () => setStatusFilter(null) },
    { label: 'Active', value: 'active', active: statusFilter === 'active', onClick: () => setStatusFilter('active') },
    { label: 'Pending', value: 'pending', active: statusFilter === 'pending', onClick: () => setStatusFilter('pending') },
    { label: 'Suspended', value: 'suspended', active: statusFilter === 'suspended', onClick: () => setStatusFilter('suspended') },
    { label: 'Inactive', value: 'inactive', active: statusFilter === 'inactive', onClick: () => setStatusFilter('inactive') },
  ];

  const categoryChips = RESTAURANT_CATEGORIES.map((cat) => ({
    label: cat,
    value: cat,
    active: categoryFilter === cat,
    onClick: () => setCategoryFilter(categoryFilter === cat ? null : cat),
  }));

  const columns = useMemo<ColumnDef<Restaurant>[]>(
    () => [
      {
        accessorKey: 'name',
        header: 'Restaurant',
        cell: ({ row }) => (
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary-50 text-primary-600 font-bold">
              {row.original.name.charAt(0)}
            </div>
            <div>
              <p className="font-medium text-admin-900">{row.original.name}</p>
              <p className="text-xs text-admin-500">{row.original.owner}</p>
            </div>
          </div>
        ),
      },
      {
        accessorKey: 'category',
        header: 'Category',
        cell: ({ getValue }) => (
          <span className="text-sm text-admin-600">{getValue() as string}</span>
        ),
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ getValue }) => <StatusBadge status={getValue() as string} />,
      },
      {
        accessorKey: 'rating',
        header: 'Rating',
        cell: ({ getValue }) => {
          const val = getValue() as number;
          return (
            <div className="flex items-center gap-1">
              <Star className="h-3.5 w-3.5 text-warning-500 fill-warning-500" />
              <span className="font-medium">{val?.toFixed(1) || '-'}</span>
            </div>
          );
        },
      },
      {
        accessorKey: 'orders_today',
        header: 'Orders Today',
        cell: ({ getValue }) => formatNumber(getValue() as number),
      },
      {
        accessorKey: 'revenue_today',
        header: 'Revenue',
        cell: ({ getValue }) => formatCurrency(getValue() as number),
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className="flex items-center gap-2">
            {row.original.status === 'pending' && (
              <button
                onClick={(e) => { e.stopPropagation(); setConfirmAction({ type: 'approve', id: row.original.id }); }}
                className="btn-success btn-sm"
              >
                Approve
              </button>
            )}
            {row.original.status === 'active' && (
              <button
                onClick={(e) => { e.stopPropagation(); setConfirmAction({ type: 'suspend', id: row.original.id }); }}
                className="btn-warning btn-sm"
              >
                Suspend
              </button>
            )}
            <button
              onClick={(e) => { e.stopPropagation(); navigate(`/restaurants/${row.original.id}`); }}
              className="btn-secondary btn-sm"
            >
              View
            </button>
            <button
              onClick={(e) => { e.stopPropagation(); setSelectedRestaurant(row.original); setCommissionValue(row.original.commission_rate); setShowCommission(true); }}
              className="btn-secondary btn-sm"
            >
              Commission
            </button>
          </div>
        ),
      },
    ],
    [navigate]
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
            <h1 className="text-2xl font-bold text-admin-900">Restaurants</h1>
            <p className="text-admin-500">Manage all restaurant partners</p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-4">
          <div className="w-full sm:w-72">
            <SearchInput value={search} onChange={setSearch} placeholder="Search restaurants..." />
          </div>
        </div>

        <div className="space-y-2">
          <FilterBar chips={statusChips} onClearAll={() => setStatusFilter(null)} />
          <FilterBar chips={categoryChips} onClearAll={() => setCategoryFilter(null)} />
        </div>

        <DataTable
          columns={columns}
          data={restaurants}
          isLoading={isLoading}
          searchable={false}
          onRowClick={(row) => navigate(`/restaurants/${row.id}`)}
          emptyTitle="No restaurants found"
          emptyMessage="No restaurants match your current filters."
        />
      </div>

      <ConfirmDialog
        isOpen={!!confirmAction}
        onClose={() => setConfirmAction(null)}
        onConfirm={() => handleStatusAction(confirmAction!.type as 'approve' | 'suspend')}
        title={`${confirmAction?.type === 'approve' ? 'Approve' : 'Suspend'} Restaurant`}
        message={`Are you sure you want to ${confirmAction?.type} this restaurant?`}
        variant={confirmAction?.type === 'suspend' ? 'danger' : 'info'}
        confirmLabel={confirmAction?.type === 'approve' ? 'Approve' : 'Suspend'}
      />

      <Modal isOpen={showCommission} onClose={() => setShowCommission(false)} title="Edit Commission" size="sm">
        <div className="space-y-4">
          <div>
            <label className="label">Commission Rate (%)</label>
            <input
              type="number"
              value={commissionValue}
              onChange={(e) => setCommissionValue(Number(e.target.value))}
              min={0}
              max={100}
              step={0.5}
              className="input"
            />
          </div>
          <div className="flex justify-end gap-3">
            <button onClick={() => setShowCommission(false)} className="btn-secondary">
              Cancel
            </button>
            <button onClick={handleCommissionSave} className="btn-primary">
              Save
            </button>
          </div>
        </div>
      </Modal>
    </ErrorBoundary>
  );
}
