import { body } from 'express-validator';

export const updateDriverProfileValidation = [
  body('vehicle_type').optional().isIn(['motorcycle', 'bicycle', 'car', 'scooter', 'walking']),
  body('vehicle_plate').optional().trim(),
  body('vehicle_model').optional().trim(),
  body('vehicle_color').optional().trim(),
  body('license_number').optional().trim(),
];

export const updateLocationValidation = [
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude required'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude required'),
  body('accuracy').optional().isFloat(),
  body('heading').optional().isFloat({ min: 0, max: 360 }),
  body('speed').optional().isFloat({ min: 0 }),
];

export const updateStatusValidation = [
  body('status').isIn(['offline', 'online', 'busy']).withMessage('Invalid status'),
];
