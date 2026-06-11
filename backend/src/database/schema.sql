-- ============================================================
-- COMPLETE DELIVERY PLATFORM DATABASE SCHEMA
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE user_role AS ENUM ('customer', 'driver', 'restaurant_owner', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'in_transit', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_method AS ENUM ('credit_card', 'debit_card', 'pix', 'cash', 'mercado_pago', 'stripe');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded', 'partially_refunded');
CREATE TYPE driver_status AS ENUM ('offline', 'online', 'busy', 'on_delivery');
CREATE TYPE vehicle_type AS ENUM ('motorcycle', 'bicycle', 'car', 'scooter', 'walking');
CREATE TYPE day_of_week AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
CREATE TYPE notification_type AS ENUM ('order_update', 'promotion', 'system', 'payment', 'driver_message');
CREATE TYPE audit_action AS ENUM ('create', 'update', 'delete', 'login', 'logout', 'status_change');
CREATE TYPE entity_type AS ENUM ('user', 'restaurant', 'order', 'product', 'driver', 'payment', 'coupon');

-- ============================================================
-- USER ACCOUNT
-- ============================================================
CREATE TABLE user_account (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  role user_role NOT NULL DEFAULT 'customer',
  avatar_url TEXT,
  email_verified BOOLEAN DEFAULT FALSE,
  phone_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_deleted BOOLEAN DEFAULT FALSE,
  last_login_at TIMESTAMPTZ,
  reset_password_token VARCHAR(255),
  reset_password_expires TIMESTAMPTZ,
  email_verification_token VARCHAR(255),
  fcm_token TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_account_email ON user_account(email) WHERE is_deleted = FALSE;
CREATE INDEX idx_user_account_role ON user_account(role) WHERE is_deleted = FALSE;

-- ============================================================
-- REFRESH TOKEN
-- ============================================================
CREATE TABLE refresh_token (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_account(id) ON DELETE CASCADE,
  token VARCHAR(500) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_token_user ON refresh_token(user_id);
CREATE INDEX idx_refresh_token_token ON refresh_token(token);

-- ============================================================
-- DRIVER PROFILE
-- ============================================================
CREATE TABLE driver_profile (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES user_account(id) ON DELETE CASCADE,
  vehicle_type vehicle_type NOT NULL DEFAULT 'motorcycle',
  vehicle_plate VARCHAR(20),
  vehicle_model VARCHAR(100),
  vehicle_color VARCHAR(50),
  license_number VARCHAR(50),
  status driver_status NOT NULL DEFAULT 'offline',
  is_verified BOOLEAN DEFAULT FALSE,
  is_available BOOLEAN DEFAULT TRUE,
  rating DECIMAL(3,2) DEFAULT 5.00,
  total_reviews INTEGER DEFAULT 0,
  total_deliveries INTEGER DEFAULT 0,
  current_latitude DECIMAL(10,7),
  current_longitude DECIMAL(10,7),
  last_location_update TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_driver_profile_status ON driver_profile(status, is_available);
CREATE INDEX idx_driver_profile_location ON driver_profile(current_latitude, current_longitude);

-- ============================================================
-- ADDRESS
-- ============================================================
CREATE TABLE address (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_account(id) ON DELETE CASCADE,
  label VARCHAR(50) DEFAULT 'Home',
  street VARCHAR(255) NOT NULL,
  number VARCHAR(20),
  complement VARCHAR(100),
  neighborhood VARCHAR(100),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50) NOT NULL,
  zip_code VARCHAR(10) NOT NULL,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_address_user ON address(user_id);

-- ============================================================
-- RESTAURANT
-- ============================================================
CREATE TABLE restaurant (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID NOT NULL REFERENCES user_account(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  phone VARCHAR(20),
  email VARCHAR(255),
  website VARCHAR(255),
  logo_url TEXT,
  banner_url TEXT,
  street VARCHAR(255) NOT NULL,
  number VARCHAR(20),
  complement VARCHAR(100),
  neighborhood VARCHAR(100),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50) NOT NULL,
  zip_code VARCHAR(10) NOT NULL,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  minimum_order DECIMAL(10,2) DEFAULT 0,
  delivery_radius_km DECIMAL(5,2) DEFAULT 5.00,
  preparation_time_min INTEGER DEFAULT 30,
  is_active BOOLEAN DEFAULT TRUE,
  is_open BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE,
  rating DECIMAL(3,2) DEFAULT 0,
  total_reviews INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_restaurant_owner ON restaurant(owner_id);
CREATE INDEX idx_restaurant_location ON restaurant(latitude, longitude);
CREATE INDEX idx_restaurant_active ON restaurant(is_active, is_open) WHERE is_deleted = FALSE;
CREATE INDEX idx_restaurant_slug ON restaurant(slug);

-- ============================================================
-- RESTAURANT HOURS
-- ============================================================
CREATE TABLE restaurant_hours (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
  day_of_week day_of_week NOT NULL,
  open_time TIME NOT NULL,
  close_time TIME NOT NULL,
  is_closed BOOLEAN DEFAULT FALSE,
  UNIQUE(restaurant_id, day_of_week)
);

-- ============================================================
-- RESTAURANT CATEGORY
-- ============================================================
CREATE TABLE restaurant_category (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  icon VARCHAR(50)
);

-- ============================================================
-- RESTAURANT CATEGORIZATION
-- ============================================================
CREATE TABLE restaurant_categorization (
  restaurant_id UUID NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES restaurant_category(id) ON DELETE CASCADE,
  PRIMARY KEY (restaurant_id, category_id)
);

-- ============================================================
-- RESTAURANT ZONE (delivery areas)
-- ============================================================
CREATE TABLE restaurant_zone (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  geometry JSONB NOT NULL,
  delivery_fee DECIMAL(10,2),
  minimum_order DECIMAL(10,2),
  estimated_time_min INTEGER,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_restaurant_zone_restaurant ON restaurant_zone(restaurant_id);

-- ============================================================
-- PRODUCT
-- ============================================================
CREATE TABLE product (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  restaurant_id UUID NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  discounted_price DECIMAL(10,2),
  image_url TEXT,
  category VARCHAR(100),
  is_available BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE,
  stock INTEGER DEFAULT -1,
  preparation_time_min INTEGER,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_product_restaurant ON product(restaurant_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_product_category ON product(restaurant_id, category) WHERE is_deleted = FALSE;

-- ============================================================
-- PRODUCT VARIANT (e.g., sizes)
-- ============================================================
CREATE TABLE product_variant (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  price_adjustment DECIMAL(10,2) DEFAULT 0,
  is_available BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0
);

CREATE INDEX idx_product_variant_product ON product_variant(product_id);

-- ============================================================
-- PRODUCT EXTRA (e.g., additional ingredients)
-- ============================================================
CREATE TABLE product_extra (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  is_available BOOLEAN DEFAULT TRUE,
  max_quantity INTEGER DEFAULT 5,
  sort_order INTEGER DEFAULT 0
);

CREATE INDEX idx_product_extra_product ON product_extra(product_id);

-- ============================================================
-- ORDERS
-- ============================================================
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number VARCHAR(20) UNIQUE NOT NULL,
  customer_id UUID NOT NULL REFERENCES user_account(id),
  restaurant_id UUID NOT NULL REFERENCES restaurant(id),
  driver_id UUID REFERENCES driver_profile(id),
  status order_status NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(10,2) NOT NULL,
  delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  discount DECIMAL(10,2) NOT NULL DEFAULT 0,
  tip DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  payment_method payment_method,
  payment_status payment_status DEFAULT 'pending',
  delivery_address_id UUID REFERENCES address(id),
  delivery_latitude DECIMAL(10,7),
  delivery_longitude DECIMAL(10,7),
  delivery_instructions TEXT,
  estimated_delivery_time TIMESTAMPTZ,
  actual_delivery_time TIMESTAMPTZ,
  coupon_id UUID,
  platform_fee DECIMAL(10,2) DEFAULT 0,
  restaurant_earnings DECIMAL(10,2) DEFAULT 0,
  driver_earnings DECIMAL(10,2) DEFAULT 0,
  customer_rating INTEGER CHECK (customer_rating >= 1 AND customer_rating <= 5),
  customer_review TEXT,
  is_scheduled BOOLEAN DEFAULT FALSE,
  scheduled_time TIMESTAMPTZ,
  cancelled_by VARCHAR(50),
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_driver ON orders(driver_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);

-- ============================================================
-- ORDER ITEM
-- ============================================================
CREATE TABLE order_item (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES product(id),
  variant_id UUID REFERENCES product_variant(id),
  product_name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  special_instructions TEXT
);

CREATE INDEX idx_order_item_order ON order_item(order_id);

-- ============================================================
-- ORDER ITEM EXTRA
-- ============================================================
CREATE TABLE order_item_extra (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_item_id UUID NOT NULL REFERENCES order_item(id) ON DELETE CASCADE,
  extra_name VARCHAR(100) NOT NULL,
  extra_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  quantity INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_order_item_extra_item ON order_item_extra(order_item_id);

-- ============================================================
-- ORDER STATUS HISTORY
-- ============================================================
CREATE TABLE order_status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status order_status NOT NULL,
  changed_by UUID REFERENCES user_account(id),
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_status_history_order ON order_status_history(order_id);

-- ============================================================
-- PAYMENT
-- ============================================================
CREATE TABLE payment (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  gateway VARCHAR(50) NOT NULL,
  gateway_payment_id VARCHAR(255),
  gateway_status VARCHAR(50),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'BRL',
  payment_method payment_method NOT NULL,
  status payment_status NOT NULL DEFAULT 'pending',
  fee DECIMAL(10,2) DEFAULT 0,
  net_amount DECIMAL(10,2),
  metadata JSONB,
  paid_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_order ON payment(order_id);

-- ============================================================
-- DRIVER DOCUMENT
-- ============================================================
CREATE TABLE driver_document (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_profile_id UUID NOT NULL REFERENCES driver_profile(id) ON DELETE CASCADE,
  document_type VARCHAR(50) NOT NULL,
  document_url TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  verified_by UUID REFERENCES user_account(id),
  verified_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_driver_document_profile ON driver_document(driver_profile_id);

-- ============================================================
-- DRIVER EARNINGS
-- ============================================================
CREATE TABLE driver_earnings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_profile_id UUID NOT NULL REFERENCES driver_profile(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT 'delivery',
  status VARCHAR(20) DEFAULT 'pending',
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_driver_earnings_profile ON driver_earnings(driver_profile_id);
CREATE INDEX idx_driver_earnings_status ON driver_earnings(status);

-- ============================================================
-- DRIVER CURRENT LOCATION
-- ============================================================
CREATE TABLE driver_current_location (
  driver_profile_id UUID PRIMARY KEY REFERENCES driver_profile(id) ON DELETE CASCADE,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  accuracy DECIMAL(10,2),
  heading DECIMAL(5,2),
  speed DECIMAL(5,2),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- DRIVER LOCATION HISTORY (PARTITIONED)
-- ============================================================
CREATE TABLE driver_location_history (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  driver_profile_id UUID NOT NULL REFERENCES driver_profile(id) ON DELETE CASCADE,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  accuracy DECIMAL(10,2),
  heading DECIMAL(5,2),
  speed DECIMAL(5,2),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (recorded_at);

CREATE INDEX idx_dlh_driver_time ON driver_location_history(driver_profile_id, recorded_at DESC);

-- Function to create monthly partitions
CREATE OR REPLACE FUNCTION create_location_history_partition()
RETURNS void AS $$
DECLARE
  partition_date DATE;
  partition_name TEXT;
  start_date TEXT;
  end_date TEXT;
BEGIN
  FOR month_offset IN 0..2 LOOP
    partition_date := date_trunc('month', NOW()) + (month_offset || ' months')::INTERVAL;
    partition_name := 'driver_location_history_' || to_char(partition_date, 'YYYY_MM');
    start_date := to_char(partition_date, 'YYYY-MM-DD');
    end_date := to_char(partition_date + INTERVAL '1 month', 'YYYY-MM-DD');

    IF NOT EXISTS (
      SELECT 1 FROM pg_class WHERE relname = partition_name
    ) THEN
      EXECUTE format(
        'CREATE TABLE %I PARTITION OF driver_location_history FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
      );
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- REVIEW
-- ============================================================
CREATE TABLE review (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES user_account(id),
  driver_profile_id UUID REFERENCES driver_profile(id),
  restaurant_rating INTEGER NOT NULL CHECK (restaurant_rating >= 1 AND restaurant_rating <= 5),
  driver_rating INTEGER CHECK (driver_rating >= 1 AND driver_rating <= 5),
  comment TEXT,
  response TEXT,
  responded_at TIMESTAMPTZ,
  is_visible BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_review_restaurant ON review(restaurant_id);
CREATE INDEX idx_review_customer ON review(customer_id);

-- Trigger to update restaurant rating
CREATE OR REPLACE FUNCTION update_restaurant_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE restaurant
  SET
    rating = (SELECT ROUND(AVG(restaurant_rating)::numeric, 2) FROM review WHERE restaurant_id = NEW.restaurant_id AND is_visible = TRUE),
    total_reviews = (SELECT COUNT(*) FROM review WHERE restaurant_id = NEW.restaurant_id AND is_visible = TRUE)
  WHERE id = NEW.restaurant_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_restaurant_rating
  AFTER INSERT OR UPDATE OF restaurant_rating
  ON review
  FOR EACH ROW
  EXECUTE FUNCTION update_restaurant_rating();

-- Trigger to update driver rating
CREATE OR REPLACE FUNCTION update_driver_rating()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.driver_rating IS NOT NULL THEN
    UPDATE driver_profile
    SET
      rating = (SELECT ROUND(AVG(driver_rating)::numeric, 2) FROM review WHERE driver_profile_id = NEW.driver_profile_id AND driver_rating IS NOT NULL),
      total_reviews = (SELECT COUNT(*) FROM review WHERE driver_profile_id = NEW.driver_profile_id AND driver_rating IS NOT NULL)
    WHERE id = NEW.driver_profile_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_driver_rating
  AFTER INSERT OR UPDATE OF driver_rating
  ON review
  FOR EACH ROW
  EXECUTE FUNCTION update_driver_rating();

-- ============================================================
-- COUPON
-- ============================================================
CREATE TABLE coupon (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value DECIMAL(10,2) NOT NULL,
  minimum_order DECIMAL(10,2) DEFAULT 0,
  max_discount DECIMAL(10,2),
  max_uses INTEGER,
  current_uses INTEGER DEFAULT 0,
  max_uses_per_user INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT TRUE,
  valid_from TIMESTAMPTZ NOT NULL,
  valid_until TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_coupon_code ON coupon(code);
CREATE INDEX idx_coupon_active ON coupon(is_active, valid_from, valid_until);

-- ============================================================
-- COUPON RESTAURANT
-- ============================================================
CREATE TABLE coupon_restaurant (
  coupon_id UUID NOT NULL REFERENCES coupon(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES restaurant(id) ON DELETE CASCADE,
  PRIMARY KEY (coupon_id, restaurant_id)
);

-- ============================================================
-- CHAT CONVERSATION
-- ============================================================
CREATE TABLE chat_conversation (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID NOT NULL REFERENCES user_account(id),
  restaurant_id UUID REFERENCES restaurant(id),
  driver_profile_id UUID REFERENCES driver_profile(id),
  subject VARCHAR(255),
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_conversation_customer ON chat_conversation(customer_id);

-- ============================================================
-- CHAT MESSAGE
-- ============================================================
CREATE TABLE chat_message (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES chat_conversation(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES user_account(id),
  content TEXT NOT NULL,
  message_type VARCHAR(20) DEFAULT 'text',
  metadata JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_message_conversation ON chat_message(conversation_id, created_at);

-- ============================================================
-- NOTIFICATION
-- ============================================================
CREATE TABLE notification (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES user_account(id) ON DELETE CASCADE,
  type notification_type NOT NULL DEFAULT 'system',
  title VARCHAR(255) NOT NULL,
  body TEXT,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notification_user ON notification(user_id, is_read, created_at DESC);

-- ============================================================
-- OUTBOX EVENT (for eventual consistency / event-driven)
-- ============================================================
CREATE TABLE outbox_event (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_type VARCHAR(100) NOT NULL,
  aggregate_type VARCHAR(100) NOT NULL,
  aggregate_id UUID NOT NULL,
  payload JSONB NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  last_error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed_at TIMESTAMPTZ
);

CREATE INDEX idx_outbox_event_status ON outbox_event(status, created_at);

-- ============================================================
-- AUDIT LOG
-- ============================================================
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_account(id),
  action audit_action NOT NULL,
  entity_type entity_type NOT NULL,
  entity_id UUID,
  changes JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_user ON audit_log(user_id);
CREATE INDEX idx_audit_log_created ON audit_log(created_at DESC);

-- ============================================================
-- AUTO-UPDATE updated_at TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_account_updated_at
  BEFORE UPDATE ON user_account FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_restaurant_updated_at
  BEFORE UPDATE ON restaurant FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_product_updated_at
  BEFORE UPDATE ON product FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_driver_profile_updated_at
  BEFORE UPDATE ON driver_profile FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_driver_document_updated_at
  BEFORE UPDATE ON driver_document FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_payment_updated_at
  BEFORE UPDATE ON payment FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_address_updated_at
  BEFORE UPDATE ON address FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trg_review_updated_at
  BEFORE UPDATE ON review FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
