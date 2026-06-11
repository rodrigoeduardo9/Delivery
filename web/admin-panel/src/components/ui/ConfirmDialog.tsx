import { Fragment } from 'react';
import { Dialog, Transition } from '@headlessui/react';
import { AlertTriangle } from 'lucide-react';

interface ConfirmDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: 'danger' | 'warning' | 'info';
  isLoading?: boolean;
}

export default function ConfirmDialog({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  variant = 'danger',
  isLoading = false,
}: ConfirmDialogProps) {
  const variantColors = {
    danger: 'bg-danger-600 hover:bg-danger-700 focus:ring-danger-500',
    warning: 'bg-warning-600 hover:bg-warning-700 focus:ring-warning-500',
    info: 'bg-primary-600 hover:bg-primary-700 focus:ring-primary-500',
  };

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-200"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-150"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black/40" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-200"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-150"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel className="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl">
                <div className="flex items-center gap-4">
                  <div
                    className={`flex h-12 w-12 items-center justify-center rounded-full ${
                      variant === 'danger'
                        ? 'bg-danger-100 text-danger-600'
                        : variant === 'warning'
                        ? 'bg-warning-100 text-warning-600'
                        : 'bg-primary-100 text-primary-600'
                    }`}
                  >
                    <AlertTriangle className="h-6 w-6" />
                  </div>
                  <div>
                    <Dialog.Title className="text-lg font-semibold text-admin-900">
                      {title}
                    </Dialog.Title>
                    <p className="mt-1 text-sm text-admin-600">{message}</p>
                  </div>
                </div>

                <div className="mt-6 flex justify-end gap-3">
                  <button onClick={onClose} className="btn-secondary" disabled={isLoading}>
                    {cancelLabel}
                  </button>
                  <button
                    onClick={onConfirm}
                    className={`btn ${variantColors[variant]}`}
                    disabled={isLoading}
                  >
                    {isLoading ? 'Processing...' : confirmLabel}
                  </button>
                </div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
}
