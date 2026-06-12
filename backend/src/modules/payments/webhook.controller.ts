import { Request, Response } from 'express';
import { config } from '../../config';
import { query } from '../../config/database';
import { logger } from '../../config/logger';
import { PaymentStatus } from '../../shared/enums';
import { refundByOrderId } from './payments.service';

export async function handleStripeWebhook(req: Request, res: Response): Promise<void> {
  const sig = req.headers['stripe-signature'] as string;
  if (!sig) {
    res.status(400).json({ error: 'Missing stripe-signature header' });
    return;
  }

  try {
    const stripe = require('stripe')(config.stripe.secretKey);
    const event = stripe.webhooks.constructEvent(req.body, sig, config.stripe.webhookSecret);

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object;
        await query(
          `UPDATE payment SET gateway_status = 'succeeded', status = $1, paid_at = NOW()
           WHERE gateway_payment_id = $2`,
          [PaymentStatus.COMPLETED, paymentIntent.id]
        );
        break;
      }
      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object;
        await query(
          `UPDATE payment SET gateway_status = 'failed', status = $1
           WHERE gateway_payment_id = $2`,
          [PaymentStatus.FAILED, paymentIntent.id]
        );
        await query(
          `UPDATE orders SET payment_status = 'failed' WHERE id = (
             SELECT order_id FROM payment WHERE gateway_payment_id = $1
           )`,
          [paymentIntent.id]
        );
        break;
      }
      case 'charge.refunded': {
        const charge = event.data.object;
        const paymentIntentId = charge.payment_intent;
        await query(
          `UPDATE payment SET status = $1, refunded_at = NOW()
           WHERE gateway_payment_id = $2`,
          [PaymentStatus.REFUNDED, paymentIntentId]
        );
        await query(
          `UPDATE orders SET payment_status = 'refunded' WHERE id = (
             SELECT order_id FROM payment WHERE gateway_payment_id = $1
           )`,
          [paymentIntentId]
        );
        break;
      }
    }

    res.json({ received: true });
  } catch (err: any) {
    logger.error('Stripe webhook error:', err.message);
    res.status(400).json({ error: `Webhook Error: ${err.message}` });
  }
}

export async function handleMercadoPagoWebhook(req: Request, res: Response): Promise<void> {
  try {
    const { action, data } = req.body;

    if (!action || !data?.id) {
      res.status(400).json({ error: 'Invalid webhook payload' });
      return;
    }

    const mercadopago = require('mercadopago');
    mercadopago.configurations.setAccessToken(config.mercadopago.accessToken);

    const paymentData = await mercadopago.payment.get(data.id);

    const gatewayPaymentId = `mp_${data.id}`;
    const status = paymentData.body.status;

    let paymentStatus: string;
    switch (status) {
      case 'approved':
        paymentStatus = PaymentStatus.COMPLETED;
        break;
      case 'rejected':
      case 'cancelled':
        paymentStatus = PaymentStatus.FAILED;
        break;
      case 'refunded':
        paymentStatus = PaymentStatus.REFUNDED;
        break;
      default:
        paymentStatus = PaymentStatus.PENDING;
    }

    const payment = await query('SELECT * FROM payment WHERE gateway_payment_id = $1', [gatewayPaymentId]);
    if (payment.rows.length === 0) {
      res.status(404).json({ error: 'Payment not found' });
      return;
    }

    await query(
      `UPDATE payment SET gateway_status = $1, status = $2${status === 'approved' ? ', paid_at = NOW()' : ''}${status === 'refunded' ? ', refunded_at = NOW()' : ''}
       WHERE gateway_payment_id = $3`,
      [status, paymentStatus, gatewayPaymentId]
    );

    await query(
      `UPDATE orders SET payment_status = $1 WHERE id = $2`,
      [status === 'approved' ? 'completed' : status === 'refunded' ? 'refunded' : 'failed', payment.rows[0].order_id]
    );

    res.sendStatus(200);
  } catch (err: any) {
    logger.error('MercadoPago webhook error:', err.message);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
}
