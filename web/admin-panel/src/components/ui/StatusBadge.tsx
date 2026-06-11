import { cn } from '../../utils/formatters';
import { STATUS_COLORS, ORDER_STATUS_COLORS } from '../../config/constants';

interface StatusBadgeProps {
  status: string;
  type?: 'order' | 'default';
}

export default function StatusBadge({ status, type = 'default' }: StatusBadgeProps) {
  const colors = type === 'order' ? ORDER_STATUS_COLORS : STATUS_COLORS;

  return (
    <span
      className={cn(
        'badge capitalize',
        colors[status] || 'bg-admin-100 text-admin-600'
      )}
    >
      {status.replace(/_/g, ' ')}
    </span>
  );
}
