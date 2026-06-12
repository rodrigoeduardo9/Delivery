import { Router } from 'express';
import { handleStripeWebhook, handleMercadoPagoWebhook } from './webhook.controller';

const router = Router();

router.post('/stripe', handleStripeWebhook);
router.post('/mercadopago', handleMercadoPagoWebhook);

export default router;
