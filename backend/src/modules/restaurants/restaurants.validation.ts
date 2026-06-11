import { body } from 'express-validator';

export const createRestaurantValidation = [
  body('name').trim().notEmpty().withMessage('Restaurant name is required'),
  body('slug').trim().notEmpty().withMessage('Slug is required'),
  body('description').optional().trim(),
  body('phone').optional().trim(),
  body('email').optional().isEmail().normalizeEmail(),
  body('street').trim().notEmpty().withMessage('Street is required'),
  body('number').optional().trim(),
  body('city').trim().notEmpty().withMessage('City is required'),
  body('state').trim().notEmpty().withMessage('State is required'),
  body('zip_code').trim().notEmpty().withMessage('Zip code is required'),
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude required'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude required'),
  body('delivery_fee').optional().isFloat({ min: 0 }),
  body('minimum_order').optional().isFloat({ min: 0 }),
  body('delivery_radius_km').optional().isFloat({ min: 0 }),
  body('preparation_time_min').optional().isInt({ min: 0 }),
  body('categories').optional().isArray(),
];

export const createProductValidation = [
  body('name').trim().notEmpty().withMessage('Product name is required'),
  body('description').optional().trim(),
  body('price').isFloat({ min: 0 }).withMessage('Valid price required'),
  body('discounted_price').optional().isFloat({ min: 0 }),
  body('category').optional().trim(),
  body('is_available').optional().isBoolean(),
  body('stock').optional().isInt(),
  body('preparation_time_min').optional().isInt({ min: 0 }),
];

export const updateHoursValidation = [
  body().isArray().withMessage('Hours must be an array'),
  body('*.day_of_week').isIn(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
  body('*.open_time').matches(/^\d{2}:\d{2}$/).withMessage('Open time must be HH:MM'),
  body('*.close_time').matches(/^\d{2}:\d{2}$/).withMessage('Close time must be HH:MM'),
  body('*.is_closed').optional().isBoolean(),
];
