import { Router } from 'express';
import { authenticate, roleCheck } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as ordersController from './orders.controller';
import { createOrderValidation, updateStatusValidation, rateOrderValidation } from './orders.validation';

const router = Router();

router.post('/calculate', authenticate, ordersController.calculateOrder);
router.post('/', authenticate, validate(createOrderValidation), ordersController.createOrder);
router.get('/', authenticate, ordersController.getOrders);
router.get('/tracking/:id', authenticate, ordersController.getOrderById);
router.get('/restaurant/:id/current', authenticate, roleCheck('restaurant_owner', 'admin'), ordersController.getRestaurantCurrentOrders);
router.get('/restaurant/:id/history', authenticate, roleCheck('restaurant_owner', 'admin'), ordersController.getRestaurantOrderHistory);
router.get('/:id', authenticate, ordersController.getOrderById);
router.put('/:id/cancel', authenticate, ordersController.cancelOrder);
router.put('/:id/status', authenticate, roleCheck('restaurant_owner', 'driver', 'admin'), validate(updateStatusValidation), ordersController.updateOrderStatus);
router.put('/:id/rate', authenticate, validate(rateOrderValidation), ordersController.rateOrder);

export default router;
