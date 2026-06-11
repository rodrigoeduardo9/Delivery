import { useState, useEffect, useRef } from 'react';
import { Search, X } from 'lucide-react';

interface SearchInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  debounceMs?: number;
}

export default function SearchInput({
  value,
  onChange,
  placeholder = 'Search...',
  debounceMs = 400,
}: SearchInputProps) {
  const [localValue, setLocalValue] = useState(value);
  const isFirstRender = useRef(true);

  useEffect(() => {
    setLocalValue(value);
  }, [value]);

  useEffect(() => {
    if (isFirstRender.current) {
      isFirstRender.current = false;
      return;
    }
    const timer = setTimeout(() => {
      onChange(localValue);
    }, debounceMs);
    return () => clearTimeout(timer);
  }, [localValue, debounceMs, onChange]);

  return (
    <div className="relative">
      <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-admin-400" />
      <input
        type="text"
        value={localValue}
        onChange={(e) => setLocalValue(e.target.value)}
        placeholder={placeholder}
        className="input pl-10 pr-10"
      />
      {localValue && (
        <button
          onClick={() => { setLocalValue(''); onChange(''); }}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-admin-400 hover:text-admin-600"
        >
          <X className="h-4 w-4" />
        </button>
      )}
    </div>
  );
}
