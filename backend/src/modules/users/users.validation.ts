import { body } from 'express-validator';

export const updateUserValidation = [
  body('first_name').optional().trim().isLength({ min: 1, max: 100 }).withMessage('First name must be 1-100 characters'),
  body('last_name').optional().trim().isLength({ min: 1, max: 100 }).withMessage('Last name must be 1-100 characters'),
  body('phone').optional().isMobilePhone('any').withMessage('Valid phone number required'),
  body('avatar_url').optional().isURL().withMessage('Valid URL required for avatar'),
];

export const createAddressValidation = [
  body('label').optional().trim().isLength({ max: 50 }).withMessage('Label max 50 characters'),
  body('street').trim().notEmpty().withMessage('Street is required'),
  body('number').optional().trim(),
  body('complement').optional().trim(),
  body('neighborhood').optional().trim(),
  body('city').trim().notEmpty().withMessage('City is required'),
  body('state').trim().notEmpty().withMessage('State is required'),
  body('zip_code').trim().notEmpty().withMessage('Zip code is required'),
  body('latitude').optional().isFloat({ min: -90, max: 90 }).withMessage('Invalid latitude'),
  body('longitude').optional().isFloat({ min: -180, max: 180 }).withMessage('Invalid longitude'),
  body('is_default').optional().isBoolean().withMessage('is_default must be boolean'),
];
