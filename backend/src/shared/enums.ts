export enum UserRole {
  CUSTOMER = 'customer',
  DRIVER = 'driver',
  RESTAURANT_OWNER = 'restaurant_owner',
  ADMIN = 'admin',
}

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PREPARING = 'preparing',
  READY = 'ready',
  PICKED_UP = 'picked_up',
  IN_TRANSIT = 'in_transit',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
}

export enum PaymentMethod {
  CREDIT_CARD = 'credit_card',
  DEBIT_CARD = 'debit_card',
  PIX = 'pix',
  CASH = 'cash',
  MERCADO_PAGO = 'mercado_pago',
  STRIPE = 'stripe',
}

export enum PaymentStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded',
  PARTIALLY_REFUNDED = 'partially_refunded',
}

export enum DriverStatus {
  OFFLINE = 'offline',
  ONLINE = 'online',
  BUSY = 'busy',
  ON_DELIVERY = 'on_delivery',
}

export enum VehicleType {
  MOTORCYCLE = 'motorcycle',
  BICYCLE = 'bicycle',
  CAR = 'car',
  SCOOTER = 'scooter',
  WALKING = 'walking',
}

export enum DayOfWeek {
  MONDAY = 'monday',
  TUESDAY = 'tuesday',
  WEDNESDAY = 'wednesday',
  THURSDAY = 'thursday',
  FRIDAY = 'friday',
  SATURDAY = 'saturday',
  SUNDAY = 'sunday',
}

export enum NotificationType {
  ORDER_UPDATE = 'order_update',
  PROMOTION = 'promotion',
  SYSTEM = 'system',
  PAYMENT = 'payment',
  DRIVER_MESSAGE = 'driver_message',
}

export enum AuditAction {
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  LOGIN = 'login',
  LOGOUT = 'logout',
  STATUS_CHANGE = 'status_change',
}

export enum EntityType {
  USER = 'user',
  RESTAURANT = 'restaurant',
  ORDER = 'order',
  PRODUCT = 'product',
  DRIVER = 'driver',
  PAYMENT = 'payment',
  COUPON = 'coupon',
}

export enum DiscountType {
  PERCENTAGE = 'percentage',
  FIXED = 'fixed',
}

export enum DocumentStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}
