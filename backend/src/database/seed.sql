-- ============================================================
-- SEED: Datos demo completos
-- Password para TODOS los usuarios: crear123
-- Hash bcrypt: $2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku
-- ============================================================

-- ============================================================
-- 1. USUARIOS
-- ============================================================
INSERT INTO user_account (email, password_hash, first_name, last_name, role, email_verified, phone, is_active)
VALUES
  -- Admin
  ('rodrigocussivalenzuela@gmail.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Rodrigo', 'Cussi', 'admin', TRUE, '+525512345678', TRUE),

  -- Dueños de restaurantes
  ('carlos@italianisimo.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Carlos', 'Mendoza', 'restaurant_owner', TRUE, '+525512345679', TRUE),
  ('maria@sushimaster.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'María', 'García', 'restaurant_owner', TRUE, '+525512345680', TRUE),
  ('juan@tacoselvaquero.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Juan', 'Martínez', 'restaurant_owner', TRUE, '+525512345681', TRUE),
  ('ana@labellaitalia.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Ana', 'Rodríguez', 'restaurant_owner', TRUE, '+525512345682', TRUE),
  ('pedro@burgerhouse.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Pedro', 'Sánchez', 'restaurant_owner', TRUE, '+525512345683', TRUE),

  -- Repartidores
  ('luis@driver.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Luis', 'Hernández', 'driver', TRUE, '+525512345684', TRUE),
  ('sofia@driver.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Sofía', 'Ramírez', 'driver', TRUE, '+525512345685', TRUE),
  ('diego@driver.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Diego', 'Torres', 'driver', TRUE, '+525512345686', TRUE),
  ('valentina@driver.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Valentina', 'López', 'driver', TRUE, '+525512345687', TRUE),

  -- Clientes
  ('cliente1@test.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Roberto', 'González', 'customer', TRUE, '+525512345688', TRUE),
  ('cliente2@test.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Laura', 'Fernández', 'customer', TRUE, '+525512345689', TRUE),
  ('cliente3@test.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Miguel', 'Ángel', 'customer', TRUE, '+525512345690', TRUE),
  ('cliente4@test.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Fernanda', 'Morales', 'customer', TRUE, '+525512345691', TRUE),
  ('cliente5@test.com', '$2a$12$kc0ZJuRtB8alrfJEB4CNaeqDZRAiszbrYatu1MdbRNwBqJP0olDku', 'Ricardo', 'Pérez', 'customer', TRUE, '+525512345692', TRUE)
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- 2. CATEGORÍAS DE RESTAURANTES
-- ============================================================
INSERT INTO restaurant_category (name, slug, icon)
VALUES
  ('Italiana', 'italiana', 'pizza'),
  ('Sushi', 'sushi', 'fish'),
  ('Mexicana', 'mexicana', 'taco'),
  ('Hamburguesas', 'hamburguesas', 'burger'),
  ('Pizza', 'pizza', 'pizza'),
  ('Ensaladas', 'ensaladas', 'salad'),
  ('Desayunos', 'desayunos', 'coffee'),
  ('Mariscos', 'mariscos', 'fish'),
  ('Vegetariana', 'vegetariana', 'leaf'),
  ('Postres', 'postres', 'cake')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- 3. RESTAURANTES
-- ============================================================
DO $$
DECLARE
  owner_italianisimo UUID;
  owner_sushi UUID;
  owner_tacos UUID;
  owner_bella UUID;
  owner_burger UUID;
  cat_italiana UUID;
  cat_sushi UUID;
  cat_mexicana UUID;
  cat_burger UUID;
  cat_pizza UUID;
  r_italianisimo UUID;
  r_sushi UUID;
  r_tacos UUID;
  r_bella UUID;
  r_burger UUID;
BEGIN
  SELECT id INTO owner_italianisimo FROM user_account WHERE email = 'carlos@italianisimo.com';
  SELECT id INTO owner_sushi FROM user_account WHERE email = 'maria@sushimaster.com';
  SELECT id INTO owner_tacos FROM user_account WHERE email = 'juan@tacoselvaquero.com';
  SELECT id INTO owner_bella FROM user_account WHERE email = 'ana@labellaitalia.com';
  SELECT id INTO owner_burger FROM user_account WHERE email = 'pedro@burgerhouse.com';
  SELECT id INTO cat_italiana FROM restaurant_category WHERE slug = 'italiana';
  SELECT id INTO cat_sushi FROM restaurant_category WHERE slug = 'sushi';
  SELECT id INTO cat_mexicana FROM restaurant_category WHERE slug = 'mexicana';
  SELECT id INTO cat_burger FROM restaurant_category WHERE slug = 'hamburguesas';
  SELECT id INTO cat_pizza FROM restaurant_category WHERE slug = 'pizza';

  -- Italianísimo
  INSERT INTO restaurant (owner_id, name, slug, description, phone, street, number, neighborhood, city, state, zip_code, latitude, longitude, delivery_fee, minimum_order, preparation_time_min, is_active, is_open)
  VALUES (owner_italianisimo, 'Italianísimo', 'italianisimo', 'La mejor pasta artesanal de la ciudad. Recetas tradicionales italianas con ingredientes frescos.', '+525512340001', 'Av. Reforma', '250', 'Juárez', 'Ciudad de México', 'CDMX', '06600', 19.4260, -99.1678, 35.00, 80.00, 30, TRUE, TRUE)
  ON CONFLICT (slug) DO UPDATE SET is_active = TRUE RETURNING id INTO r_italianisimo;

  -- Sushi Master
  INSERT INTO restaurant (owner_id, name, slug, description, phone, street, number, neighborhood, city, state, zip_code, latitude, longitude, delivery_fee, minimum_order, preparation_time_min, is_active, is_open)
  VALUES (owner_sushi, 'Sushi Master', 'sushi-master', 'Sushi fresco preparado por chefs japoneses. Rolls creativos y tradicionales.', '+525512340002', 'Av. Insurgentes Sur', '520', 'Roma Norte', 'Ciudad de México', 'CDMX', '06700', 19.4194, -99.1655, 40.00, 100.00, 25, TRUE, TRUE)
  ON CONFLICT (slug) DO UPDATE SET is_active = TRUE RETURNING id INTO r_sushi;

  -- Tacos El Vaquero
  INSERT INTO restaurant (owner_id, name, slug, description, phone, street, number, neighborhood, city, state, zip_code, latitude, longitude, delivery_fee, minimum_order, preparation_time_min, is_active, is_open)
  VALUES (owner_tacos, 'Tacos El Vaquero', 'tacos-el-vaquero', 'Tacos al pastor, de asada y más. El sabor auténtico de México en cada bocado.', '+525512340003', 'Calle Madero', '120', 'Centro', 'Ciudad de México', 'CDMX', '06000', 19.4333, -99.1400, 25.00, 60.00, 20, TRUE, TRUE)
  ON CONFLICT (slug) DO UPDATE SET is_active = TRUE RETURNING id INTO r_tacos;

  -- La Bella Italia
  INSERT INTO restaurant (owner_id, name, slug, description, phone, street, number, neighborhood, city, state, zip_code, latitude, longitude, delivery_fee, minimum_order, preparation_time_min, is_active, is_open)
  VALUES (owner_bella, 'La Bella Italia', 'la-bella-italia', 'Auténtica cocina italiana con un toque moderno. Pizzas al horno de leña y pastas artesanales.', '+525512340004', 'Av. Mazatlán', '85', 'Condesa', 'Ciudad de México', 'CDMX', '06140', 19.4110, -99.1750, 30.00, 90.00, 35, TRUE, TRUE)
  ON CONFLICT (slug) DO UPDATE SET is_active = TRUE RETURNING id INTO r_bella;

  -- Burger House
  INSERT INTO restaurant (owner_id, name, slug, description, phone, street, number, neighborhood, city, state, zip_code, latitude, longitude, delivery_fee, minimum_order, preparation_time_min, is_active, is_open)
  VALUES (owner_burger, 'Burger House', 'burger-house', 'Hamburguesas gourmet con carne angus, ingredientes frescos y papas crujientes.', '+525512340005', 'Av. Coyoacán', '400', 'Del Valle', 'Ciudad de México', 'CDMX', '03100', 19.3870, -99.1620, 30.00, 70.00, 20, TRUE, TRUE)
  ON CONFLICT (slug) DO UPDATE SET is_active = TRUE RETURNING id INTO r_burger;

  -- Categorías
  INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES (r_italianisimo, cat_italiana) ON CONFLICT DO NOTHING;
  INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES (r_italianisimo, cat_pizza) ON CONFLICT DO NOTHING;
  INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES (r_sushi, cat_sushi) ON CONFLICT DO NOTHING;
  INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES (r_tacos, cat_mexicana) ON CONFLICT DO NOTHING;
  INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES (r_bella, cat_italiana) ON CONFLICT DO NOTHING;
  INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES (r_bella, cat_pizza) ON CONFLICT DO NOTHING;
  INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES (r_burger, cat_burger) ON CONFLICT DO NOTHING;

  -- ============================================================
  -- 4. HORARIOS DE RESTAURANTES
  -- ============================================================
  INSERT INTO restaurant_hours (restaurant_id, day_of_week, open_time, close_time)
  VALUES
    (r_italianisimo, 'monday', '12:00', '23:00'), (r_italianisimo, 'tuesday', '12:00', '23:00'),
    (r_italianisimo, 'wednesday', '12:00', '23:00'), (r_italianisimo, 'thursday', '12:00', '23:00'),
    (r_italianisimo, 'friday', '12:00', '01:00'), (r_italianisimo, 'saturday', '13:00', '01:00'),
    (r_italianisimo, 'sunday', '13:00', '22:00'),
    (r_sushi, 'monday', '11:00', '22:30'), (r_sushi, 'tuesday', '11:00', '22:30'),
    (r_sushi, 'wednesday', '11:00', '22:30'), (r_sushi, 'thursday', '11:00', '23:00'),
    (r_sushi, 'friday', '11:00', '23:30'), (r_sushi, 'saturday', '12:00', '23:30'),
    (r_sushi, 'sunday', '12:00', '21:00'),
    (r_tacos, 'monday', '09:00', '02:00'), (r_tacos, 'tuesday', '09:00', '02:00'),
    (r_tacos, 'wednesday', '09:00', '02:00'), (r_tacos, 'thursday', '09:00', '03:00'),
    (r_tacos, 'friday', '09:00', '04:00'), (r_tacos, 'saturday', '10:00', '04:00'),
    (r_tacos, 'sunday', '10:00', '01:00'),
    (r_bella, 'monday', '13:00', '23:00'), (r_bella, 'tuesday', '13:00', '23:00'),
    (r_bella, 'wednesday', '13:00', '23:00'), (r_bella, 'thursday', '13:00', '23:00'),
    (r_bella, 'friday', '13:00', '00:30'), (r_bella, 'saturday', '14:00', '00:30'),
    (r_bella, 'sunday', '14:00', '22:00'),
    (r_burger, 'monday', '10:00', '23:00'), (r_burger, 'tuesday', '10:00', '23:00'),
    (r_burger, 'wednesday', '10:00', '23:00'), (r_burger, 'thursday', '10:00', '23:30'),
    (r_burger, 'friday', '10:00', '01:00'), (r_burger, 'saturday', '11:00', '01:00'),
    (r_burger, 'sunday', '11:00', '22:00')
  ON CONFLICT (restaurant_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;

  -- ============================================================
  -- 5. PRODUCTOS
  -- ============================================================
  -- Italianísimo
  INSERT INTO product (restaurant_id, name, description, price, category, is_available, stock)
  VALUES
    (r_italianisimo, 'Spaghetti Carbonara', 'Spaghetti con salsa carbonara tradicional, huevo, queso parmesano y panceta', 185.00, 'Pastas', TRUE, 50),
    (r_italianisimo, 'Pizza Margherita', 'Pizza clásica con salsa de tomate, mozzarella fresca y albahaca', 165.00, 'Pizzas', TRUE, 40),
    (r_italianisimo, 'Risotto ai Funghi', 'Risotto cremoso con hongos mixtos y parmesano', 210.00, 'Risottos', TRUE, 30),
    (r_italianisimo, 'Lasaña Bolognese', 'Lasaña clásica con salsa boloñesa, bechamel y queso gratinado', 195.00, 'Pastas', TRUE, 35),
    (r_italianisimo, 'Tiramisú', 'Postre italiano tradicional con café, mascarpone y cacao', 95.00, 'Postres', TRUE, 25),
    (r_italianisimo, 'Bruschetta', 'Pan tostado con tomate cherry, albahaca, ajo y aceite de oliva', 85.00, 'Entradas', TRUE, 45),
    (r_italianisimo, 'Carpaccio de Res', 'Finas láminas de res con rúcula, parmesano y vinagreta balsámica', 145.00, 'Entradas', TRUE, 30),
    (r_italianisimo, 'Pizza Pepperoni', 'Pizza con pepperoni, mozzarella y salsa de tomate', 175.00, 'Pizzas', TRUE, 40)
  ON CONFLICT DO NOTHING;

  -- Sushi Master
  INSERT INTO product (restaurant_id, name, description, price, category, is_available, stock)
  VALUES
    (r_sushi, 'Roll Salmón Philadelphia', 'Roll de salmón fresco con queso crema y aguacate', 195.00, 'Rolls', TRUE, 40),
    (r_sushi, 'Nigiri Mix (8 pzas)', '8 piezas de nigiri variado: salmón, atún, pez mantequilla', 245.00, 'Nigiri', TRUE, 30),
    (r_sushi, 'Dragon Roll', 'Roll de camarón tempura con aguacate y salsa anguila', 215.00, 'Rolls Especiales', TRUE, 35),
    (r_sushi, 'California Roll', 'Roll clásico de cangrejo, aguacate y pepino', 145.00, 'Rolls', TRUE, 50),
    (r_sushi, 'Tataki de Atún', 'Atún sellado con salsa ponzu y jengibre', 225.00, 'Especiales', TRUE, 25),
    (r_sushi, 'Edamame', 'Vainas de soya al vapor con sal de mar', 65.00, 'Entradas', TRUE, 60),
    (r_sushi, 'Sashimi Salmón (12 pzas)', '12 piezas de sashimi de salmón fresco', 285.00, 'Sashimi', TRUE, 25),
    (r_sushi, 'Tempura Roll', 'Roll de camarón y vegetales tempura', 175.00, 'Rolls', TRUE, 35)
  ON CONFLICT DO NOTHING;

  -- Tacos El Vaquero
  INSERT INTO product (restaurant_id, name, description, price, category, is_available, stock)
  VALUES
    (r_tacos, 'Taco al Pastor (4)', '4 tacos al pastor con piña, cebolla y cilantro', 89.00, 'Tacos', TRUE, 100),
    (r_tacos, 'Taco de Asada (4)', '4 tacos de carne asada con guacamole', 99.00, 'Tacos', TRUE, 80),
    (r_tacos, 'Taco de Carnitas (4)', '4 tacos de carnitas con salsa verde', 85.00, 'Tacos', TRUE, 75),
    (r_tacos, 'Quesadilla de Huitlacoche', 'Quesadilla grande con huitlacoche y queso Oaxaca', 75.00, 'Quesadillas', TRUE, 40),
    (r_tacos, 'Torta Ahogada', 'Torta bañada en salsa de tomate con carne de cerdo', 120.00, 'Tortas', TRUE, 35),
    (r_tacos, 'Guacamole con Totopos', 'Guacamole fresco con totopos de maíz', 70.00, 'Entradas', TRUE, 50),
    (r_tacos, 'Agua de Horchata 1L', 'Agua fresca de horchata tradicional', 35.00, 'Bebidas', TRUE, 100),
    (r_tacos, 'Flan Napolitano', 'Flan cremoso con caramelo', 55.00, 'Postres', TRUE, 30)
  ON CONFLICT DO NOTHING;

  -- La Bella Italia
  INSERT INTO product (restaurant_id, name, description, price, category, is_available, stock)
  VALUES
    (r_bella, 'Pizza Quattro Formaggi', 'Pizza con mozzarella, gorgonzola, parmesano y fontina', 195.00, 'Pizzas', TRUE, 35),
    (r_bella, 'Pasta Alfredo con Pollo', 'Fettuccine Alfredo con pollo a la parrilla', 185.00, 'Pastas', TRUE, 40),
    (r_bella, 'Pizza Prosciutto e Rucola', 'Pizza con jamón serrano, rúcula y parmesano', 210.00, 'Pizzas', TRUE, 30),
    (r_bella, 'Spaghetti al Pesto', 'Spaghetti con pesto genovés, piñones y albahaca', 175.00, 'Pastas', TRUE, 35),
    (r_bella, 'Panna Cotta', 'Postre italiano con frutos rojos', 85.00, 'Postres', TRUE, 30),
    (r_bella, 'Insalata Caprese', 'Ensalada de tomate, mozzarella fresca y albahaca', 95.00, 'Ensaladas', TRUE, 45),
    (r_bella, 'Pizza Napoletana', 'Pizza napolitana con anchoas, alcaparras y aceitunas', 185.00, 'Pizzas', TRUE, 30),
    (r_bella, 'Limonata 500ml', 'Limonada natural fresca', 45.00, 'Bebidas', TRUE, 100)
  ON CONFLICT DO NOTHING;

  -- Burger House
  INSERT INTO product (restaurant_id, name, description, price, category, is_available, stock)
  VALUES
    (r_burger, 'Classic Angus Burger', 'Hamburguesa angus 200g con lechuga, tomate, cebolla y pepinillos', 149.00, 'Hamburguesas', TRUE, 50),
    (r_burger, 'BBQ Bacon Burger', 'Hamburguesa angus con BBQ, bacon crujiente, queso cheddar y aros de cebolla', 179.00, 'Hamburguesas', TRUE, 40),
    (r_burger, 'Veggie Burger', 'Hamburguesa vegetal con quinoa, espinaca y champiñones', 139.00, 'Hamburguesas', TRUE, 30),
    (r_burger, 'Papas Fritas con Queso', 'Papas fritas crujientes con queso cheddar fundido y jalapeños', 79.00, 'Acompañantes', TRUE, 60),
    (r_burger, 'Aros de Cebolla', 'Aros de cebolla empanizados con salsa ranch', 69.00, 'Acompañantes', TRUE, 50),
    (r_burger, 'Milk Shake de Fresa', 'Malteada cremosa de fresa con crema batida', 65.00, 'Bebidas', TRUE, 40),
    (r_burger, 'Double Cheese Burger', 'Doble carne angus con doble queso, lechuga y tomate', 199.00, 'Hamburguesas', TRUE, 35),
    (r_burger, 'Chicken Crispy Sandwich', 'Pechuga de pollo empanizada con lechuga, tomate y mayonesa', 139.00, 'Sandwiches', TRUE, 40)
  ON CONFLICT DO NOTHING;

  -- ============================================================
  -- 6. DIRECCIONES DE CLIENTES
  -- ============================================================
  INSERT INTO address (user_id, label, street, number, complement, neighborhood, city, state, zip_code, latitude, longitude, is_default)
  SELECT id, 'Casa', 'Av. Álvaro Obregón', '150', 'Depto 3', 'Roma Norte', 'Ciudad de México', 'CDMX', '06700', 19.4180, -99.1650, TRUE
  FROM user_account u
  WHERE u.email = 'cliente1@test.com'
    AND NOT EXISTS (SELECT 1 FROM address a WHERE a.user_id = u.id);

  INSERT INTO address (user_id, label, street, number, complement, neighborhood, city, state, zip_code, latitude, longitude, is_default)
  SELECT id, 'Casa', 'Av. Universidad', '800', 'Casa 5', 'Del Valle', 'Ciudad de México', 'CDMX', '03100', 19.3880, -99.1630, TRUE
  FROM user_account u
  WHERE u.email = 'cliente2@test.com'
    AND NOT EXISTS (SELECT 1 FROM address a WHERE a.user_id = u.id);

  INSERT INTO address (user_id, label, street, number, complement, neighborhood, city, state, zip_code, latitude, longitude, is_default)
  SELECT id, 'Oficina', 'Paseo de la Reforma', '300', 'Piso 12', 'Juárez', 'Ciudad de México', 'CDMX', '06600', 19.4320, -99.1650, TRUE
  FROM user_account u
  WHERE u.email = 'cliente3@test.com'
    AND NOT EXISTS (SELECT 1 FROM address a WHERE a.user_id = u.id);

  -- ============================================================
  -- 7. PERFILES DE REPARTIDORES
  -- ============================================================
  INSERT INTO driver_profile (user_id, vehicle_type, vehicle_plate, vehicle_model, vehicle_color, license_number, status, is_verified, is_available, rating, total_deliveries)
  SELECT id, 'motorcycle', 'MOT-1234', 'Italika 250', 'Rojo', 'LIC-LH-001', 'online', TRUE, TRUE, 4.8, 320
  FROM user_account WHERE email = 'luis@driver.com'
  ON CONFLICT (user_id) DO UPDATE SET status = 'online', is_available = TRUE;

  INSERT INTO driver_profile (user_id, vehicle_type, vehicle_plate, vehicle_model, vehicle_color, license_number, status, is_verified, is_available, rating, total_deliveries)
  SELECT id, 'bicycle', 'BIC-5678', 'Mercedes Benz', 'Azul', 'LIC-SR-002', 'online', TRUE, TRUE, 4.9, 180
  FROM user_account WHERE email = 'sofia@driver.com'
  ON CONFLICT (user_id) DO UPDATE SET status = 'online', is_available = TRUE;

  INSERT INTO driver_profile (user_id, vehicle_type, vehicle_plate, vehicle_model, vehicle_color, license_number, status, is_verified, is_available, rating, total_deliveries)
  SELECT id, 'motorcycle', 'MOT-9012', 'Vento Cross 200', 'Negra', 'LIC-DT-003', 'online', TRUE, TRUE, 4.7, 250
  FROM user_account WHERE email = 'diego@driver.com'
  ON CONFLICT (user_id) DO UPDATE SET status = 'online', is_available = TRUE;

  INSERT INTO driver_profile (user_id, vehicle_type, vehicle_plate, vehicle_model, vehicle_color, license_number, status, is_verified, is_available, rating, total_deliveries)
  SELECT id, 'motorcycle', 'MOT-3456', 'Honda Navi', 'Blanco', 'LIC-VL-004', 'online', TRUE, TRUE, 4.9, 150
  FROM user_account WHERE email = 'valentina@driver.com'
  ON CONFLICT (user_id) DO UPDATE SET status = 'online', is_available = TRUE;

  -- ============================================================
  -- 8. CUPONES
  -- ============================================================
  INSERT INTO coupon (code, description, discount_type, discount_value, minimum_order, max_discount, max_uses, current_uses, is_active, valid_from, valid_until)
  VALUES
    ('BIENVENIDO', '10% de descuento en tu primer pedido', 'percentage', 10, 50.00, 50.00, 1000, 0, TRUE, NOW() - INTERVAL '30 days', NOW() + INTERVAL '60 days'),
    ('PRIMERA', '15% de descuento en restaurantes participantes', 'percentage', 15, 80.00, 75.00, 500, 0, TRUE, NOW() - INTERVAL '30 days', NOW() + INTERVAL '30 days'),
    ('SINENVIO', 'Envío gratis en tu próximo pedido', 'fixed', 40.00, 100.00, NULL, 300, 0, TRUE, NOW() - INTERVAL '15 days', NOW() + INTERVAL '45 days'),
    ('MITAD', '50% de descuento hasta $100', 'percentage', 50, 80.00, 100.00, 100, 0, TRUE, NOW() - INTERVAL '7 days', NOW() + INTERVAL '14 days'),
    ('DELIVERY10', '$10 de descuento en delivery', 'fixed', 10.00, 30.00, NULL, 999, 12, TRUE, NOW() - INTERVAL '60 days', NOW() + INTERVAL '90 days')
  ON CONFLICT (code) DO NOTHING;

  -- ============================================================
  -- 9. PEDIDOS DEMO (últimos 30 días)
  -- ============================================================
  INSERT INTO orders (order_number, customer_id, restaurant_id, driver_id, status, subtotal, delivery_fee, discount, tip, total, payment_method, payment_status, delivery_address_id, platform_fee, actual_delivery_time, created_at)
  SELECT
    'DEL-' || TO_CHAR(d, 'YYMMDD') || '-' || LPAD(ROW_NUMBER() OVER (ORDER BY d)::TEXT, 5, '0'),
    u.id, rest.id, dp.id,
    (CASE
      WHEN d < NOW() - INTERVAL '7 days' THEN 'delivered'::order_status
      WHEN d < NOW() - INTERVAL '2 days' THEN 'delivered'::order_status
      WHEN d < NOW() - INTERVAL '1 day' THEN 'delivered'::order_status
      WHEN d < NOW() - INTERVAL '4 hours' THEN 'in_transit'::order_status
      WHEN d < NOW() - INTERVAL '1 hour' THEN 'picked_up'::order_status
      ELSE 'pending'::order_status
    END),
    150 + (random() * 350)::int, 30 + (random() * 15)::int, 0, (random() * 20)::int, 200 + (random() * 400)::int,
    'credit_card'::payment_method, 'completed'::payment_status, (SELECT id FROM address WHERE user_id = u.id LIMIT 1),
    15 + (random() * 10)::int,
    CASE WHEN d < NOW() - INTERVAL '1 day' THEN d + INTERVAL '30 minutes' + (random() * INTERVAL '20 minutes') ELSE NULL END,
    d
  FROM generate_series(NOW() - INTERVAL '30 days', NOW(), INTERVAL '6 hours') AS d
  CROSS JOIN (SELECT id FROM user_account WHERE email = 'cliente1@test.com' LIMIT 1) u
  CROSS JOIN (SELECT id, delivery_fee FROM restaurant WHERE is_active = TRUE ORDER BY random() LIMIT 1) rest
  CROSS JOIN (SELECT id FROM driver_profile WHERE is_available = TRUE ORDER BY random() LIMIT 1) dp
  WHERE random() < 0.3
  LIMIT 50
  ON CONFLICT (order_number) DO NOTHING;

  -- ============================================================
  -- 10. STATUS HISTORY Y REVIEWS PARA PEDIDOS ENTREGADOS
  -- ============================================================
  INSERT INTO order_status_history (order_id, status, note, created_at)
  SELECT o.id, 'pending', 'Order created', o.created_at
  FROM orders o
  WHERE o.status = 'delivered' AND NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = o.id AND status = 'pending');

  INSERT INTO order_status_history (order_id, status, note, created_at)
  SELECT o.id, 'confirmed', 'Payment confirmed', o.created_at + INTERVAL '2 minutes'
  FROM orders o
  WHERE o.status = 'delivered' AND NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = o.id AND status = 'confirmed');

  INSERT INTO order_status_history (order_id, status, note, created_at)
  SELECT o.id, 'preparing', 'Restaurant is preparing your order', o.created_at + INTERVAL '5 minutes'
  FROM orders o
  WHERE o.status = 'delivered' AND NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = o.id AND status = 'preparing');

  INSERT INTO order_status_history (order_id, status, note, created_at)
  SELECT o.id, 'ready', 'Order is ready for pickup', o.created_at + INTERVAL '25 minutes'
  FROM orders o
  WHERE o.status = 'delivered' AND NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = o.id AND status = 'ready');

  INSERT INTO order_status_history (order_id, status, note, created_at)
  SELECT o.id, 'picked_up', 'Driver picked up the order', o.created_at + INTERVAL '30 minutes'
  FROM orders o
  WHERE o.status = 'delivered' AND NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = o.id AND status = 'picked_up');

  INSERT INTO order_status_history (order_id, status, note, created_at)
  SELECT o.id, 'in_transit', 'Order is on the way', o.created_at + INTERVAL '32 minutes'
  FROM orders o
  WHERE o.status = 'delivered' AND NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = o.id AND status = 'in_transit');

  INSERT INTO order_status_history (order_id, status, note, created_at)
  SELECT o.id, 'delivered', 'Order delivered successfully', o.actual_delivery_time
  FROM orders o
  WHERE o.status = 'delivered' AND o.actual_delivery_time IS NOT NULL AND NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = o.id AND status = 'delivered');

  -- Reviews for delivered orders
  INSERT INTO review (order_id, restaurant_id, customer_id, driver_profile_id, restaurant_rating, driver_rating, comment, created_at)
  SELECT o.id, o.restaurant_id, o.customer_id, o.driver_id,
    (3 + (random() * 2)::int), (4 + (random() * 1)::int),
    (ARRAY['Excelente servicio, muy rápido', 'La comida llegó caliente y deliciosa', 'Todo perfecto, muy recomendable', 'Buena atención, volveré a pedir', 'El repartidor fue muy amable'])[1 + (random() * 4)::int],
    o.actual_delivery_time + INTERVAL '1 hour'
  FROM orders o
  WHERE o.status = 'delivered' AND o.actual_delivery_time IS NOT NULL AND random() < 0.6
  AND NOT EXISTS (SELECT 1 FROM review WHERE order_id = o.id)
  LIMIT 20
  ON CONFLICT (order_id) DO NOTHING;

END $$;
