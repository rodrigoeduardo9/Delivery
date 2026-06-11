export interface User {
  id: string;
  email: string;
  name: string;
  role: 'superadmin' | 'admin' | 'manager' | 'support' | 'viewer';
  avatar?: string;
  status: 'active' | 'inactive' | 'suspended';
  orders_count: number;
  created_at: string;
  last_login?: string;
  phone?: string;
}

export interface Restaurant {
  id: string;
  name: string;
  owner: string;
  owner_id: string;
  email: string;
  phone: string;
  category: string;
  status: 'active' | 'inactive' | 'pending' | 'suspended';
  rating: number;
  logo?: string;
  cover_image?: string;
  description?: string;
  address: string;
  latitude: number;
  longitude: number;
  commission_rate: number;
  orders_today: number;
  revenue_today: number;
  total_revenue: number;
  total_orders: number;
  is_featured: boolean;
  delivery_fee: number;
  min_order: number;
  created_at: string;
  updated_at: string;
  opening_hours: OpeningHour[];
  menu: Product[];
  zones: DeliveryZone[];
}

export interface OpeningHour {
  day: string;
  open: string;
  close: string;
  is_closed: boolean;
}

export interface Product {
  id: string;
  restaurant_id: string;
  name: string;
  description?: string;
  price: number;
  category?: string;
  image?: string;
  is_available: boolean;
  preparation_time?: number;
  created_at: string;
}

export interface DeliveryZone {
  id: string;
  name: string;
  coordinates: [number, number][];
  base_fee: number;
  per_km_rate: number;
  estimated_time: number;
}

export interface Order {
  id: string;
  order_number: string;
  customer_id: string;
  customer_name: string;
  customer_phone?: string;
  customer_address: string;
  restaurant_id: string;
  restaurant_name: string;
  driver_id?: string;
  driver_name?: string;
  status: OrderStatus;
  items: OrderItem[];
  subtotal: number;
  delivery_fee: number;
  service_fee: number;
  discount: number;
  total: number;
  payment_method: string;
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded';
  notes?: string;
  cancellation_reason?: string;
  estimated_delivery_time?: string;
  delivered_at?: string;
  created_at: string;
  updated_at: string;
  timeline: OrderTimelineEntry[];
}

export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'picked_up'
  | 'in_transit'
  | 'delivered'
  | 'cancelled'
  | 'refunded';

export interface OrderItem {
  id: string;
  product_id: string;
  product_name: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  notes?: string;
}

export interface OrderTimelineEntry {
  status: OrderStatus;
  timestamp: string;
  note?: string;
}

export interface Driver {
  id: string;
  name: string;
  email: string;
  phone: string;
  avatar?: string;
  status: 'online' | 'offline' | 'busy' | 'suspended';
  vehicle_type: string;
  vehicle_model?: string;
  vehicle_plate?: string;
  rating: number;
  deliveries_today: number;
  earnings_today: number;
  total_deliveries: number;
  total_earnings: number;
  is_verified: boolean;
  current_location?: {
    latitude: number;
    longitude: number;
    updated_at: string;
  };
  documents: DriverDocument[];
  created_at: string;
}

export interface DriverDocument {
  id: string;
  type: string;
  status: 'pending' | 'verified' | 'rejected';
  url: string;
  uploaded_at: string;
  verified_at?: string;
  rejection_reason?: string;
}

export interface Payment {
  id: string;
  order_id: string;
  order_number: string;
  amount: number;
  method: string;
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  transaction_id?: string;
  created_at: string;
}

export interface ReportOverview {
  total_orders_today: number;
  total_revenue_today: number;
  active_drivers: number;
  active_restaurants: number;
  revenue_change_percent: number;
  orders_change_percent: number;
  drivers_change_percent: number;
  restaurants_change_percent: number;
  orders_over_time: ChartDataPoint[];
  revenue_breakdown: PieChartData[];
  recent_orders: Order[];
  top_restaurants: TopRestaurant[];
}

export interface ChartDataPoint {
  date: string;
  value: number;
  label?: string;
}

export interface PieChartData {
  name: string;
  value: number;
  color: string;
}

export interface TopRestaurant {
  id: string;
  name: string;
  logo?: string;
  revenue: number;
  orders: number;
  rating: number;
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'warning' | 'success' | 'error';
  is_read: boolean;
  created_at: string;
  link?: string;
}

export interface AuditLog {
  id: string;
  admin_id: string;
  admin_name: string;
  action: string;
  entity_type: string;
  entity_id: string;
  old_values?: Record<string, unknown>;
  new_values?: Record<string, unknown>;
  ip_address: string;
  created_at: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
  status: number;
}
