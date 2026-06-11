import { body } from 'express-validator';

export const updateProductValidation = [
  body('name').optional().trim().notEmpty().withMessage('Product name cannot be empty'),
  body('price').optional().isFloat({ min: 0 }).withMessage('Valid price required'),
  body('discounted_price').optional({ nullable: true }).isFloat({ min: 0 }).withMessage('Valid discounted price required'),
  body('is_available').optional().isBoolean(),
  body('stock').optional().isInt(),
];

export const variantValidation = [
  body().isArray().withMessage('Variants must be an array'),
  body('*.name').trim().notEmpty().withMessage('Variant name is required'),
  body('*.price_adjustment').optional().isFloat(),
  body('*.is_available').optional().isBoolean(),
];

export const extraValidation = [
  body().isArray().withMessage('Extras must be an array'),
  body('*.name').trim().notEmpty().withMessage('Extra name is required'),
  body('*.price').isFloat({ min: 0 }).withMessage('Extra price is required'),
  body('*.max_quantity').optional().isInt({ min: 1 }),
];
