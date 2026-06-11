export const APP_NAME = 'DeliverAdmin';

export const PAGINATION = {
  defaultPageSize: 10,
  pageSizeOptions: [10, 25, 50, 100],
};

export const STATUS_COLORS: Record<string, string> = {
  active: 'bg-success-100 text-success-800',
  inactive: 'bg-admin-100 text-admin-600',
  pending: 'bg-warning-100 text-warning-800',
  suspended: 'bg-danger-100 text-danger-800',
  verified: 'bg-success-100 text-success-800',
  unverified: 'bg-warning-100 text-warning-800',
  online: 'bg-success-100 text-success-800',
  offline: 'bg-admin-100 text-admin-600',
  busy: 'bg-warning-100 text-warning-800',
};

export const ORDER_STATUS_COLORS: Record<string, string> = {
  pending: 'bg-warning-100 text-warning-800',
  confirmed: 'bg-primary-100 text-primary-800',
  preparing: 'bg-indigo-100 text-indigo-800',
  picked_up: 'bg-purple-100 text-purple-800',
  in_transit: 'bg-blue-100 text-blue-800',
  delivered: 'bg-success-100 text-success-800',
  cancelled: 'bg-danger-100 text-danger-800',
  refunded: 'bg-admin-100 text-admin-600',
};

export const ROLE_LABELS: Record<string, string> = {
  superadmin: 'Super Admin',
  admin: 'Admin',
  manager: 'Manager',
  support: 'Support',
  viewer: 'Viewer',
};

export const RESTAURANT_CATEGORIES = [
  'Pizza',
  'Burgers',
  'Sushi',
  'Mexican',
  'Italian',
  'Chinese',
  'Indian',
  'Japanese',
  'Thai',
  'American',
  'Desserts',
  'Coffee',
  'Healthy',
  'Seafood',
  'Other',
];

export const VEHICLE_TYPES = ['motorcycle', 'bicycle', 'car', 'scooter', 'van', 'truck'];

export const EXPORT_FORMATS = ['csv', 'pdf', 'excel'] as const;

export const DATE_FORMAT = 'MMM dd, yyyy';
export const TIME_FORMAT = 'HH:mm';
export const DATE_TIME_FORMAT = 'MMM dd, yyyy HH:mm';
export const CURRENCY = 'MXN';
