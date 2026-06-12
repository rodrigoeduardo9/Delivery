import { query } from '../../config/database';
import { Restaurant, RestaurantHours, Product, RestaurantCategory } from '../../shared/interfaces';

export async function createRestaurant(ownerId: string, data: any): Promise<Restaurant> {
  const result = await query(
    `INSERT INTO restaurant (owner_id, name, slug, description, phone, email, street, number,
            complement, neighborhood, city, state, zip_code, latitude, longitude,
            delivery_fee, minimum_order, delivery_radius_km, preparation_time_min)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
     RETURNING *`,
    [
      ownerId, data.name, data.slug, data.description || null, data.phone || null,
      data.email || null, data.street, data.number || null, data.complement || null,
      data.neighborhood || null, data.city, data.state, data.zip_code,
      data.latitude, data.longitude, data.delivery_fee || 0, data.minimum_order || 0,
      data.delivery_radius_km || 5, data.preparation_time_min || 30,
    ]
  );

  if (data.categories && Array.isArray(data.categories)) {
    for (const categoryId of data.categories) {
      await query(
        `INSERT INTO restaurant_categorization (restaurant_id, category_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
        [result.rows[0].id, categoryId]
      );
    }
  }

  return result.rows[0];
}

export async function findAllRestaurants(
  page: number = 1,
  limit: number = 20,
  filters?: { is_active?: boolean; category?: string; search?: string }
): Promise<{ restaurants: Restaurant[]; total: number }> {
  const offset = (page - 1) * limit;
  const conditions: string[] = ['r.is_deleted = FALSE'];
  const params: any[] = [];
  let paramIndex = 1;
  let joinClause = '';

  if (filters?.is_active !== undefined) {
    conditions.push(`r.is_active = $${paramIndex++}`);
    params.push(filters.is_active);
  }

  if (filters?.category) {
    joinClause = `JOIN restaurant_categorization rc ON r.id = rc.restaurant_id`;
    conditions.push(`rc.category_id = $${paramIndex++}`);
    params.push(filters.category);
  }

  if (filters?.search) {
    conditions.push(`(r.name ILIKE $${paramIndex} OR r.description ILIKE $${paramIndex})`);
    params.push(`%${filters.search}%`);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const countResult = await query(`SELECT COUNT(*) FROM restaurant r ${joinClause} ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(
    `SELECT r.* FROM restaurant r ${joinClause} ${whereClause} ORDER BY r.rating DESC, r.total_reviews DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  return { restaurants: result.rows, total };
}

export async function findNearbyRestaurants(
  latitude: number,
  longitude: number,
  radiusKm: number = 5,
  category?: string,
  search?: string,
  page: number = 1,
  limit: number = 20
): Promise<{ restaurants: any[]; total: number }> {
  const offset = (page - 1) * limit;
  const params: any[] = [latitude, longitude, radiusKm];
  let paramIndex = 4;
  let additionalConditions = '';
  let joinClause = '';

  if (category) {
    joinClause = `JOIN restaurant_categorization rc ON r.id = rc.restaurant_id`;
    additionalConditions += ` AND rc.category_id = $${paramIndex++}`;
    params.push(category);
  }

  if (search) {
    additionalConditions += ` AND (r.name ILIKE $${paramIndex} OR r.description ILIKE $${paramIndex})`;
    params.push(`%${search}%`);
    paramIndex++;
  }

  const haversine = `(6371 * ACOS(COS(RADIANS($1)) * COS(RADIANS(r.latitude)) * COS(RADIANS(r.longitude) - RADIANS($2)) + SIN(RADIANS($1)) * SIN(RADIANS(r.latitude))))`;

  const countResult = await query(
    `SELECT COUNT(*) FROM restaurant r ${joinClause}
     WHERE r.is_deleted = FALSE AND r.is_active = TRUE AND ${haversine} <= $3${additionalConditions}`,
    params
  );
  const total = parseInt(countResult.rows[0].count, 10);

  params.push(limit, offset);
  const result = await query(
    `SELECT r.*, ${haversine} AS distance FROM restaurant r ${joinClause}
     WHERE r.is_deleted = FALSE AND r.is_active = TRUE AND ${haversine} <= $3${additionalConditions}
     ORDER BY distance ASC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    params
  );

  return { restaurants: result.rows, total };
}

export async function findRestaurantById(id: string): Promise<Restaurant | null> {
  const result = await query(
    `SELECT * FROM restaurant WHERE id = $1 AND is_deleted = FALSE`,
    [id]
  );
  return result.rows[0] || null;
}

export async function updateRestaurant(id: string, data: any): Promise<Restaurant | null> {
  const fields: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;
  const allowedFields = [
    'name', 'slug', 'description', 'phone', 'email', 'website', 'logo_url', 'banner_url',
    'street', 'number', 'complement', 'neighborhood', 'city', 'state', 'zip_code',
    'latitude', 'longitude', 'delivery_fee', 'minimum_order', 'delivery_radius_km',
    'preparation_time_min', 'is_active',
  ];

  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      fields.push(`${key} = $${paramIndex++}`);
      params.push(data[key]);
    }
  }

  if (fields.length === 0) return findRestaurantById(id);

  params.push(id);
  const result = await query(
    `UPDATE restaurant SET ${fields.join(', ')} WHERE id = $${paramIndex} AND is_deleted = FALSE RETURNING *`,
    params
  );
  return result.rows[0] || null;
}

export async function findRestaurantHours(restaurantId: string): Promise<RestaurantHours[]> {
  const result = await query(
    `SELECT * FROM restaurant_hours WHERE restaurant_id = $1 ORDER BY
     CASE day_of_week
       WHEN 'monday' THEN 1 WHEN 'tuesday' THEN 2 WHEN 'wednesday' THEN 3
       WHEN 'thursday' THEN 4 WHEN 'friday' THEN 5 WHEN 'saturday' THEN 6 WHEN 'sunday' THEN 7
     END`,
    [restaurantId]
  );
  return result.rows;
}

export async function upsertRestaurantHours(restaurantId: string, hours: any[]): Promise<void> {
  await query(`DELETE FROM restaurant_hours WHERE restaurant_id = $1`, [restaurantId]);

  for (const h of hours) {
    await query(
      `INSERT INTO restaurant_hours (restaurant_id, day_of_week, open_time, close_time, is_closed)
       VALUES ($1, $2, $3, $4, $5)`,
      [restaurantId, h.day_of_week, h.open_time, h.close_time, h.is_closed || false]
    );
  }
}

export async function findProductsByRestaurant(
  restaurantId: string,
  category?: string
): Promise<Product[]> {
  const conditions: string[] = ['restaurant_id = $1', 'is_deleted = FALSE'];
  const params: any[] = [restaurantId];
  let paramIndex = 2;

  if (category) {
    conditions.push(`category = $${paramIndex++}`);
    params.push(category);
  }

  const result = await query(
    `SELECT * FROM product WHERE ${conditions.join(' AND ')} ORDER BY sort_order ASC, name ASC`,
    params
  );
  return result.rows;
}

export async function syncRestaurantStatus(restaurantId: string): Promise<boolean> {
  const dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  const today = dayNames[new Date().getDay()];

  const hoursResult = await query(
    `SELECT * FROM restaurant_hours WHERE restaurant_id = $1 AND day_of_week = $2 AND is_closed = FALSE`,
    [restaurantId, today]
  );

  if (hoursResult.rows.length === 0) {
    await query(`UPDATE restaurant SET is_open = FALSE WHERE id = $1`, [restaurantId]);
    return false;
  }

  const hour = hoursResult.rows[0];
  const now = new Date();
  const currentMinutes = now.getHours() * 60 + now.getMinutes();

  const openParts = hour.open_time.slice(0, 5).split(':');
  const closeParts = hour.close_time.slice(0, 5).split(':');
  const openMinutes = parseInt(openParts[0]) * 60 + parseInt(openParts[1]);
  const closeMinutes = parseInt(closeParts[0]) * 60 + parseInt(closeParts[1]);

  let isOpen: boolean;
  if (closeMinutes <= openMinutes) {
    isOpen = currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
  } else {
    isOpen = currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  await query(`UPDATE restaurant SET is_open = $1 WHERE id = $2`, [isOpen, restaurantId]);
  return isOpen;
}

export async function getCategories(): Promise<RestaurantCategory[]> {
  const result = await query(`SELECT * FROM restaurant_category ORDER BY name ASC`);
  return result.rows;
}

export async function createProduct(restaurantId: string, data: any): Promise<Product> {
  const result = await query(
    `INSERT INTO product (restaurant_id, name, description, price, discounted_price, image_url, category, is_available, stock, preparation_time_min, sort_order)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *`,
    [
      restaurantId, data.name, data.description || null, data.price,
      data.discounted_price || null, data.image_url || null, data.category || null,
      data.is_available !== false, data.stock ?? -1, data.preparation_time_min || null,
      data.sort_order || 0,
    ]
  );
  return result.rows[0];
}

export async function updateProduct(productId: string, restaurantId: string, data: any): Promise<Product | null> {
  const fields: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;
  const allowedFields = [
    'name', 'description', 'price', 'discounted_price', 'image_url',
    'category', 'is_available', 'is_featured', 'stock', 'preparation_time_min', 'sort_order',
  ];

  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      fields.push(`${key} = $${paramIndex++}`);
      params.push(data[key]);
    }
  }

  if (fields.length === 0) return null;

  params.push(productId, restaurantId);
  const result = await query(
    `UPDATE product SET ${fields.join(', ')} WHERE id = $${paramIndex} AND restaurant_id = $${paramIndex + 1} AND is_deleted = FALSE RETURNING *`,
    params
  );
  return result.rows[0] || null;
}

export async function deleteProduct(productId: string, restaurantId: string): Promise<boolean> {
  const result = await query(
    `UPDATE product SET is_deleted = TRUE WHERE id = $1 AND restaurant_id = $2 RETURNING id`,
    [productId, restaurantId]
  );
  return result.rows.length > 0;
}

export async function addZone(restaurantId: string, data: any): Promise<any> {
  const result = await query(
    `INSERT INTO restaurant_zone (restaurant_id, name, geometry, delivery_fee, minimum_order, estimated_time_min)
     VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
    [
      restaurantId, data.name, JSON.stringify(data.geometry),
      data.delivery_fee || null, data.minimum_order || null, data.estimated_time_min || null,
    ]
  );
  return result.rows[0];
}
