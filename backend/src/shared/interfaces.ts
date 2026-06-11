import {
  UserRole, OrderStatus, PaymentMethod, PaymentStatus,
  DriverStatus, VehicleType, NotificationType, DiscountType,
  DocumentStatus, DayOfWeek
} from './enums';

export interface PaginationParams {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'asc' | 'desc';
}

export interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface User {
  id: string;
  email: string;
  phone?: string;
  password_hash: string;
  first_name: string;
  last_name: string;
  role: UserRole;
  avatar_url?: string;
  email_verified: boolean;
  phone_verified: boolean;
  is_active: boolean;
  is_deleted: boolean;
  last_login_at?: Date;
  created_at: Date;
  updated_at: Date;
}

export interface UserCreateInput {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  phone?: string;
  role?: UserRole;
}

export interface UserUpdateInput {
  first_name?: string;
  last_name?: string;
  phone?: string;
  avatar_url?: string;
}

export interface RefreshToken {
  id: string;
  user_id: string;
  token: string;
  expires_at: Date;
  revoked: boolean;
  created_at: Date;
}

export interface DriverProfile {
  id: string;
  user_id: string;
  vehicle_type: VehicleType;
  vehicle_plate?: string;
  vehicle_model?: string;
  vehicle_color?: string;
  license_number?: string;
  status: DriverStatus;
  is_verified: boolean;
  is_available: boolean;
  rating: number;
  total_reviews: number;
  total_deliveries: number;
  current_latitude?: number;
  current_longitude?: number;
  last_location_update?: Date;
  created_at: Date;
  updated_at: Date;
}

