import { body } from 'express-validator';

export const processPaymentValidation = [
  body('order_id').isUUID().withMessage('Valid order ID required'),
  body('payment_method').isIn(['credit_card', 'debit_card', 'pix', 'cash', 'mercado_pago', 'stripe'])
    .withMessage('Valid payment method required'),
  body('card_token').optional().trim(),
];

export const addPaymentMethodValidation = [
  body('type').isIn(['credit_card', 'debit_card', 'pix']).withMessage('Valid payment type required'),
  body('token').notEmpty().withMessage('Payment token is required'),
  body('is_default').optional().isBoolean(),
];
