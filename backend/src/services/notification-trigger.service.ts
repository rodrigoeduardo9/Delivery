import { query } from '../config/database';
import { getIO } from './websocket.service';
import { queuePush } from './queue.service';
import { logger } from '../config/logger';

type OrderEvent = 'created' | 'confirmed' | 'preparing' | 'ready' | 'picked_up' | 'delivered' | 'cancelled';

export async function triggerOrderNotification(orderId: string, event: OrderEvent, extra?: Record<string, string>): Promise<void> {
  try {
    const order = await query(
      `SELECT o.*, r.name as restaurant_name, r.user_id as restaurant_owner_id
       FROM orders o JOIN restaurant r ON o.restaurant_id = r.id
       WHERE o.id = $1`,
      [orderId]
    );
    if (!order.rows[0]) return;
    const o = order.rows[0];

    const io = getIO();
    const room = `order:${orderId}`;

    const labels: Record<OrderEvent, { title: string; body: string }> = {
      created: { title: 'New Order', body: `Order #${o.order_number} from ${o.restaurant_name} — $${o.total}` },
      confirmed: { title: 'Order Confirmed', body: `Your order #${o.order_number} has been confirmed` },
      preparing: { title: 'Preparing Order', body: `${o.restaurant_name} is preparing your order #${o.order_number}` },
      ready: { title: 'Order Ready', body: `Your order #${o.order_number} from ${o.restaurant_name} is ready for pickup` },
      picked_up: { title: 'Order Picked Up', body: `Your order #${o.order_number} is on its way!` },
      delivered: { title: 'Order Delivered', body: `Your order #${o.order_number} has been delivered. Enjoy!` },
      cancelled: { title: 'Order Cancelled', body: `Order #${o.order_number} from ${o.restaurant_name} has been cancelled` },
    };

    const notification = labels[event];
    io?.to(room).emit('order_status', { orderId, status: event, ...notification });

    io?.to(`user:${o.customer_id}`).emit('notification', {
      type: 'order',
      orderId,
      title: notification.title,
      body: notification.body,
    });

    if (o.restaurant_owner_id) {
      io?.to(`user:${o.restaurant_owner_id}`).emit('notification', {
        type: 'order',
        orderId,
        title: notification.title,
        body: notification.body,
      });
    }

    if (o.driver_id) {
      io?.to(`user:${o.driver_id}`).emit('notification', {
        type: 'order',
        orderId,
        title: notification.title,
        body: notification.body,
      });
    }

    await queuePush({
      title: notification.title,
      body: notification.body,
      userId: o.customer_id,
      data: { orderId, type: 'order_status' },
    });

    logger.info(`Notification triggered for order ${orderId}: ${event}`);
  } catch (err) {
    logger.error('Notification trigger error:', err);
  }
}
