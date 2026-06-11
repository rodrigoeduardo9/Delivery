import { X } from 'lucide-react';

interface FilterChip {
  label: string;
  value: string;
  active: boolean;
  onClick: () => void;
}

interface FilterBarProps {
  chips: FilterChip[];
  onClearAll?: () => void;
}

export default function FilterBar({ chips, onClearAll }: FilterBarProps) {
  const hasActiveFilters = chips.some((c) => c.active);

  return (
    <div className="flex flex-wrap items-center gap-2">
      {chips.map((chip) => (
        <button
          key={`${chip.label}-${chip.value}`}
          onClick={chip.onClick}
          className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-medium transition-colors ${
            chip.active
              ? 'bg-primary-100 text-primary-700'
              : 'bg-admin-100 text-admin-600 hover:bg-admin-200'
          }`}
        >
          {chip.label}
          {chip.active && <X className="h-3 w-3" />}
        </button>
      ))}
      {hasActiveFilters && onClearAll && (
        <button
          onClick={onClearAll}
          className="text-xs text-admin-500 hover:text-admin-700 underline"
        >
          Clear all
        </button>
      )}
    </div>
  );
}
