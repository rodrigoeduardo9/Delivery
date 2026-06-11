import { Package } from 'lucide-react';
import { cn } from '../../utils/formatters';

interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  message?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
  className?: string;
}

export default function EmptyState({ icon, title, message, action, className }: EmptyStateProps) {
  return (
    <div className={cn('flex flex-col items-center justify-center py-16 text-center', className)}>
      <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-admin-100 text-admin-400">
        {icon || <Package className="h-8 w-8" />}
      </div>
      <h3 className="text-lg font-semibold text-admin-900">{title}</h3>
      {message && <p className="mt-1 max-w-sm text-sm text-admin-500">{message}</p>}
      {action && (
        <button onClick={action.onClick} className="btn-primary mt-4">
          {action.label}
        </button>
      )}
    </div>
  );
}
