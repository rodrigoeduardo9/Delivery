import { body } from 'express-validator';

export const createOrderValidation = [
  body('restaurant_id').isUUID().withMessage('Valid restaurant ID required'),
  body('items').isArray({ min: 1 }).withMessage('At least one item required'),
  body('items.*.product_id').isUUID().withMessage('Valid product ID required'),
  body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('items.*.variant_id').optional().isUUID(),
  body('items.*.extras').optional().isArray(),
  body('items.*.extras.*.extra_id').isUUID(),
  body('items.*.extras.*.quantity').isInt({ min: 1 }),
  body('delivery_address_id').optional().isUUID(),
  body('delivery_latitude').optional().isFloat({ min: -90, max: 90 }),
  body('delivery_longitude').optional().isFloat({ min: -180, max: 180 }),
  body('delivery_instructions').optional().trim().isLength({ max: 500 }),
  body('payment_method').isIn(['credit_card', 'debit_card', 'pix', 'cash', 'mercado_pago', 'stripe'])
    .withMessage('Valid payment method required'),
  body('coupon_code').optional().trim(),
  body('tip').optional().isFloat({ min: 0 }),
  body('is_scheduled').optional().isBoolean(),
  body('scheduled_time').optional({ nullable: true }).isISO8601(),
];

export const updateStatusValidation = [
  body('status').isIn(['confirmed', 'preparing', 'ready', 'picked_up', 'in_transit', 'delivered', 'cancelled'])
    .withMessage('Invalid status'),
  body('note').optional().trim(),
];

export const rateOrderValidation = [
  body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('review').optional().trim().isLength({ max: 1000 }),
  body('driver_rating').optional().isInt({ min: 1, max: 5 }),
];
