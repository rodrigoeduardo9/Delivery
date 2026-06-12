import { format, formatDistanceToNow, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { CURRENCY } from '../config/constants';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatCurrency(amount: number): string {
  const n = Number(amount) || 0;
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: CURRENCY,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(n);
}

export function formatDate(date: string | Date | null | undefined, dateFormat: string = 'MMM dd, yyyy'): string {
  if (!date) return '-';
  const d = typeof date === 'string' ? parseISO(date) : date;
  try { return format(d, dateFormat, { locale: es }); } catch { return '-'; }
}

export function formatDateTime(date: string | Date | null | undefined): string {
  if (!date) return '-';
  const d = typeof date === 'string' ? parseISO(date) : date;
  try { return format(d, 'MMM dd, yyyy HH:mm', { locale: es }); } catch { return '-'; }
}

export function formatRelativeTime(date: string | Date | null | undefined): string {
  if (!date) return '-';
  const d = typeof date === 'string' ? parseISO(date) : date;
  try { return formatDistanceToNow(d, { addSuffix: true, locale: es }); } catch { return '-'; }
}

export function formatNumber(num: number): string {
  return new Intl.NumberFormat('es-MX').format(Number(num) || 0);
}

export function formatPercentage(value: number, decimals: number = 1): string {
  if (value == null || isNaN(Number(value))) return 'N/A';
  const n = Number(value);
  return `${n >= 0 ? '+' : ''}${n.toFixed(decimals)}%`;
}

export function truncate(str: string, length: number = 50): string {
  if (!str) return '';
  if (str.length <= length) return str;
  return str.substring(0, length) + '...';
}

export function getInitials(name: string): string {
  if (!name) return '';
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .substring(0, 2);
}
