import { useState, useMemo, useCallback } from 'react';
import type { ColumnDef } from '@tanstack/react-table';
import { Shield } from 'lucide-react';
import toast from 'react-hot-toast';
import { useApi, useMutation } from '../hooks/useApi';
import DataTable from '../components/ui/DataTable';
import StatusBadge from '../components/ui/StatusBadge';
import ConfirmDialog from '../components/ui/ConfirmDialog';
import Modal from '../components/ui/Modal';
import SearchInput from '../components/ui/SearchInput';
import FilterBar from '../components/ui/FilterBar';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import { formatDate, formatDateTime, formatNumber } from '../utils/formatters';
import { ROLE_LABELS } from '../config/constants';
import type { User as UserType, PaginatedResponse } from '../types';

export default function UsersPage() {
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<string | null>(null);
  const [selectedUser, setSelectedUser] = useState<UserType | null>(null);
  const [showRoleModal, setShowRoleModal] = useState(false);
  const [newRole, setNewRole] = useState('');
  const [confirmAction, setConfirmAction] = useState<{ type: string; id: string } | null>(null);

  const { data, isLoading, error, refetch } = useApi<PaginatedResponse<UserType>>('/users', {
    params: {
      search,
      role: roleFilter,
      status: statusFilter,
    },
  });

  const { mutate: updateUser } = useMutation();

  const users = useMemo(() => data?.data || [], [data]);

  const handleStatusAction = useCallback(
    async (action: 'suspend' | 'activate') => {
      if (!confirmAction) return;
      try {
        const endpoint = action === 'suspend'
          ? `/users/${confirmAction.id}/suspend`
          : `/users/${confirmAction.id}/activate`;
        await updateUser('post', endpoint);
        toast.success(`User ${action}d successfully`);
        refetch();
      } catch {
        toast.error(`Failed to ${action} user`);
      } finally {
        setConfirmAction(null);
      }
    },
    [confirmAction, updateUser, refetch]
  );

  const handleRoleChange = useCallback(async () => {
    if (!selectedUser || !newRole) return;
    try {
      await updateUser('patch', `/users/${selectedUser.id}/role`, { role: newRole });
      toast.success('Role updated');
      setShowRoleModal(false);
      refetch();
    } catch {
      toast.error('Failed to update role');
    }
  }, [selectedUser, newRole, updateUser, refetch]);

  const roleChips = Object.entries(ROLE_LABELS).map(([value, label]) => ({
    label,
    value,
    active: roleFilter === value,
    onClick: () => setRoleFilter(roleFilter === value ? null : value),
  }));

  const statusChips = [
    { label: 'All', value: '', active: !statusFilter, onClick: () => setStatusFilter(null) },
    { label: 'Active', value: 'active', active: statusFilter === 'active', onClick: () => setStatusFilter('active') },
    { label: 'Suspended', value: 'suspended', active: statusFilter === 'suspended', onClick: () => setStatusFilter('suspended') },
    { label: 'Inactive', value: 'inactive', active: statusFilter === 'inactive', onClick: () => setStatusFilter('inactive') },
  ];

  const columns = useMemo<ColumnDef<UserType>[]>(
    () => [
      {
        accessorKey: 'name',
        header: 'User',
        cell: ({ row }) => (
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary-50 text-primary-600 font-bold">
              {(row.original.name ?? '?').charAt(0)}
            </div>
            <div>
              <p className="font-medium text-admin-900">{row.original.name}</p>
              <p className="text-xs text-admin-500">{row.original.email}</p>
            </div>
          </div>
        ),
      },
      {
        accessorKey: 'role',
        header: 'Role',
        cell: ({ getValue }) => {
          const val = getValue() as string;
          return (
            <span className="badge bg-primary-100 text-primary-800">
              <Shield className="h-3 w-3 mr-1 inline" />
              {ROLE_LABELS[val] || val}
            </span>
          );
        },
      },
      {
        accessorKey: 'status',
        header: 'Status',
        cell: ({ getValue }) => <StatusBadge status={getValue() as string} />,
      },
      {
        accessorKey: 'orders_count',
        header: 'Orders',
        cell: ({ getValue }) => formatNumber(getValue() as number),
      },
      {
        accessorKey: 'created_at',
        header: 'Registered',
        cell: ({ getValue }) => formatDate(getValue() as string),
      },
      {
        accessorKey: 'last_login',
        header: 'Last Login',
        cell: ({ getValue }) => {
          const val = getValue() as string | null;
          return val ? formatDateTime(val) : '-';
        },
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className="flex items-center gap-2">
            <button
              onClick={(e) => { e.stopPropagation(); setSelectedUser(row.original); setNewRole(row.original.role); setShowRoleModal(true); }}
              className="btn-secondary btn-sm"
            >
              Change Role
            </button>
            {row.original.status === 'active' ? (
              <button
                onClick={(e) => { e.stopPropagation(); setConfirmAction({ type: 'suspend', id: row.original.id }); }}
                className="btn-warning btn-sm"
              >
                Suspend
              </button>
            ) : (
              <button
                onClick={(e) => { e.stopPropagation(); setConfirmAction({ type: 'activate', id: row.original.id }); }}
                className="btn-success btn-sm"
              >
                Activate
              </button>
            )}
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
            <h1 className="text-2xl font-bold text-admin-900">Users</h1>
            <p className="text-admin-500">Manage platform users</p>
          </div>
        </div>

        <div className="w-full sm:w-72">
          <SearchInput value={search} onChange={setSearch} placeholder="Search users..." />
        </div>

        <div className="space-y-2">
          <FilterBar chips={roleChips} onClearAll={() => setRoleFilter(null)} />
          <FilterBar chips={statusChips} onClearAll={() => setStatusFilter(null)} />
        </div>

        <DataTable
          columns={columns}
          data={users}
          isLoading={isLoading}
          emptyTitle="No users found"
          emptyMessage="No users match your current filters."
        />
      </div>

      <Modal isOpen={showRoleModal} onClose={() => setShowRoleModal(false)} title="Change User Role" size="sm">
        <div className="space-y-4">
          <div>
            <label className="label">New Role</label>
            <select value={newRole} onChange={(e) => setNewRole(e.target.value)} className="select">
              {Object.entries(ROLE_LABELS).map(([value, label]) => (
                <option key={value} value={value}>{label}</option>
              ))}
            </select>
          </div>
          <div className="flex justify-end gap-3">
            <button onClick={() => setShowRoleModal(false)} className="btn-secondary">Cancel</button>
            <button onClick={handleRoleChange} className="btn-primary">Save</button>
          </div>
        </div>
      </Modal>

      <ConfirmDialog
        isOpen={!!confirmAction}
        onClose={() => setConfirmAction(null)}
        onConfirm={() => handleStatusAction(confirmAction!.type as 'suspend' | 'activate')}
        title={`${confirmAction?.type === 'suspend' ? 'Suspend' : 'Activate'} User`}
        message={`Are you sure you want to ${confirmAction?.type} this user?`}
        variant={confirmAction?.type === 'suspend' ? 'danger' : 'info'}
        confirmLabel={confirmAction?.type === 'suspend' ? 'Suspend' : 'Activate'}
      />
    </ErrorBoundary>
  );
}
