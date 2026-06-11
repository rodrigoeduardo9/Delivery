import { query } from '../../config/database';

export async function getAdminOverview(): Promise<any> {
  const results = await Promise.all([
    query(`SELECT COUNT(*) FROM user_account WHERE is_deleted = FALSE AND role = 'customer'`),
    query(`SELECT COUNT(*) FROM user_account WHERE is_deleted = FALSE AND role = 'driver'`),
    query(`SELECT COUNT(*) FROM restaurant WHERE is_deleted = FALSE`),
    query(`SELECT COUNT(*) FROM orders WHERE created_at >= NOW() - INTERVAL '24 hours'`),
    query(`SELECT COUNT(*) FROM orders WHERE created_at >= NOW() - INTERVAL '7 days'`),
    query(`SELECT COALESCE(SUM(total), 0) FROM orders WHERE created_at >= NOW() - INTERVAL '7 days' AND status = 'delivered'`),
    query(`SELECT COALESCE(SUM(total), 0) FROM orders WHERE created_at >= NOW() - INTERVAL '30 days' AND status = 'delivered'`),
    query(`SELECT COUNT(*) FROM orders WHERE status = 'pending'`),
    query(`SELECT COUNT(*) FROM driver_profile WHERE status = 'online' AND is_available = TRUE`),
  ]);

  return {
    total_customers: parseInt(results[0].rows[0].count),
    total_drivers: parseInt(results[1].rows[0].count),
    total_restaurants: parseInt(results[2].rows[0].count),
    orders_last_24h: parseInt(results[3].rows[0].count),
    orders_last_7d: parseInt(results[4].rows[0].count),
    revenue_last_7d: parseFloat(results[5].rows[0].coalesce),
    revenue_last_30d: parseFloat(results[6].rows[0].coalesce),
    pending_orders: parseInt(results[7].rows[0].count),
    available_drivers: parseInt(results[8].rows[0].count),
  };
}

