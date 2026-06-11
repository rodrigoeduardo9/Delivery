import { useState, useMemo, useCallback } from 'react';
import type { ColumnDef } from '@tanstack/react-table';
import { useApi } from '../hooks/useApi';
import DataTable from '../components/ui/DataTable';
import Modal from '../components/ui/Modal';
import DateRangePicker from '../components/ui/DateRangePicker';
import FilterBar from '../components/ui/FilterBar';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import { formatDateTime } from '../utils/formatters';
import type { AuditLog, PaginatedResponse } from '../types';

const ACTION_TYPES = [
  'create', 'update', 'delete', 'login', 'logout',
  'approve', 'reject', 'suspend', 'activate', 'verify',
];

export default function AuditLogPage() {
  const [search, setSearch] = useState('');
  const [actionFilter, setActionFilter] = useState<string | null>(null);
  const [dateRange, setDateRange] = useState<{ start: Date | null; end: Date | null }>({ start: null, end: null });
  const [selectedLog, setSelectedLog] = useState<AuditLog | null>(null);
  const [showDetail, setShowDetail] = useState(false);

  const { data, isLoading, error, refetch } = useApi<PaginatedResponse<AuditLog>>('/audit-logs', {
    params: {
      search,
      action: actionFilter,
      start_date: dateRange.start?.toISOString(),
      end_date: dateRange.end?.toISOString(),
    },
  });

  const logs = useMemo(() => data?.data || [], [data]);

  const actionChips = [
    { label: 'All', value: '', active: !actionFilter, onClick: () => setActionFilter(null) },
    ...ACTION_TYPES.map((action) => ({
      label: action.charAt(0).toUpperCase() + action.slice(1),
      value: action,
      active: actionFilter === action,
      onClick: () => setActionFilter(actionFilter === action ? null : action),
    })),
  ];

  const columns = useMemo<ColumnDef<AuditLog>[]>(
    () => [
      {
        accessorKey: 'created_at',
        header: 'Timestamp',
        cell: ({ getValue }) => (
          <span className="text-sm text-admin-700 whitespace-nowrap">
            {formatDateTime(getValue() as string)}
          </span>
        ),
      },
      {
        accessorKey: 'admin_name',
        header: 'Admin',
        cell: ({ getValue }) => (
          <span className="font-medium text-admin-900">{getValue() as string}</span>
        ),
      },
      {
        accessorKey: 'action',
        header: 'Action',
        cell: ({ getValue }) => {
          const action = getValue() as string;
          const colors: Record<string, string> = {
            create: 'bg-success-100 text-success-800',
            update: 'bg-primary-100 text-primary-800',
            delete: 'bg-danger-100 text-danger-800',
            login: 'bg-blue-100 text-blue-800',
            logout: 'bg-admin-100 text-admin-600',
            approve: 'bg-success-100 text-success-800',
            reject: 'bg-danger-100 text-danger-800',
            suspend: 'bg-warning-100 text-warning-800',
            activate: 'bg-success-100 text-success-800',
            verify: 'bg-success-100 text-success-800',
          };
          return (
            <span className={`badge ${colors[action] || 'bg-admin-100 text-admin-600'}`}>
              {action}
            </span>
          );
        },
      },
      {
        accessorKey: 'entity_type',
        header: 'Entity',
        cell: ({ getValue }) => (
          <span className="capitalize text-admin-700">{(getValue() as string).replace(/_/g, ' ')}</span>
        ),
      },
      {
        accessorKey: 'entity_id',
        header: 'Entity ID',
        cell: ({ getValue }) => (
          <span className="text-xs font-mono text-admin-500">{getValue() as string}</span>
        ),
      },
      {
        accessorKey: 'ip_address',
        header: 'IP Address',
        cell: ({ getValue }) => <span className="text-sm text-admin-500">{getValue() as string}</span>,
      },
      {
        id: 'actions',
        header: '',
        cell: ({ row }) => (
          <button
            onClick={(e) => { e.stopPropagation(); setSelectedLog(row.original); setShowDetail(true); }}
            className="btn-secondary btn-sm"
          >
            View
          </button>
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
            <h1 className="text-2xl font-bold text-admin-900">Audit Log</h1>
            <p className="text-admin-500">Track all administrative actions</p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-4">
          <DateRangePicker value={dateRange} onChange={setDateRange} />
        </div>

        <FilterBar chips={actionChips} onClearAll={() => setActionFilter(null)} />

        {isLoading ? (
          <div className="flex justify-center py-12">
            <div className="h-10 w-10 animate-spin rounded-full border-4 border-primary-500 border-t-transparent" />
          </div>
        ) : (
          <DataTable
            columns={columns}
            data={logs}
            isLoading={false}
            emptyTitle="No audit logs found"
            emptyMessage="No logs match your current filters."
            onRowClick={(row) => { setSelectedLog(row); setShowDetail(true); }}
          />
        )}
      </div>

      <Modal
        isOpen={showDetail}
        onClose={() => setShowDetail(false)}
        title="Audit Log Details"
        size="lg"
      >
        {selectedLog && (
          <div className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div>
                <p className="text-xs text-admin-500 uppercase mb-1">Admin</p>
                <p className="font-medium">{selectedLog.admin_name}</p>
              </div>
              <div>
                <p className="text-xs text-admin-500 uppercase mb-1">Action</p>
                <p className="font-medium capitalize">{selectedLog.action}</p>
              </div>
              <div>
                <p className="text-xs text-admin-500 uppercase mb-1">Entity</p>
                <p className="font-medium capitalize">{selectedLog.entity_type.replace(/_/g, ' ')}</p>
              </div>
              <div>
                <p className="text-xs text-admin-500 uppercase mb-1">Entity ID</p>
                <p className="font-mono text-sm">{selectedLog.entity_id}</p>
              </div>
              <div>
                <p className="text-xs text-admin-500 uppercase mb-1">IP Address</p>
                <p className="font-medium">{selectedLog.ip_address}</p>
              </div>
              <div>
                <p className="text-xs text-admin-500 uppercase mb-1">Timestamp</p>
                <p className="font-medium">{formatDateTime(selectedLog.created_at)}</p>
              </div>
            </div>

            {(selectedLog.old_values || selectedLog.new_values) && (
              <div className="grid gap-4 sm:grid-cols-2">
                {selectedLog.old_values && (
                  <div>
                    <h4 className="font-semibold text-sm text-admin-700 mb-2">Previous Values</h4>
                    <div className="rounded-lg bg-admin-50 p-4">
                      <pre className="text-xs whitespace-pre-wrap font-mono">
                        {JSON.stringify(selectedLog.old_values, null, 2)}
                      </pre>
                    </div>
                  </div>
                )}
                {selectedLog.new_values && (
                  <div>
                    <h4 className="font-semibold text-sm text-admin-700 mb-2">New Values</h4>
                    <div className="rounded-lg bg-admin-50 p-4">
                      <pre className="text-xs whitespace-pre-wrap font-mono">
                        {JSON.stringify(selectedLog.new_values, null, 2)}
                      </pre>
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </Modal>
    </ErrorBoundary>
  );
}
