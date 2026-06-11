import { useState, useCallback } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Save, Globe, Percent, Truck, Bell, CreditCard, Shield } from 'lucide-react';
import toast from 'react-hot-toast';
import { useApi, useMutation } from '../hooks/useApi';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import ErrorBoundary from '../components/ui/ErrorBoundary';
import { settingsSchema, SettingsFormData } from '../utils/validators';

const SECTIONS = [
  { id: 'general', label: 'General', icon: Globe },
  { id: 'commissions', label: 'Commissions', icon: Percent },
  { id: 'delivery', label: 'Delivery', icon: Truck },
  { id: 'notifications', label: 'Notifications', icon: Bell },
  { id: 'payment', label: 'Payment', icon: CreditCard },
  { id: 'security', label: 'Security', icon: Shield },
];

export default function SettingsPage() {
  const [activeSection, setActiveSection] = useState('general');

  const { data: settings, isLoading } = useApi<any>('/settings');

  const { mutate: updateSettings } = useMutation();

  const {
    register,
    handleSubmit,
    formState: { errors, isDirty },
    reset,
  } = useForm<SettingsFormData>({
    resolver: zodResolver(settingsSchema),
    values: settings || {
      platform_name: 'DeliverAdmin',
      support_email: 'support@deliveradmin.com',
      default_currency: 'MXN',
      default_commission_rate: 15,
      base_delivery_fee: 25,
      per_km_rate: 8,
      free_delivery_threshold: 150,
      session_timeout_minutes: 60,
      min_payout_amount: 500,
    },
  });

  const onSubmit = useCallback(
    async (data: SettingsFormData) => {
      try {
        await updateSettings('put', '/settings', data);
        toast.success('Settings saved successfully');
        reset(data);
      } catch {
        toast.error('Failed to save settings');
      }
    },
    [updateSettings, reset]
  );

  const [notificationTemplates, setNotificationTemplates] = useState({
    order_confirmed: 'Your order #{{order_number}} has been confirmed!',
    order_in_transit: 'Your order is on the way! Driver: {{driver_name}}',
    order_delivered: 'Your order has been delivered! Enjoy your meal.',
    driver_assigned: 'You have been assigned to order #{{order_number}}',
  });

  const [emailTemplates, setEmailTemplates] = useState({
    welcome: 'Welcome to {{platform_name}}!',
    order_receipt: 'Your receipt for order #{{order_number}}',
    password_reset: 'Reset your {{platform_name}} password',
  });

  const [paymentMethods, setPaymentMethods] = useState<Record<string, boolean>>({
    card: true,
    cash: true,
    wallet: true,
    transfer: false,
  });

  const handleNotificationChange = (key: string, value: string) => {
    setNotificationTemplates((prev) => ({ ...prev, [key]: value }));
  };

  const handleEmailChange = (key: string, value: string) => {
    setEmailTemplates((prev) => ({ ...prev, [key]: value }));
  };

  if (isLoading) return <LoadingSpinner size="lg" />;

  return (
    <ErrorBoundary>
      <div className="max-w-5xl">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-admin-900">Settings</h1>
          <p className="text-admin-500">Manage platform configuration</p>
        </div>

        <div className="flex gap-6">
          <div className="w-56 shrink-0">
            <nav className="space-y-1">
              {SECTIONS.map((section) => {
                const Icon = section.icon;
                return (
                  <button
                    key={section.id}
                    onClick={() => setActiveSection(section.id)}
                    className={`flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                      activeSection === section.id
                        ? 'bg-primary-50 text-primary-700'
                        : 'text-admin-600 hover:bg-admin-100'
                    }`}
                  >
                    <Icon className="h-4 w-4" />
                    {section.label}
                  </button>
                );
              })}
            </nav>
          </div>

          <div className="flex-1">
            <form onSubmit={handleSubmit(onSubmit)}>
              {activeSection === 'general' && (
                <div className="card">
                  <div className="card-header">
                    <h3 className="text-lg font-semibold">General Settings</h3>
                  </div>
                  <div className="card-body space-y-4">
                    <div>
                      <label className="label">Platform Name</label>
                      <input {...register('platform_name')} className="input" />
                      {errors.platform_name && <p className="text-xs text-danger-500 mt-1">{errors.platform_name.message}</p>}
                    </div>
                    <div>
                      <label className="label">Support Email</label>
                      <input {...register('support_email')} className="input" />
                      {errors.support_email && <p className="text-xs text-danger-500 mt-1">{errors.support_email.message}</p>}
                    </div>
                    <div>
                      <label className="label">Default Currency</label>
                      <select {...register('default_currency')} className="select">
                        <option value="MXN">MXN - Mexican Peso</option>
                        <option value="USD">USD - US Dollar</option>
                        <option value="EUR">EUR - Euro</option>
                      </select>
                    </div>
                  </div>
                </div>
              )}

              {activeSection === 'commissions' && (
                <div className="card">
                  <div className="card-header">
                    <h3 className="text-lg font-semibold">Commission Settings</h3>
                  </div>
                  <div className="card-body space-y-4">
                    <div>
                      <label className="label">Default Commission Rate (%)</label>
                      <input {...register('default_commission_rate', { valueAsNumber: true })} type="number" min={0} max={100} step={0.5} className="input" />
                      {errors.default_commission_rate && <p className="text-xs text-danger-500 mt-1">{errors.default_commission_rate.message}</p>}
                    </div>
                    <p className="text-sm text-admin-500">
                      Per-restaurant commission overrides can be set on the restaurant detail page.
                    </p>
                  </div>
                </div>
              )}

              {activeSection === 'delivery' && (
                <div className="card">
                  <div className="card-header">
                    <h3 className="text-lg font-semibold">Delivery Settings</h3>
                  </div>
                  <div className="card-body space-y-4">
                    <div>
                      <label className="label">Base Delivery Fee ({settings?.default_currency || 'MXN'})</label>
                      <input {...register('base_delivery_fee', { valueAsNumber: true })} type="number" min={0} step={5} className="input" />
                      {errors.base_delivery_fee && <p className="text-xs text-danger-500 mt-1">{errors.base_delivery_fee.message}</p>}
                    </div>
                    <div>
                      <label className="label">Per-Kilometer Rate ({settings?.default_currency || 'MXN'})</label>
                      <input {...register('per_km_rate', { valueAsNumber: true })} type="number" min={0} step={1} className="input" />
                      {errors.per_km_rate && <p className="text-xs text-danger-500 mt-1">{errors.per_km_rate.message}</p>}
                    </div>
                    <div>
                      <label className="label">Free Delivery Threshold ({settings?.default_currency || 'MXN'})</label>
                      <input {...register('free_delivery_threshold', { valueAsNumber: true })} type="number" min={0} step={50} className="input" />
                      <p className="text-xs text-admin-400 mt-1">Leave at 0 to disable free delivery</p>
                    </div>
                  </div>
                </div>
              )}

              {activeSection === 'notifications' && (
                <div className="space-y-6">
                  <div className="card">
                    <div className="card-header">
                      <h3 className="text-lg font-semibold">Push Notification Templates</h3>
                    </div>
                    <div className="card-body space-y-4">
                      {Object.entries(notificationTemplates).map(([key, value]) => (
                        <div key={key}>
                          <label className="label capitalize">{key.replace(/_/g, ' ')}</label>
                          <textarea
                            value={value}
                            onChange={(e) => handleNotificationChange(key, e.target.value)}
                            className="input h-20 resize-none"
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                  <div className="card">
                    <div className="card-header">
                      <h3 className="text-lg font-semibold">Email Templates</h3>
                    </div>
                    <div className="card-body space-y-4">
                      {Object.entries(emailTemplates).map(([key, value]) => (
                        <div key={key}>
                          <label className="label capitalize">{key.replace(/_/g, ' ')}</label>
                          <input
                            value={value}
                            onChange={(e) => handleEmailChange(key, e.target.value)}
                            className="input"
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {activeSection === 'payment' && (
                <div className="card">
                  <div className="card-header">
                    <h3 className="text-lg font-semibold">Payment Settings</h3>
                  </div>
                  <div className="card-body space-y-4">
                    <div>
                      <label className="label">Enabled Payment Methods</label>
                      <div className="space-y-2 mt-2">
                        {Object.entries(paymentMethods).map(([key, value]) => (
                          <label key={key} className="flex items-center gap-3">
                            <input
                              type="checkbox"
                              checked={value}
                              onChange={() => setPaymentMethods((prev) => ({ ...prev, [key]: !prev[key as keyof typeof prev] }))}
                              className="h-4 w-4 rounded border-admin-300 text-primary-600 focus:ring-primary-500"
                            />
                            <span className="text-sm capitalize">{key}</span>
                          </label>
                        ))}
                      </div>
                    </div>
                    <div>
                      <label className="label">Minimum Payout Amount</label>
                      <input {...register('min_payout_amount', { valueAsNumber: true })} type="number" min={0} step={100} className="input" />
                      {errors.min_payout_amount && <p className="text-xs text-danger-500 mt-1">{errors.min_payout_amount.message}</p>}
                    </div>
                  </div>
                </div>
              )}

              {activeSection === 'security' && (
                <div className="card">
                  <div className="card-header">
                    <h3 className="text-lg font-semibold">Security Settings</h3>
                  </div>
                  <div className="card-body space-y-6">
                    <div>
                      <label className="label">Session Timeout (minutes)</label>
                      <input {...register('session_timeout_minutes', { valueAsNumber: true })} type="number" min={1} max={1440} className="input" />
                      {errors.session_timeout_minutes && <p className="text-xs text-danger-500 mt-1">{errors.session_timeout_minutes.message}</p>}
                    </div>
                    <div>
                      <label className="label">Password Policy</label>
                      <div className="space-y-2">
                        <label className="flex items-center gap-3">
                          <input type="checkbox" defaultChecked className="h-4 w-4 rounded border-admin-300 text-primary-600" />
                          <span className="text-sm">Minimum 8 characters</span>
                        </label>
                        <label className="flex items-center gap-3">
                          <input type="checkbox" defaultChecked className="h-4 w-4 rounded border-admin-300 text-primary-600" />
                          <span className="text-sm">Require uppercase & lowercase</span>
                        </label>
                        <label className="flex items-center gap-3">
                          <input type="checkbox" defaultChecked className="h-4 w-4 rounded border-admin-300 text-primary-600" />
                          <span className="text-sm">Require number</span>
                        </label>
                        <label className="flex items-center gap-3">
                          <input type="checkbox" defaultChecked className="h-4 w-4 rounded border-admin-300 text-primary-600" />
                          <span className="text-sm">Require special character</span>
                        </label>
                      </div>
                    </div>
                    <div>
                      <label className="flex items-center gap-3">
                        <input type="checkbox" className="h-4 w-4 rounded border-admin-300 text-primary-600" />
                        <div>
                          <span className="text-sm font-medium">Enable Multi-Factor Authentication (MFA)</span>
                          <p className="text-xs text-admin-500">For all admin accounts</p>
                        </div>
                      </label>
                    </div>
                  </div>
                </div>
              )}

              {isDirty && (
                <div className="mt-6 flex justify-end">
                  <button type="submit" className="btn-primary">
                    <Save className="h-4 w-4" />
                    Save Changes
                  </button>
                </div>
              )}
            </form>
          </div>
        </div>
      </div>
    </ErrorBoundary>
  );
}
