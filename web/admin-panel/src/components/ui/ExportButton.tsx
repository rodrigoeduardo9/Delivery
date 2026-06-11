import { useState, useRef, useEffect } from 'react';
import { Download, FileText, FileSpreadsheet, File } from 'lucide-react';
import { EXPORT_FORMATS } from '../../config/constants';

interface ExportButtonProps {
  onExport: (format: 'csv' | 'pdf' | 'excel') => void;
  filename?: string;
  disabled?: boolean;
}

const formatIcons = {
  csv: FileText,
  pdf: File,
  excel: FileSpreadsheet,
};

export default function ExportButton({ onExport, disabled = false }: ExportButtonProps) {
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

  return (
    <div className="relative" ref={ref}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="btn-secondary"
        disabled={disabled}
      >
        <Download className="h-4 w-4" />
        Export
      </button>

      {isOpen && (
        <div className="absolute right-0 top-full z-40 mt-2 w-44 rounded-xl border bg-white py-2 shadow-lg">
          {EXPORT_FORMATS.map((format) => {
            const Icon = formatIcons[format];
            return (
              <button
                key={format}
                onClick={() => {
                  onExport(format);
                  setIsOpen(false);
                }}
                className="flex w-full items-center gap-3 px-4 py-2 text-sm text-admin-700 capitalize hover:bg-admin-50"
              >
                <Icon className="h-4 w-4 text-admin-500" />
                {format}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
