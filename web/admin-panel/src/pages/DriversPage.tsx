import { useState, useMemo, useCallback } from 'react';
import type { ColumnDef } from '@tanstack/react-table';
import { Bike, Star, MapPin, FileCheck } from 'lucide-react';
import toast from 'react-hot-toast';
import { useApi, useMutation } from '../hooks/useApi';
import DataTable from '../components/ui/DataTable';
import StatusBadge from '../components/ui/StatusBadge';
import Modal from '../components/ui/Modal';
import ConfirmDialog from '../components/ui/ConfirmDialog';
import SearchInput from '../components/ui/SearchInput';
import FilterBar from '../components/ui/FilterBar';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { formatCurrency, formatNumber, formatDate } from '../utils/formatters';
import { VEHICLE_TYPES } from '../config/constants';
import type { Driver, DriverDocument, PaginatedResponse } from '../types';

export default function DriversPage() {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string | null>(null);
  const [vehicleFilter, setVehicleFilter] = useState<string | null>(null);
  const [selectedDriver, setSelectedDriver] = useState<Driver | null>(null);
  const [showDocuments, setShowDocuments] = useState(false);
  const [showLocation, setShowLocation] = useState(false);
  const [confirmAction, setConfirmAction] = useState<{ type: string; id: string } | null>(null);
  const [previewDoc, setPreviewDoc] = useState<DriverDocument | null>(null);

  const { data, isLoading, error, refetch } = useApi<PaginatedResponse<Driver>>('/drivers/admin', {
    params: { status: statusFilter, vehicle_type: vehicleFilter, search },
  });

  const { mutate: updateStatus } = useMutation();
  const { mutate: verifyDocument } = useMutation();

  const drivers = useMemo(() => data?.data || [], [data]);

  const handleStatusAction = useCallback(
    async (action: 'verify' | 'suspend') => {
      if (!confirmAction) return;
      try {
        const endpoint = action === 'verify'
          ? `/drivers/admin/${confirmAction.id}/verify`
          : `/drivers/admin/${confirmAction.id}/status`;
        await updateStatus('post', endpoint);
        toast.success(`Driver ${action === 'verify' ? 'verified' : 'suspended'} successfully`);
        refetch();
      } catch {
        toast.error(`Failed to ${action} driver`);
      } finally {
        setConfirmAction(null);
      }
    },
    [confirmAction, updateStatus, refetch]
  );

  const handleDocumentAction = useCallback(
    async (docId: string, action: 'verify' | 'reject') => {
      if (!selectedDriver) return;
      try {
        await verifyDocument('post', `/drivers/${selectedDriver.id}/documents/${docId}/${action}`);
        toast.success(`Document ${action}ed`);
        refetch();
      } catch {
        toast.error(`Failed to ${action} document`);
      }
    },
    [selectedDriver, verifyDocument, refetch]
  );

  const statusChips = [
    { label: 'All', value: '', active: !statusFilter, onClick: () => setStatusFilter(null) },
    { label: 'Online', value: 'online', active: statusFilter === 'online', onClick: () => setStatusFilter('online') },
    { label: 'Offline', value: 'offline', active: statusFilter === 'offline', onClick: () => setStatusFilter('offline') },
    { label: 'Busy', value: 'busy', active: statusFilter === 'busy', onClick: () => setStatusFilter('busy') },
    { label: 'Suspended', value: 'suspended', active: statusFilter === 'suspended', onClick: () => setStatusFilter('suspended') },
  ];

  const vehicleChips = VEHICLE_TYPES.map((v) => ({
    label: v.charAt(0).toUpperCase() + v.slice(1),
    value: v,
    active: vehicleFilter === v,
    onClick: () => setVehicleFilter(vehicleFilter === v ? null : v),
  }));

  const columns = useMemo<ColumnDef<Driver>[]>(
    () => [
      {
        accessorKey: 'name',
        header: 'Driver',
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
        accessorKey: 'vehicle_type',
        header: 'Vehicle',
        cell: ({ getValue }) => (
          <div className="flex items-center gap-2">
            <Bike className="h-4 w-4 text-admin-400" />
            <span className="text-sm capitalize">{getValue() as string}</span>
          </div>
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
              <span className="font-medium">{val != null ? Number(val).toFixed(1) : '-'}</span>
            </div>
          );
        },
      },
      {
        accessorKey: 'deliveries_today',
        header: 'Deliveries',
        cell: ({ getValue }) => formatNumber(getValue() as number),
      },
      {
        accessorKey: 'earnings_today',
        header: 'Earnings',
        cell: ({ getValue }) => formatCurrency(getValue() as number),
      },
      {
        accessorKey: 'is_verified',
        header: 'Docs',
        cell: ({ getValue }) => {
          const val = getValue() as boolean;
          return (
            <span className={`badge ${val ? 'bg-success-100 text-success-800' : 'bg-warning-100 text-warning-800'}`}>
              {val ? 'Verified' : 'Pending'}
            </span>
          );
        },
      },
      {
        id: 'actions',
        header: 'Actions',
        cell: ({ row }) => (
          <div className="flex items-center gap-2">
            {!row.original.is_verified && (
              <button
                onClick={(e) => { e.stopPropagation(); setConfirmAction({ type: 'verify', id: row.original.id }); }}
                className="btn-success btn-sm"
              >
                Verify
              </button>
            )}
            {row.original.status !== 'suspended' && (
              <button
                onClick={(e) => { e.stopPropagation(); setConfirmAction({ type: 'suspend', id: row.original.id }); }}
                className="btn-warning btn-sm"
              >
                Suspend
              </button>
            )}
            <button
              onClick={(e) => { e.stopPropagation(); setSelectedDriver(row.original); setShowDocuments(true); }}
              className="btn-secondary btn-sm"
            >
              <FileCheck className="h-3.5 w-3.5" />
              Docs
            </button>
            <button
              onClick={(e) => { e.stopPropagation(); setSelectedDriver(row.original); setShowLocation(true); }}
              className="btn-secondary btn-sm"
            >
              <MapPin className="h-3.5 w-3.5" />
              Map
            </button>
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
            <h1 className="text-2xl font-bold text-admin-900">Drivers</h1>
            <p className="text-admin-500">Manage delivery drivers</p>
          </div>
        </div>

        <div className="w-full sm:w-72">
          <SearchInput value={search} onChange={setSearch} placeholder="Search drivers..." />
        </div>

        <div className="space-y-2">
          <FilterBar chips={statusChips} onClearAll={() => setStatusFilter(null)} />
          <FilterBar chips={vehicleChips} onClearAll={() => setVehicleFilter(null)} />
        </div>

        <DataTable
          columns={columns}
          data={drivers}
          isLoading={isLoading}
          emptyTitle="No drivers found"
          emptyMessage="No drivers match your current filters."
        />
      </div>

      <Modal
        isOpen={showDocuments}
        onClose={() => { setShowDocuments(false); setPreviewDoc(null); }}
        title={`Documents - ${selectedDriver?.name || ''}`}
        size="lg"
      >
        <div className="space-y-4">
          {selectedDriver?.documents?.length === 0 && (
            <p className="text-admin-500 text-center py-8">No documents uploaded yet.</p>
          )}
          {selectedDriver?.documents?.map((doc) => (
            <div key={doc.id} className="flex items-center justify-between rounded-lg border p-4">
              <div>
                <p className="font-medium text-admin-900 capitalize">{(doc.type || '').replace(/_/g, ' ')}</p>
                <p className="text-xs text-admin-500">Uploaded {formatDate(doc.uploaded_at)}</p>
                <StatusBadge status={doc.status} />
              </div>
              <div className="flex items-center gap-2">
                <button onClick={() => setPreviewDoc(doc)} className="btn-secondary btn-sm">
                  Preview
                </button>
                {doc.status === 'pending' && (
                  <>
                    <button onClick={() => handleDocumentAction(doc.id, 'verify')} className="btn-success btn-sm">
                      Approve
                    </button>
                    <button onClick={() => handleDocumentAction(doc.id, 'reject')} className="btn-danger btn-sm">
                      Reject
                    </button>
                  </>
                )}
              </div>
            </div>
          ))}

          {previewDoc && (
            <div className="mt-4 rounded-lg border overflow-hidden">
              <div className="flex items-center justify-between bg-admin-50 px-4 py-2">
                <span className="text-sm font-medium capitalize">{(previewDoc.type || '').replace(/_/g, ' ')}</span>
                <button onClick={() => setPreviewDoc(null)} className="text-admin-500 hover:text-admin-700">Close</button>
              </div>
              <div className="flex items-center justify-center bg-admin-100 p-8">
                <img src={previewDoc.url} alt="Document" className="max-h-80 rounded-lg shadow" onError={(e) => { e.currentTarget.src = ''; e.currentTarget.alt = 'Image not available'; }} />
              </div>
            </div>
          )}
        </div>
      </Modal>

      <Modal
        isOpen={showLocation}
        onClose={() => setShowLocation(false)}
        title={`Location - ${selectedDriver?.name || ''}`}
        size="lg"
      >
        <div className="flex h-80 items-center justify-center rounded-lg bg-admin-100">
          {selectedDriver?.current_location ? (
            <div className="text-center">
              <MapPin className="mx-auto h-12 w-12 text-primary-500 mb-4" />
              <p className="font-medium">
                Lat: {selectedDriver.current_location.latitude != null ? Number(selectedDriver.current_location.latitude).toFixed(4) : '-'}, Lng: {selectedDriver.current_location.longitude != null ? Number(selectedDriver.current_location.longitude).toFixed(4) : '-'}
              </p>
              <p className="text-sm text-admin-500">
                Updated: {formatDate(selectedDriver.current_location.updated_at)}
              </p>
            </div>
          ) : (
            <div className="text-center text-admin-500">
              <MapPin className="mx-auto h-12 w-12 mb-4" />
              <p>No location data available</p>
            </div>
          )}
        </div>
      </Modal>

      <ConfirmDialog
        isOpen={!!confirmAction}
        onClose={() => setConfirmAction(null)}
        onConfirm={() => handleStatusAction(confirmAction!.type as 'verify' | 'suspend')}
        title={`${confirmAction?.type === 'verify' ? 'Verify' : 'Suspend'} Driver`}
        message={`Are you sure you want to ${confirmAction?.type} this driver?`}
        variant={confirmAction?.type === 'suspend' ? 'danger' : 'info'}
        confirmLabel={confirmAction?.type === 'verify' ? 'Verify' : 'Suspend'}
      />
    </ErrorBoundary>
  );
}
