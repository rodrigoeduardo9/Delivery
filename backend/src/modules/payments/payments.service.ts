import { query } from '../../config/database';
import { Payment, Order } from '../../shared/interfaces';
import { PaymentStatus } from '../../shared/enums';

export async function processPayment(order: Order, paymentMethod: string): Promise<Payment> {
  const gateway = paymentMethod === 'mercado_pago' ? 'mercadopago' : 'stripe';

  // In production, integrate with Stripe/MercadoPago SDK
  const gatewayPaymentId = `mock_${gateway}_${Date.now()}`;

  const result = await query(
    `INSERT INTO payment (order_id, gateway, gateway_payment_id, gateway_status, amount, payment_method, status, fee, net_amount)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
    [
      order.id, gateway, gatewayPaymentId, 'succeeded',
      order.total, paymentMethod, PaymentStatus.COMPLETED,
      Math.round(order.total * 0.03 * 100) / 100,
      Math.round(order.total * 0.97 * 100) / 100,
    ]
  );

  await query(
    `UPDATE orders SET payment_status = 'completed' WHERE id = $1`,
    [order.id]
  );

  return result.rows[0];
}

export async function refundPayment(paymentId: string): Promise<Payment | null> {
  const payment = await query('SELECT * FROM payment WHERE id = $1', [paymentId]);
  if (!payment.rows[0]) return null;

  const result = await query(
    `UPDATE payment SET status = 'refunded', refunded_at = NOW() WHERE id = $1 RETURNING *`,
    [paymentId]
  );

  await query(
    `UPDATE orders SET payment_status = 'refunded' WHERE id = $1`,
    [payment.rows[0].order_id]
  );

  return result.rows[0];
}

export async function getPaymentHistory(
  userId: string,
  page: number = 1,
  limit: number = 20
): Promise<{ payments: any[]; total: number }> {
  const offset = (page - 1) * limit;

  const countResult = await query(
    `SELECT COUNT(*) FROM payment p
     JOIN orders o ON p.order_id = o.id
     WHERE o.customer_id = $1`,
    [userId]
  );
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(
    `SELECT p.*, o.order_number, o.total as order_total
     FROM payment p
     JOIN orders o ON p.order_id = o.id
     WHERE o.customer_id = $1
     ORDER BY p.created_at DESC LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );

  return { payments: result.rows, total };
}

export async function refundByOrderId(orderId: string): Promise<Payment | null> {
  const payment = await query(
    'SELECT * FROM payment WHERE order_id = $1 AND status = $2',
    [orderId, PaymentStatus.COMPLETED]
  );

  if (payment.rows.length === 0) return null;
  return refundPayment(payment.rows[0].id);
}
