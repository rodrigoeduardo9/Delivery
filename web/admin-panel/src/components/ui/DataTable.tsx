import { useState, useMemo, ReactNode } from 'react';
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  flexRender,
  ColumnDef,
  SortingState,
  ColumnFiltersState,
} from '@tanstack/react-table';
import { ChevronUp, ChevronDown, ChevronsUpDown, ChevronLeft, ChevronRight } from 'lucide-react';
import { cn } from '../../utils/formatters';
import { PAGINATION } from '../../config/constants';
import SearchInput from './SearchInput';
import LoadingSpinner from './LoadingSpinner';
import EmptyState from './EmptyState';

interface DataTableProps<T> {
  columns: ColumnDef<T>[];
  data: T[];
  isLoading?: boolean;
  searchable?: boolean;
  searchPlaceholder?: string;
  searchColumn?: string;
  pageSize?: number;
  onRowClick?: (row: T) => void;
  toolbar?: ReactNode;
  emptyTitle?: string;
  emptyMessage?: string;
}

export default function DataTable<T>({
  columns,
  data,
  isLoading = false,
  searchable = false,
  searchPlaceholder = 'Search...',
  searchColumn,
  pageSize = PAGINATION.defaultPageSize,
  onRowClick,
  toolbar,
  emptyTitle = 'No data found',
  emptyMessage = 'No records to display',
}: DataTableProps<T>) {
  const [sorting, setSorting] = useState<SortingState>([]);
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
  const [globalFilter, setGlobalFilter] = useState('');

  const tableData = useMemo(() => data, [data]);

  const table = useReactTable({
    data: tableData,
    columns,
    state: {
      sorting,
      columnFilters,
      globalFilter,
    },
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onGlobalFilterChange: setGlobalFilter,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: {
      pagination: { pageSize },
    },
  });

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (data.length === 0) {
    return (
      <div>
        {toolbar && <div className="mb-4">{toolbar}</div>}
        <EmptyState title={emptyTitle} message={emptyMessage} />
      </div>
    );
  }

  return (
    <div>
      {(searchable || toolbar) && (
        <div className="mb-4 flex flex-wrap items-center justify-between gap-4">
          {searchable && (
            <div className="w-full max-w-xs">
              <SearchInput
                value={globalFilter}
                onChange={setGlobalFilter}
                placeholder={searchPlaceholder}
              />
            </div>
          )}
          {toolbar && <div className="flex items-center gap-2">{toolbar}</div>}
        </div>
      )}

      <div className="overflow-x-auto rounded-xl border border-admin-200">
        <table className="w-full text-sm">
          <thead>
            {table.getHeaderGroups().map((headerGroup) => (
              <tr key={headerGroup.id} className="bg-admin-50">
                {headerGroup.headers.map((header) => (
                  <th
                    key={header.id}
                    className={cn(
                      'px-4 py-3 text-left text-xs font-semibold uppercase tracking-wider text-admin-500',
                      header.column.getCanSort() && 'cursor-pointer select-none hover:text-admin-700'
                    )}
                    onClick={header.column.getToggleSortingHandler()}
                  >
                    <div className="flex items-center gap-1">
                      {flexRender(header.column.columnDef.header, header.getContext())}
                      {header.column.getCanSort() && (
                        <span className="inline-flex">
                          {header.column.getIsSorted() === 'asc' ? (
                            <ChevronUp className="h-3.5 w-3.5" />
                          ) : header.column.getIsSorted() === 'desc' ? (
                            <ChevronDown className="h-3.5 w-3.5" />
                          ) : (
                            <ChevronsUpDown className="h-3.5 w-3.5 text-admin-300" />
                          )}
                        </span>
                      )}
                    </div>
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody className="divide-y divide-admin-100 bg-white">
            {table.getRowModel().rows.map((row) => (
              <tr
                key={row.id}
                className={cn(
                  'transition-colors hover:bg-admin-50',
                  onRowClick && 'cursor-pointer'
                )}
                onClick={() => onRowClick?.(row.original)}
              >
                {row.getVisibleCells().map((cell) => (
                  <td key={cell.id} className="px-4 py-3 text-admin-700">
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="flex items-center justify-between py-4 text-sm text-admin-500">
        <p>
          Showing {table.getState().pagination.pageIndex * table.getState().pagination.pageSize + 1} to{' '}
          {Math.min(
            (table.getState().pagination.pageIndex + 1) * table.getState().pagination.pageSize,
            data.length
          )}{' '}
          of {data.length} results
        </p>
        <div className="flex items-center gap-2">
          <button
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}
            className="btn-secondary btn-sm"
          >
            <ChevronLeft className="h-4 w-4" />
            Previous
          </button>
          {Array.from({ length: table.getPageCount() }, (_, i) => i + 1)
            .filter(
              (page) =>
                page === 1 ||
                page === table.getPageCount() ||
                Math.abs(page - (table.getState().pagination.pageIndex + 1)) <= 1
            )
            .map((page, idx, arr) => (
              <span key={page} className="flex items-center gap-1">
                {idx > 0 && arr[idx - 1] !== page - 1 && <span className="px-1">...</span>}
                <button
                  onClick={() => table.setPageIndex(page - 1)}
                  className={cn(
                    'flex h-8 w-8 items-center justify-center rounded-lg text-sm font-medium',
                    table.getState().pagination.pageIndex === page - 1
                      ? 'bg-primary-600 text-white'
                      : 'text-admin-600 hover:bg-admin-100'
                  )}
                >
                  {page}
                </button>
              </span>
            ))}
          <button
            onClick={() => table.nextPage()}
            disabled={!table.getCanNextPage()}
            className="btn-secondary btn-sm"
          >
            Next
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
