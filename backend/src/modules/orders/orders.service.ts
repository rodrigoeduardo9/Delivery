import { query, getClient } from '../../config/database';
import { Order, OrderItem, OrderItemExtra } from '../../shared/interfaces';
import { OrderStatus } from '../../shared/enums';

const VALID_TRANSITIONS: Record<string, string[]> = {
  [OrderStatus.PENDING]: [OrderStatus.CONFIRMED, OrderStatus.CANCELLED],
  [OrderStatus.CONFIRMED]: [OrderStatus.PREPARING, OrderStatus.CANCELLED],
  [OrderStatus.PREPARING]: [OrderStatus.READY, OrderStatus.CANCELLED],
  [OrderStatus.READY]: [OrderStatus.PICKED_UP, OrderStatus.CANCELLED],
  [OrderStatus.PICKED_UP]: [OrderStatus.IN_TRANSIT],
  [OrderStatus.IN_TRANSIT]: [OrderStatus.DELIVERED],
  [OrderStatus.DELIVERED]: [],
  [OrderStatus.CANCELLED]: [OrderStatus.REFUNDED],
  [OrderStatus.REFUNDED]: [],
};

export function isValidTransition(current: string, next: string): boolean {
  const allowed = VALID_TRANSITIONS[current];
  return allowed ? allowed.includes(next) : false;
}

export async function generateOrderNumber(): Promise<string> {
  const datePart = new Date().toISOString().slice(2, 10).replace(/-/g, '');
  const randomPart = Math.random().toString(36).substring(2, 7).toUpperCase();
  const result = await query(
    `INSERT INTO orders (order_number, customer_id, restaurant_id, subtotal, delivery_fee, total)
     VALUES ($1, '00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 0, 0, 0)
     ON CONFLICT DO NOTHING RETURNING order_number`,
    [`DEL-${datePart}-${randomPart}`]
  );

  if (result.rows.length > 0) {
    await query(`DELETE FROM orders WHERE order_number = $1`, [result.rows[0].order_number]);
    return result.rows[0].order_number;
  }

  return generateOrderNumber();
}

export async function calculateOrderTotal(
  restaurantId: string,
  items: any[],
  couponCode?: string
): Promise<{
  subtotal: number;
  delivery_fee: number;
  discount: number;
  total: number;
  platform_fee: number;
  coupon_id?: string;
}> {
  const restaurantResult = await query(
    `SELECT delivery_fee, minimum_order FROM restaurant WHERE id = $1`,
    [restaurantId]
  );
  const restaurant = restaurantResult.rows[0];
  if (!restaurant) throw new Error('Restaurant not found');

  let subtotal = 0;

  for (const item of items) {
    const productResult = await query(
      `SELECT price, discounted_price FROM product WHERE id = $1 AND restaurant_id = $2 AND is_deleted = FALSE`,
      [item.product_id, restaurantId]
    );
    const product = productResult.rows[0];
    if (!product) throw new Error(`Product ${item.product_id} not found`);

    const unitPrice = product.discounted_price || product.price;
    let itemTotal = unitPrice * item.quantity;

    if (item.variant_id) {
      const variantResult = await query(
        `SELECT price_adjustment FROM product_variant WHERE id = $1`,
        [item.variant_id]
      );
      if (variantResult.rows[0]) {
        itemTotal += variantResult.rows[0].price_adjustment * item.quantity;
      }
    }

    if (item.extras && item.extras.length > 0) {
      for (const extra of item.extras) {
        const extraResult = await query(
          `SELECT price FROM product_extra WHERE id = $1`,
          [extra.extra_id]
        );
        if (extraResult.rows[0]) {
          itemTotal += extraResult.rows[0].price * extra.quantity;
        }
      }
    }

    subtotal += itemTotal;
  }

  if (restaurant.minimum_order > 0 && subtotal < restaurant.minimum_order) {
    throw new Error(`Minimum order amount is ${restaurant.minimum_order}`);
  }

  const delivery_fee = restaurant.delivery_fee;
  let discount = 0;
  let coupon_id: string | undefined;

  if (couponCode) {
    const couponResult = await query(
      `SELECT * FROM coupon WHERE code = $1 AND is_active = TRUE AND valid_from <= NOW() AND valid_until > NOW() AND (max_uses IS NULL OR current_uses < max_uses)`,
      [couponCode]
    );
    const coupon = couponResult.rows[0];

    if (coupon && subtotal >= coupon.minimum_order) {
      coupon_id = coupon.id;
      if (coupon.discount_type === 'percentage') {
        discount = subtotal * (coupon.discount_value / 100);
        if (coupon.max_discount) discount = Math.min(discount, coupon.max_discount);
      } else {
        discount = coupon.discount_value;
      }
    }
  }

  const platform_fee = Math.round((subtotal * 0.05) * 100) / 100;
  const total = subtotal + delivery_fee - discount + platform_fee;

  return { subtotal, delivery_fee, discount, total, platform_fee, coupon_id };
}

