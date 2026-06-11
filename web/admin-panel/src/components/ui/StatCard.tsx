import { TrendingUp, TrendingDown } from 'lucide-react';
import { cn } from '../../utils/formatters';

interface StatCardProps {
  label: string;
  value: string | number;
  icon: React.ReactNode;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  className?: string;
}

export default function StatCard({ label, value, icon, trend, className }: StatCardProps) {
  return (
    <div className={cn('card p-6', className)}>
      <div className="flex items-center justify-between">
        <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary-50 text-primary-600">
          {icon}
        </div>
        {trend && (
          <div
            className={cn(
              'flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium',
              trend.isPositive ? 'bg-success-50 text-success-700' : 'bg-danger-50 text-danger-700'
            )}
          >
            {trend.isPositive ? (
              <TrendingUp className="h-3.5 w-3.5" />
            ) : (
              <TrendingDown className="h-3.5 w-3.5" />
            )}
            {Math.abs(trend.value)}%
          </div>
        )}
      </div>
      <div className="mt-4">
        <p className="text-sm text-admin-500">{label}</p>
        <p className="mt-1 text-2xl font-bold text-admin-900">{value}</p>
      </div>
    </div>
  );
}
