import { query } from '../../config/database';
import { DriverProfile, DriverEarnings, Order } from '../../shared/interfaces';

export async function getDriverProfileByUserId(userId: string): Promise<DriverProfile | null> {
  const result = await query('SELECT * FROM driver_profile WHERE user_id = $1', [userId]);
  return result.rows[0] || null;
}

export async function getDriverProfileById(id: string): Promise<DriverProfile | null> {
  const result = await query('SELECT * FROM driver_profile WHERE id = $1', [id]);
  return result.rows[0] || null;
}

export async function updateDriverProfile(userId: string, data: any): Promise<DriverProfile | null> {
  const fields: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;
  const allowedFields = ['vehicle_type', 'vehicle_plate', 'vehicle_model', 'vehicle_color', 'license_number'];

  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      fields.push(`${key} = $${paramIndex++}`);
      params.push(data[key]);
    }
  }

  if (fields.length === 0) return getDriverProfileByUserId(userId);

  params.push(userId);
  const result = await query(
    `UPDATE driver_profile SET ${fields.join(', ')} WHERE user_id = $${paramIndex} RETURNING *`,
    params
  );
  return result.rows[0] || null;
}

export async function updateDriverLocation(
  driverProfileId: string,
  latitude: number,
  longitude: number,
  accuracy?: number,
  heading?: number,
  speed?: number
): Promise<void> {
  await query(
    `INSERT INTO driver_current_location (driver_profile_id, latitude, longitude, accuracy, heading, speed, updated_at)
     VALUES ($1, $2, $3, $4, $5, $6, NOW())
     ON CONFLICT (driver_profile_id)
     DO UPDATE SET latitude = $2, longitude = $3, accuracy = $4, heading = $5, speed = $6, updated_at = NOW()`,
    [driverProfileId, latitude, longitude, accuracy || null, heading || null, speed || null]
  );

  await query(
    `INSERT INTO driver_location_history (driver_profile_id, latitude, longitude, accuracy, heading, speed)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [driverProfileId, latitude, longitude, accuracy || null, heading || null, speed || null]
  );

  await query(
    `UPDATE driver_profile SET current_latitude = $1, current_longitude = $2, last_location_update = NOW() WHERE id = $3`,
    [latitude, longitude, driverProfileId]
  );
}

export async function updateDriverStatus(userId: string, status: string): Promise<DriverProfile | null> {
  const result = await query(
    `UPDATE driver_profile SET status = $1 WHERE user_id = $2 RETURNING *`,
    [status, userId]
  );
  return result.rows[0] || null;
}

export async function getDriverEarnings(
  driverProfileId: string,
  page: number = 1,
  limit: number = 20
): Promise<{ earnings: DriverEarnings[]; total: number; total_amount: number }> {
  const offset = (page - 1) * limit;

  const countResult = await query(
    `SELECT COUNT(*) FROM driver_earnings WHERE driver_profile_id = $1`,
    [driverProfileId]
  );
  const total = parseInt(countResult.rows[0].count, 10);

  const sumResult = await query(
    `SELECT COALESCE(SUM(amount), 0) as total_amount FROM driver_earnings WHERE driver_profile_id = $1 AND status = 'paid'`,
    [driverProfileId]
  );
  const totalAmount = parseFloat(sumResult.rows[0].total_amount);

  const result = await query(
    `SELECT de.*, o.order_number FROM driver_earnings de
     LEFT JOIN orders o ON de.order_id = o.id
     WHERE de.driver_profile_id = $1
     ORDER BY de.created_at DESC LIMIT $2 OFFSET $3`,
    [driverProfileId, limit, offset]
  );

  return { earnings: result.rows, total, total_amount: totalAmount };
}

export async function getDriverOrderHistory(
  driverProfileId: string,
  page: number = 1,
  limit: number = 20
): Promise<{ orders: any[]; total: number }> {
  const offset = (page - 1) * limit;

  const countResult = await query(
    `SELECT COUNT(*) FROM orders WHERE driver_id = $1`,
    [driverProfileId]
  );
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(
    `SELECT o.*, r.name as restaurant_name FROM orders o
     LEFT JOIN restaurant r ON o.restaurant_id = r.id
     WHERE o.driver_id = $1
     ORDER BY o.created_at DESC LIMIT $2 OFFSET $3`,
    [driverProfileId, limit, offset]
  );

  return { orders: result.rows, total };
}

export async function findAvailableOrders(
  driverProfileId: string,
  page: number = 1,
  limit: number = 20
): Promise<{ orders: any[]; total: number }> {
  const offset = (page - 1) * limit;

  const driver = await query('SELECT * FROM driver_profile WHERE id = $1', [driverProfileId]);

  let orderQuery = `
    SELECT o.*, r.name as restaurant_name, r.latitude as rest_lat, r.longitude as rest_lng,
           r.street, r.number, r.neighborhood, r.city
    FROM orders o
    JOIN restaurant r ON o.restaurant_id = r.id
    WHERE o.status = 'confirmed'
    AND o.driver_id IS NULL
  `;
  const params: any[] = [];

  if (driver.rows[0]?.current_latitude && driver.rows[0]?.current_longitude) {
    const haversine = `(6371 * ACOS(COS(RADIANS($1)) * COS(RADIANS(r.latitude)) * COS(RADIANS(r.longitude) - RADIANS($2)) + SIN(RADIANS($1)) * SIN(RADIANS(r.latitude))))`;
    orderQuery += ` AND ${haversine} <= r.delivery_radius_km`;
    params.push(driver.rows[0].current_latitude, driver.rows[0].current_longitude);
  }

  params.push(limit, offset);
  const paramIdx = params.length - 1;
  orderQuery += ` ORDER BY o.created_at ASC LIMIT $${params.length - 1} OFFSET $${params.length}`;

  const countResult = await query(
    `SELECT COUNT(*) FROM orders o
     JOIN restaurant r ON o.restaurant_id = r.id
     WHERE o.status = 'confirmed' AND o.driver_id IS NULL`,
    []
  );
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(orderQuery, params);
  return { orders: result.rows, total };
}

export async function acceptOrder(
  driverProfileId: string,
  orderId: string
): Promise<Order | null> {
  const order = await query(
    `UPDATE orders SET driver_id = $1, status = 'picked_up'
     WHERE id = $2 AND driver_id IS NULL AND status = 'confirmed'
     RETURNING *`,
    [driverProfileId, orderId]
  );

  if (order.rows[0]) {
    await query(
      `UPDATE driver_profile SET status = 'on_delivery', is_available = FALSE WHERE id = $1`,
      [driverProfileId]
    );

    await query(
      `INSERT INTO order_status_history (order_id, status, changed_by, note)
       VALUES ($1, 'picked_up', (SELECT user_id FROM driver_profile WHERE id = $2), 'Driver assigned')`,
      [orderId, driverProfileId]
    );
  }

  return order.rows[0] || null;
}

export async function markAsPickedUp(driverProfileId: string, orderId: string): Promise<Order | null> {
  const result = await query(
    `UPDATE orders SET status = 'in_transit'
     WHERE id = $1 AND driver_id = $2 AND status = 'picked_up'
     RETURNING *`,
    [orderId, driverProfileId]
  );

  if (result.rows[0]) {
    await query(
      `INSERT INTO order_status_history (order_id, status, changed_by) VALUES ($1, 'in_transit', (SELECT user_id FROM driver_profile WHERE id = $2))`,
      [orderId, driverProfileId]
    );
  }

  return result.rows[0] || null;
}

export async function markAsDelivered(driverProfileId: string, orderId: string): Promise<Order | null> {
  const result = await query(
    `UPDATE orders SET status = 'delivered', actual_delivery_time = NOW()
     WHERE id = $1 AND driver_id = $2 AND status = 'in_transit'
     RETURNING *`,
    [orderId, driverProfileId]
  );

  if (result.rows[0]) {
    const earnings = result.rows[0].driver_earnings || 5;
    await query(
      `INSERT INTO driver_earnings (driver_profile_id, order_id, amount, type, status)
       VALUES ($1, $2, $3, 'delivery', 'pending')`,
      [driverProfileId, orderId, earnings]
    );

    await query(
      `UPDATE driver_profile SET status = 'online', is_available = TRUE, total_deliveries = total_deliveries + 1 WHERE id = $1`,
      [driverProfileId]
    );

    await query(
      `INSERT INTO order_status_history (order_id, status, changed_by) VALUES ($1, 'delivered', (SELECT user_id FROM driver_profile WHERE id = $2))`,
      [orderId, driverProfileId]
    );
  }

  return result.rows[0] || null;
}

export async function findDriversForAdmin(
  page: number = 1,
  limit: number = 20,
  status?: string,
  verified?: boolean
): Promise<{ drivers: any[]; total: number }> {
  const offset = (page - 1) * limit;
  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (status) {
    conditions.push(`dp.status = $${paramIndex++}`);
    params.push(status);
  }

  if (verified !== undefined) {
    conditions.push(`dp.is_verified = $${paramIndex++}`);
    params.push(verified);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const countResult = await query(
    `SELECT COUNT(*) FROM driver_profile dp ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count, 10);

  params.push(limit, offset);
  const result = await query(
    `SELECT dp.*, ua.email, ua.first_name, ua.last_name, ua.phone, ua.avatar_url
     FROM driver_profile dp
     JOIN user_account ua ON dp.user_id = ua.id
     ${whereClause}
     ORDER BY dp.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    params
  );

  return { drivers: result.rows, total };
}

export async function verifyDriver(driverProfileId: string, adminId: string): Promise<DriverProfile | null> {
  const result = await query(
    `UPDATE driver_profile SET is_verified = TRUE WHERE id = $1 RETURNING *`,
    [driverProfileId]
  );
  return result.rows[0] || null;
}

export async function updateDriverStatusByAdmin(driverProfileId: string, status: string): Promise<DriverProfile | null> {
  const result = await query(
    `UPDATE driver_profile SET status = $1 WHERE id = $2 RETURNING *`,
    [status, driverProfileId]
  );
  return result.rows[0] || null;
}
