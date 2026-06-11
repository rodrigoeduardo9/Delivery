import { Router } from 'express';
import { authenticate, roleCheck } from '../../middleware/auth';
import * as reportsController from './reports.controller';

const router = Router();

router.get('/admin/overview', authenticate, roleCheck('admin'), reportsController.getAdminOverview);
router.get('/admin/orders', authenticate, roleCheck('admin'), reportsController.getOrderReport);
router.get('/admin/revenue', authenticate, roleCheck('admin'), reportsController.getRevenueReport);
router.get('/admin/drivers', authenticate, roleCheck('admin'), reportsController.getDriverReport);
router.get('/admin/restaurants', authenticate, roleCheck('admin'), reportsController.getRestaurantReport);
router.get('/admin/export/:format', authenticate, roleCheck('admin'), reportsController.getExport);
router.get('/restaurant/:id/overview', authenticate, roleCheck('restaurant_owner', 'admin'), reportsController.getRestaurantOverview);
router.get('/restaurant/:id/sales', authenticate, roleCheck('restaurant_owner', 'admin'), reportsController.getRestaurantSales);

export default router;
