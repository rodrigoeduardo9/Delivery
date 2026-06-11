import { cn } from '../../utils/formatters';

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export default function LoadingSpinner({ size = 'md', className }: LoadingSpinnerProps) {
  const sizeClasses = {
    sm: 'h-5 w-5 border-2',
    md: 'h-10 w-10 border-3',
    lg: 'h-16 w-16 border-4',
  };

  return (
    <div className={cn('flex items-center justify-center py-12', className)}>
      <div
        className={cn(
          'animate-spin rounded-full border-primary-500 border-t-transparent',
          sizeClasses[size]
        )}
      />
    </div>
  );
}