export async function createOrder(
  customerId: string,
  data: any,
  totals: any
): Promise<Order> {
  const orderNumber = await generateOrderNumber();

  const client = await getClient();
  try {
    await client.query('BEGIN');

    const orderResult = await client.query(
      `INSERT INTO orders (order_number, customer_id, restaurant_id, subtotal, delivery_fee,
        discount, tip, total, payment_method, payment_status, delivery_address_id,
        delivery_latitude, delivery_longitude, delivery_instructions, coupon_id,
        platform_fee, is_scheduled, scheduled_time)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'pending', $10, $11, $12, $13, $14, $15, $16, $17)
       RETURNING *`,
      [
        orderNumber, customerId, data.restaurant_id, totals.subtotal,
        totals.delivery_fee, totals.discount, data.tip || 0, totals.total,
        data.payment_method, data.delivery_address_id || null,
        data.delivery_latitude || null, data.delivery_longitude || null,
        data.delivery_instructions || null, totals.coupon_id || null,
        totals.platform_fee, data.is_scheduled || false, data.scheduled_time || null,
      ]
    );
    const order = orderResult.rows[0];

    for (const item of data.items) {
      const productResult = await client.query(
        `SELECT price, discounted_price, name FROM product WHERE id = $1`,
        [item.product_id]
      );
      const product = productResult.rows[0];
      const unitPrice = product.discounted_price || product.price;
      let itemTotal = unitPrice * item.quantity;

      await client.query(
        `INSERT INTO order_item (order_id, product_id, variant_id, product_name, quantity, unit_price, total_price, special_instructions)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [order.id, item.product_id, item.variant_id || null, product.name, item.quantity, unitPrice, itemTotal, item.special_instructions || null]
      );

      if (item.extras && item.extras.length > 0) {
        for (const extra of item.extras) {
          const extraResult = await client.query(
            `SELECT price, name FROM product_extra WHERE id = $1`,
            [extra.extra_id]
          );
          if (extraResult.rows[0]) {
            const extraPrice = extraResult.rows[0].price * extra.quantity;
            itemTotal += extraPrice;
            await client.query(
              `INSERT INTO order_item_extra (order_item_id, extra_name, extra_price, quantity)
               VALUES ((SELECT id FROM order_item WHERE order_id = $1 AND product_id = $2 LIMIT 1), $3, $4, $5)`,
              [order.id, item.product_id, extraResult.rows[0].name, extraResult.rows[0].price, extra.quantity]
            );
          }
        }
      }
    }

    await client.query(
      `UPDATE orders SET total = $1 WHERE id = $2`,
      [totals.total, order.id]
    );

    await client.query(
      `INSERT INTO order_status_history (order_id, status, changed_by) VALUES ($1, 'pending', $2)`,
      [order.id, customerId]
    );

    if (totals.coupon_id) {
      await client.query(
        `UPDATE coupon SET current_uses = current_uses + 1 WHERE id = $1`,
        [totals.coupon_id]
      );
    }

    await client.query('COMMIT');

    const finalOrder = await client.query('SELECT * FROM orders WHERE id = $1', [order.id]);
    return finalOrder.rows[0];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function findOrders(
  customerId?: string,
  restaurantId?: string,
  driverId?: string,
  status?: string,
  page: number = 1,
  limit: number = 20
): Promise<{ orders: any[]; total: number }> {
  const offset = (page - 1) * limit;
  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (customerId) {
    conditions.push(`o.customer_id = $${paramIndex++}`);
    params.push(customerId);
  }
  if (restaurantId) {
    conditions.push(`o.restaurant_id = $${paramIndex++}`);
    params.push(restaurantId);
  }
  if (driverId) {
    conditions.push(`o.driver_id = $${paramIndex++}`);
    params.push(driverId);
  }
  if (status) {
    if (status === 'active') {
      conditions.push(`o.status NOT IN ('delivered', 'cancelled', 'refunded')`);
    } else {
      conditions.push(`o.status = $${paramIndex++}`);
      params.push(status);
    }
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const countResult = await query(
    `SELECT COUNT(*) FROM orders o ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count, 10);

  params.push(limit, offset);
  const result = await query(
    `SELECT o.*, r.name as restaurant_name, r.logo_url as restaurant_logo
     FROM orders o
     LEFT JOIN restaurant r ON o.restaurant_id = r.id
     ${whereClause}
     ORDER BY o.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    params
  );

  return { orders: result.rows, total };
}

export async function findOrderById(id: string): Promise<any> {
  const result = await query(
    `SELECT o.*, r.name as restaurant_name, r.logo_url as restaurant_logo,
            r.street, r.number, r.neighborhood, r.city, r.state,
            a.street as delivery_street, a.number as delivery_number,
            a.neighborhood as delivery_neighborhood, a.city as delivery_city,
            a.complement as delivery_complement, a.zip_code as delivery_zip
     FROM orders o
     LEFT JOIN restaurant r ON o.restaurant_id = r.id
     LEFT JOIN address a ON o.delivery_address_id = a.id
     WHERE o.id = $1`,
    [id]
  );
  if (!result.rows[0]) return null;

  const order = result.rows[0];

  const itemsResult = await query(
    `SELECT oi.*, json_agg(json_build_object(
       'id', oie.id, 'extra_name', oie.extra_name, 'extra_price', oie.extra_price, 'quantity', oie.quantity
     )) FILTER (WHERE oie.id IS NOT NULL) as extras
     FROM order_item oi
     LEFT JOIN order_item_extra oie ON oi.id = oie.order_item_id
     WHERE oi.order_id = $1
     GROUP BY oi.id
     ORDER BY oi.id`,
    [id]
  );

  const historyResult = await query(
    `SELECT * FROM order_status_history WHERE order_id = $1 ORDER BY created_at ASC`,
    [id]
  );

  return { ...order, items: itemsResult.rows, status_history: historyResult.rows };
}

export async function updateOrderStatus(
  orderId: string,
  status: string,
  changedBy: string,
  note?: string
): Promise<Order | null> {
  const order = await query('SELECT * FROM orders WHERE id = $1', [orderId]);
  if (!order.rows[0]) return null;

  if (!isValidTransition(order.rows[0].status, status)) {
    throw new Error(`Cannot transition from ${order.rows[0].status} to ${status}`);
  }

  const client = await getClient();
  try {
    await client.query('BEGIN');

    const updateFields: string[] = ['status = $1'];
    const updateParams: any[] = [status];

    if (status === 'delivered') {
      updateFields.push('actual_delivery_time = NOW()');
    }

    updateParams.push(orderId);
    await client.query(
      `UPDATE orders SET ${updateFields.join(', ')} WHERE id = $${updateParams.length}`,
      updateParams
    );

    await client.query(
      `INSERT INTO order_status_history (order_id, status, changed_by, note) VALUES ($1, $2, $3, $4)`,
      [orderId, status, changedBy, note || null]
    );

    if (status === 'cancelled') {
      await client.query(
        `UPDATE orders SET cancelled_by = $1 WHERE id = $2`,
        [changedBy, orderId]
      );
    }

    if (status === 'delivered') {
      await client.query(
        `UPDATE driver_profile SET total_deliveries = total_deliveries + 1
         WHERE id = (SELECT driver_id FROM orders WHERE id = $1)`,
        [orderId]
      );
    }

    await client.query('COMMIT');

    const result = await client.query('SELECT * FROM orders WHERE id = $1', [orderId]);
    return result.rows[0];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function cancelOrder(orderId: string, userId: string, reason?: string): Promise<Order | null> {
  const order = await query('SELECT * FROM orders WHERE id = $1', [orderId]);
  if (!order.rows[0]) return null;

  const cancellableStatuses = [OrderStatus.PENDING, OrderStatus.CONFIRMED, OrderStatus.PREPARING];
  if (!cancellableStatuses.includes(order.rows[0].status)) {
    throw new Error('Order cannot be cancelled at current status');
  }

  return updateOrderStatus(orderId, OrderStatus.CANCELLED, userId, reason);
}

export async function rateOrder(
  orderId: string,
  customerId: string,
  rating: number,
  review?: string,
  driverRating?: number
): Promise<any> {
  const order = await query(
    `SELECT * FROM orders WHERE id = $1 AND customer_id = $2`,
    [orderId, customerId]
  );
  if (!order.rows[0]) throw new Error('Order not found');

  const result = await query(
    `INSERT INTO review (order_id, restaurant_id, customer_id, driver_profile_id, restaurant_rating, driver_rating, comment)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     ON CONFLICT (order_id)
     DO UPDATE SET restaurant_rating = $5, driver_rating = COALESCE($6, review.driver_rating), comment = COALESCE($7, review.comment)
     RETURNING *`,
    [
      orderId, order.rows[0].restaurant_id, customerId,
      order.rows[0].driver_id || null, rating, driverRating || null, review || null,
    ]
  );

  await query(
    `UPDATE orders SET customer_rating = $1, customer_review = $2 WHERE id = $3`,
    [rating, review || null, orderId]
  );

  return result.rows[0];
}