export interface Address {
  id: string;
  user_id: string;
  label: string;
  street: string;
  number?: string;
  complement?: string;
  neighborhood?: string;
  city: string;
  state: string;
  zip_code: string;
  latitude?: number;
  longitude?: number;
  is_default: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Restaurant {
  id: string;
  owner_id: string;
  name: string;
  slug: string;
  description?: string;
  phone?: string;
  email?: string;
  website?: string;
  logo_url?: string;
  banner_url?: string;
  street: string;
  number?: string;
  complement?: string;
  neighborhood?: string;
  city: string;
  state: string;
  zip_code: string;
  latitude: number;
  longitude: number;
  delivery_fee: number;
  minimum_order: number;
  delivery_radius_km: number;
  preparation_time_min: number;
  is_active: boolean;
  is_open: boolean;
  is_deleted: boolean;
  rating: number;
  total_reviews: number;
  created_at: Date;
  updated_at: Date;
}

export interface RestaurantHours {
  id: string;
  restaurant_id: string;
  day_of_week: DayOfWeek;
  open_time: string;
  close_time: string;
  is_closed: boolean;
}

export interface RestaurantCategory {
  id: string;
  name: string;
  slug: string;
  icon?: string;
}

export interface RestaurantZone {
  id: string;
  restaurant_id: string;
  name: string;
  geometry: any;
  delivery_fee?: number;
  minimum_order?: number;
  estimated_time_min?: number;
  is_active: boolean;
  created_at: Date;
}

export interface Product {
  id: string;
  restaurant_id: string;
  name: string;
  description?: string;
  price: number;
  discounted_price?: number;
  image_url?: string;
  category?: string;
  is_available: boolean;
  is_featured: boolean;
  is_deleted: boolean;
  stock: number;
  preparation_time_min?: number;
  sort_order: number;
  created_at: Date;
  updated_at: Date;
}

export interface ProductVariant {
  id: string;
  product_id: string;
  name: string;
  price_adjustment: number;
  is_available: boolean;
  sort_order: number;
}

export interface ProductExtra {
  id: string;
  product_id: string;
  name: string;
  price: number;
  is_available: boolean;
  max_quantity: number;
  sort_order: number;
}

export interface Order {
  id: string;
  order_number: string;
  customer_id: string;
  restaurant_id: string;
  driver_id?: string;
  status: OrderStatus;
  subtotal: number;
  delivery_fee: number;
  discount: number;
  tip: number;
  total: number;
  payment_method?: PaymentMethod;
  payment_status: PaymentStatus;
  delivery_address_id?: string;
  delivery_latitude?: number;
  delivery_longitude?: number;
  delivery_instructions?: string;
  estimated_delivery_time?: Date;
  actual_delivery_time?: Date;
  coupon_id?: string;
  platform_fee: number;
  restaurant_earnings: number;
  driver_earnings: number;
  customer_rating?: number;
  customer_review?: string;
  is_scheduled: boolean;
  scheduled_time?: Date;
  cancelled_by?: string;
  cancellation_reason?: string;
  created_at: Date;
  updated_at: Date;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  variant_id?: string;
  product_name: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  special_instructions?: string;
}

export interface OrderItemExtra {
  id: string;
  order_item_id: string;
  extra_name: string;
  extra_price: number;
  quantity: number;
}

export interface Payment {
  id: string;
  order_id: string;
  gateway: string;
  gateway_payment_id?: string;
  gateway_status?: string;
  amount: number;
  currency: string;
  payment_method: PaymentMethod;
  status: PaymentStatus;
  fee: number;
  net_amount?: number;
  metadata?: any;
  paid_at?: Date;
  refunded_at?: Date;
  created_at: Date;
  updated_at: Date;
}

export interface DriverDocument {
  id: string;
  driver_profile_id: string;
  document_type: string;
  document_url: string;
  status: DocumentStatus;
  verified_by?: string;
  verified_at?: Date;
  rejection_reason?: string;
  created_at: Date;
  updated_at: Date;
}

export interface DriverEarnings {
  id: string;
  driver_profile_id: string;
  order_id: string;
  amount: number;
  type: string;
  status: string;
  paid_at?: Date;
  created_at: Date;
}

export interface Review {
  id: string;
  order_id: string;
  restaurant_id: string;
  customer_id: string;
  driver_profile_id?: string;
  restaurant_rating: number;
  driver_rating?: number;
  comment?: string;
  response?: string;
  responded_at?: Date;
  is_visible: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface Coupon {
  id: string;
  code: string;
  description?: string;
  discount_type: DiscountType;
  discount_value: number;
  minimum_order: number;
  max_discount?: number;
  max_uses?: number;
  current_uses: number;
  max_uses_per_user: number;
  is_active: boolean;
  valid_from: Date;
  valid_until: Date;
  created_at: Date;
}

export interface ChatConversation {
  id: string;
  customer_id: string;
  restaurant_id?: string;
  driver_profile_id?: string;
  subject?: string;
  status: string;
  created_at: Date;
  updated_at: Date;
}

export interface ChatMessage {
  id: string;
  conversation_id: string;
  sender_id: string;
  content: string;
  message_type: string;
  metadata?: any;
  is_read: boolean;
  created_at: Date;
}

export interface Notification {
  id: string;
  user_id: string;
  type: NotificationType;
  title: string;
  body?: string;
  data?: any;
  is_read: boolean;
  read_at?: Date;
  created_at: Date;
}

export interface AuditLog {
  id: string;
  user_id?: string;
  action: string;
  entity_type: string;
  entity_id?: string;
  changes?: any;
  ip_address?: string;
  user_agent?: string;
  created_at: Date;
}

export interface JwtPayload {
  userId: string;
  role: UserRole;
  email: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface OrderCreateInput {
  restaurant_id: string;
  items: OrderItemInput[];
  delivery_address_id?: string;
  delivery_latitude?: number;
  delivery_longitude?: number;
  delivery_instructions?: string;
  payment_method: PaymentMethod;
  coupon_code?: string;
  tip?: number;
  is_scheduled?: boolean;
  scheduled_time?: string;
}

export interface OrderItemInput {
  product_id: string;
  quantity: number;
  variant_id?: string;
  extras?: OrderItemExtraInput[];
  special_instructions?: string;
}

export interface OrderItemExtraInput {
  extra_id: string;
  quantity: number;
}

export interface NearbySearchParams {
  latitude: number;
  longitude: number;
  radius_km?: number;
  category?: string;
  search?: string;
  page?: number;
  limit?: number;
}

export interface RouteOptimizationInput {
  origin: { lat: number; lng: number };
  destination: { lat: number; lng: number };
  waypoints?: { lat: number; lng: number }[];
}

export interface ChatbotMessageInput {
  conversation_id?: string;
  message: string;
  context?: {
    order_id?: string;
    restaurant_id?: string;
  };
}

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}
