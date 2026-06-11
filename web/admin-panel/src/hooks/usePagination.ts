import { useState, useCallback, useMemo } from 'react';
import { PAGINATION } from '../config/constants';

interface PaginationState {
  page: number;
  perPage: number;
  total: number;
}

interface PaginationReturn extends PaginationState {
  totalPages: number;
  from: number;
  to: number;
  setPage: (page: number) => void;
  setPerPage: (size: number) => void;
  setTotal: (total: number) => void;
  nextPage: () => void;
  prevPage: () => void;
  hasNext: boolean;
  hasPrev: boolean;
}

export function usePagination(initial?: Partial<PaginationState>): PaginationReturn {
  const [state, setState] = useState<PaginationState>({
    page: initial?.page || 1,
    perPage: initial?.perPage || PAGINATION.defaultPageSize,
    total: initial?.total || 0,
  });

  const totalPages = useMemo(() => Math.ceil(state.total / state.perPage) || 1, [state.total, state.perPage]);
  const from = useMemo(() => (state.page - 1) * state.perPage + 1, [state.page, state.perPage]);
  const to = useMemo(() => Math.min(state.page * state.perPage, state.total), [state.page, state.perPage, state.total]);

  const setPage = useCallback((page: number) => {
    setState((prev) => ({ ...prev, page: Math.max(1, page) }));
  }, []);

  const setPerPage = useCallback((size: number) => {
    setState((prev) => ({ ...prev, perPage: size, page: 1 }));
  }, []);

  const setTotal = useCallback((total: number) => {
    setState((prev) => ({ ...prev, total }));
  }, []);

  const nextPage = useCallback(() => {
    setState((prev) => ({
      ...prev,
      page: Math.min(prev.page + 1, Math.ceil(prev.total / prev.perPage)),
    }));
  }, []);

  const prevPage = useCallback(() => {
    setState((prev) => ({ ...prev, page: Math.max(1, prev.page - 1) }));
  }, []);

  return {
    ...state,
    totalPages,
    from,
    to,
    setPage,
    setPerPage,
    setTotal,
    nextPage,
    prevPage,
    hasNext: state.page < totalPages,
    hasPrev: state.page > 1,
  };
}
