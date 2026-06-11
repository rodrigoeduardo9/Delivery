import { useState, useEffect, useCallback, useRef } from 'react';
import api from '../config/api';

interface UseApiState<T> {
  data: T | null;
  isLoading: boolean;
  error: string | null;
}

interface UseApiReturn<T> extends UseApiState<T> {
  refetch: () => Promise<void>;
  setData: (data: T | null) => void;
}

export function useApi<T>(
  url: string | null,
  options?: {
    params?: Record<string, unknown>;
    enabled?: boolean;
    onSuccess?: (data: T) => void;
    onError?: (error: string) => void;
  }
): UseApiReturn<T> {
  const [state, setState] = useState<UseApiState<T>>({
    data: null,
    isLoading: !!url && options?.enabled !== false,
    error: null,
  });

  const optionsRef = useRef(options);
  optionsRef.current = options;

  const fetchData = useCallback(async () => {
    if (!url) return;

    setState((prev) => ({ ...prev, isLoading: true, error: null }));

    try {
      const response = await api.get<T>(url, {
        params: optionsRef.current?.params,
      });
      setState({ data: response.data, isLoading: false, error: null });
      optionsRef.current?.onSuccess?.(response.data);
    } catch (err: any) {
      const message = err?.response?.data?.message || err?.message || 'An error occurred';
      setState((prev) => ({ ...prev, isLoading: false, error: message }));
      optionsRef.current?.onError?.(message);
    }
  }, [url]);

  useEffect(() => {
    if (url && options?.enabled !== false) {
      fetchData();
    }
  }, [fetchData, url, options?.enabled]);

  return {
    ...state,
    refetch: fetchData,
    setData: (data: T | null) => setState((prev) => ({ ...prev, data })),
  };
}

export function useMutation<T = unknown>() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const mutate = useCallback(
    async (
      method: 'post' | 'put' | 'patch' | 'delete',
      url: string,
      data?: unknown,
      params?: Record<string, unknown>
    ) => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await api[method]<T>(url, data, { params });
        setIsLoading(false);
        return response.data;
      } catch (err: any) {
        const message = err?.response?.data?.message || err?.message || 'An error occurred';
        setError(message);
        setIsLoading(false);
        throw err;
      }
    },
    []
  );

  return { mutate, isLoading, error };
}
