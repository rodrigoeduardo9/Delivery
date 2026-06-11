import { useState, useRef, useEffect } from 'react';
import { Calendar } from 'lucide-react';
import { format } from 'date-fns';
import { DATE_FORMAT } from '../../config/constants';

interface DateRange {
  start: Date | null;
  end: Date | null;
}

interface DateRangePickerProps {
  value: DateRange;
  onChange: (range: DateRange) => void;
  presets?: boolean;
}

const PRESETS = [
  { label: 'Today', days: 0 },
  { label: 'Last 7 days', days: 7 },
  { label: 'Last 30 days', days: 30 },
  { label: 'Last 90 days', days: 90 },
  { label: 'This year', days: 365 },
];

export default function DateRangePicker({ value, onChange, presets = true }: DateRangePickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const applyPreset = (days: number) => {
    const end = new Date();
    const start = new Date();
    start.setDate(start.getDate() - days);
    onChange({ start, end });
    setIsOpen(false);
  };

  const displayText = () => {
    if (!value.start && !value.end) return 'Select date range';
    if (value.start && value.end)
      return `${format(value.start, DATE_FORMAT)} - ${format(value.end, DATE_FORMAT)}`;
    if (value.start) return `From ${format(value.start, DATE_FORMAT)}`;
    return `Until ${format(value.end!, DATE_FORMAT)}`;
  };

  return (
    <div className="relative" ref={ref}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="btn-secondary text-sm"
      >
        <Calendar className="h-4 w-4" />
        {displayText()}
      </button>

      {isOpen && (
        <div className="absolute right-0 top-full z-40 mt-2 w-80 rounded-xl border bg-white p-4 shadow-lg">
          <div className="space-y-4">
            <div className="flex gap-2">
              <div className="flex-1">
                <label className="label">Start date</label>
                <input
                  type="date"
                  value={value.start ? format(value.start, 'yyyy-MM-dd') : ''}
                  onChange={(e) =>
                    onChange({
                      ...value,
                      start: e.target.value ? new Date(e.target.value) : null,
                    })
                  }
                  className="input"
                />
              </div>
              <div className="flex-1">
                <label className="label">End date</label>
                <input
                  type="date"
                  value={value.end ? format(value.end, 'yyyy-MM-dd') : ''}
                  onChange={(e) =>
                    onChange({
                      ...value,
                      end: e.target.value ? new Date(e.target.value) : null,
                    })
                  }
                  className="input"
                />
              </div>
            </div>

            {presets && (
              <>
                <hr />
                <div className="flex flex-wrap gap-2">
                  {PRESETS.map((preset) => (
                    <button
                      key={preset.label}
                      onClick={() => applyPreset(preset.days)}
                      className="rounded-lg bg-admin-100 px-3 py-1.5 text-xs font-medium text-admin-700 hover:bg-admin-200 transition-colors"
                    >
                      {preset.label}
                    </button>
                  ))}
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