export async function getOrderReport(
  startDate?: string,
  endDate?: string,
  page: number = 1,
  limit: number = 20
): Promise<{ orders: any[]; total: number }> {
  const offset = (page - 1) * limit;
  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (startDate) {
    conditions.push(`o.created_at >= $${paramIndex++}`);
    params.push(startDate);
  }
  if (endDate) {
    conditions.push(`o.created_at <= $${paramIndex++}`);
    params.push(endDate);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const countResult = await query(`SELECT COUNT(*) FROM orders o ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].count, 10);

  params.push(limit, offset);
  const result = await query(
    `SELECT o.*, r.name as restaurant_name, u.first_name || ' ' || u.last_name as customer_name
     FROM orders o
     LEFT JOIN restaurant r ON o.restaurant_id = r.id
     LEFT JOIN user_account u ON o.customer_id = u.id
     ${whereClause}
     ORDER BY o.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    params
  );

  return { orders: result.rows, total };
}

export async function getRevenueReport(
  startDate?: string,
  endDate?: string
): Promise<any> {
  const conditions: string[] = ["o.status = 'delivered'"];
  const params: any[] = [];
  let paramIndex = 1;

  if (startDate) {
    conditions.push(`o.created_at >= $${paramIndex++}`);
    params.push(startDate);
  }
  if (endDate) {
    conditions.push(`o.created_at <= $${paramIndex++}`);
    params.push(endDate);
  }

  const whereClause = `WHERE ${conditions.join(' AND ')}`;

  const result = await query(
    `SELECT
       DATE(o.created_at) as date,
       COUNT(*) as order_count,
       COALESCE(SUM(o.total), 0) as revenue,
       COALESCE(SUM(o.platform_fee), 0) as platform_fees,
       COALESCE(AVG(o.total), 0) as avg_order_value
     FROM orders o ${whereClause}
     GROUP BY DATE(o.created_at)
     ORDER BY date DESC LIMIT 30`,
    params
  );

  const totals = await query(
    `SELECT
       COUNT(*) as total_orders,
       COALESCE(SUM(o.total), 0) as total_revenue,
       COALESCE(SUM(o.platform_fee), 0) as total_platform_fees,
       COALESCE(AVG(o.total), 0) as avg_order_value
     FROM orders o ${whereClause}`,
    params
  );

  return { daily: result.rows, summary: totals.rows[0] };
}

export async function getDriverPerformanceReport(
  page: number = 1,
  limit: number = 20
): Promise<{ drivers: any[]; total: number }> {
  const offset = (page - 1) * limit;

  const countResult = await query(`SELECT COUNT(*) FROM driver_profile`);
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(
    `SELECT dp.*, ua.first_name, ua.last_name, ua.email, ua.phone,
       COALESCE(SUM(de.amount), 0) as total_earned
     FROM driver_profile dp
     JOIN user_account ua ON dp.user_id = ua.id
     LEFT JOIN driver_earnings de ON dp.id = de.driver_profile_id AND de.status = 'paid'
     GROUP BY dp.id, ua.first_name, ua.last_name, ua.email, ua.phone
     ORDER BY dp.total_deliveries DESC LIMIT $1 OFFSET $2`,
    [limit, offset]
  );

  return { drivers: result.rows, total };
}

export async function getRestaurantPerformanceReport(
  page: number = 1,
  limit: number = 20
): Promise<{ restaurants: any[]; total: number }> {
  const offset = (page - 1) * limit;

  const countResult = await query(`SELECT COUNT(*) FROM restaurant WHERE is_deleted = FALSE`);
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(
    `SELECT r.*, ua.first_name || ' ' || ua.last_name as owner_name,
       COUNT(o.id) as total_orders,
       COALESCE(SUM(o.total), 0) as total_revenue
     FROM restaurant r
     JOIN user_account ua ON r.owner_id = ua.id
     LEFT JOIN orders o ON r.id = o.restaurant_id AND o.status = 'delivered'
     WHERE r.is_deleted = FALSE
     GROUP BY r.id, ua.first_name, ua.last_name
     ORDER BY total_orders DESC LIMIT $1 OFFSET $2`,
    [limit, offset]
  );

  return { restaurants: result.rows, total };
}

export async function getRestaurantOverview(restaurantId: string): Promise<any> {
  const results = await Promise.all([
    query(`SELECT * FROM restaurant WHERE id = $1`, [restaurantId]),
    query(`SELECT COUNT(*) FROM orders WHERE restaurant_id = $1 AND status = 'delivered'`, [restaurantId]),
    query(`SELECT COALESCE(SUM(total), 0) FROM orders WHERE restaurant_id = $1 AND status = 'delivered'`, [restaurantId]),
    query(`SELECT COUNT(*) FROM orders WHERE restaurant_id = $1 AND created_at >= NOW() - INTERVAL '24 hours'`, [restaurantId]),
    query(`SELECT COUNT(*) FROM orders WHERE restaurant_id = $1 AND status IN ('pending', 'confirmed', 'preparing', 'ready')`, [restaurantId]),
    query(`SELECT COALESCE(AVG(restaurant_rating), 0) FROM review WHERE restaurant_id = $1`, [restaurantId]),
  ]);

  return {
    restaurant: results[0].rows[0] || null,
    total_delivered_orders: parseInt(results[1].rows[0].count),
    total_revenue: parseFloat(results[2].rows[0].coalesce),
    orders_last_24h: parseInt(results[3].rows[0].count),
    active_orders: parseInt(results[4].rows[0].count),
    avg_rating: parseFloat(results[5].rows[0].coalesce),
  };
}

export async function getRestaurantSalesReport(
  restaurantId: string,
  startDate?: string,
  endDate?: string
): Promise<any> {
  const conditions: string[] = ['o.restaurant_id = $1', "o.status = 'delivered'"];
  const params: any[] = [restaurantId];
  let paramIndex = 2;

  if (startDate) {
    conditions.push(`o.created_at >= $${paramIndex++}`);
    params.push(startDate);
  }
  if (endDate) {
    conditions.push(`o.created_at <= $${paramIndex++}`);
    params.push(endDate);
  }

  const whereClause = `WHERE ${conditions.join(' AND ')}`;

  const result = await query(
    `SELECT
       DATE(o.created_at) as date,
       COUNT(*) as order_count,
       COALESCE(SUM(o.total), 0) as revenue,
       COALESCE(AVG(o.total), 0) as avg_order_value
     FROM orders o ${whereClause}
     GROUP BY DATE(o.created_at)
     ORDER BY date DESC LIMIT 30`,
    params
  );

  const totals = await query(
    `SELECT
       COUNT(*) as total_orders,
       COALESCE(SUM(o.total), 0) as total_revenue
     FROM orders o ${whereClause}`,
    params
  );

  const popularItems = await query(
    `SELECT oi.product_name, SUM(oi.quantity) as total_sold,
            SUM(oi.total_price) as total_revenue
     FROM order_item oi
     JOIN orders o ON oi.order_id = o.id
     WHERE o.restaurant_id = $1 AND o.status = 'delivered'
     GROUP BY oi.product_name
     ORDER BY total_sold DESC LIMIT 10`,
    [restaurantId]
  );

  return { daily: result.rows, summary: totals.rows[0], popular_items: popularItems.rows };
}
