import { Router } from 'express';
import { authenticate, roleCheck } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as restaurantsController from './restaurants.controller';
import {
  createRestaurantValidation,
  createProductValidation,
  updateHoursValidation,
} from './restaurants.validation';

const router = Router();

router.get('/categories', restaurantsController.getCategories);
router.get('/nearby', restaurantsController.getNearbyRestaurants);
router.get('/', restaurantsController.getRestaurants);
router.get('/:id', restaurantsController.getRestaurantById);
router.get('/:id/products', restaurantsController.getRestaurantProducts);
router.get('/:id/reviews', restaurantsController.getRestaurantReviews);
router.get('/:id/availability', restaurantsController.getRestaurantAvailability);
router.post('/', authenticate, roleCheck('admin', 'restaurant_owner'), validate(createRestaurantValidation), restaurantsController.createRestaurant);
router.put('/:id', authenticate, restaurantsController.updateRestaurant);
router.put('/:id/status', authenticate, restaurantsController.updateRestaurantStatus);
router.put('/:id/hours', authenticate, validate(updateHoursValidation), restaurantsController.updateRestaurantHours);
router.post('/:id/products', authenticate, validate(createProductValidation), restaurantsController.createRestaurantProduct);
router.put('/:id/products/:productId', authenticate, restaurantsController.updateRestaurantProduct);
router.delete('/:id/products/:productId', authenticate, restaurantsController.deleteRestaurantProduct);
router.post('/:id/zones', authenticate, restaurantsController.addZone);
router.post('/:id/logo', authenticate, restaurantsController.uploadRestaurantLogo);
router.post('/:id/banner', authenticate, restaurantsController.uploadRestaurantBanner);
router.post('/:id/products/:productId/image', authenticate, restaurantsController.uploadProductImageHandler);

export default router;
