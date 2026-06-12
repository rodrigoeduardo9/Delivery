import { Router } from 'express';
import { authenticate, roleCheck } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as driversController from './drivers.controller';
import {
  updateDriverProfileValidation,
  updateLocationValidation,
  updateStatusValidation,
} from './drivers.validation';

const router = Router();

router.get('/me', authenticate, roleCheck('driver'), driversController.getMyProfile);
router.put('/me', authenticate, roleCheck('driver'), validate(updateDriverProfileValidation), driversController.updateMyProfile);
router.put('/me/location', authenticate, roleCheck('driver'), validate(updateLocationValidation), driversController.updateLocation);
router.put('/me/status', authenticate, roleCheck('driver'), validate(updateStatusValidation), driversController.updateStatus);
router.get('/me/earnings', authenticate, roleCheck('driver'), driversController.getEarnings);
router.get('/me/history', authenticate, roleCheck('driver'), driversController.getMyHistory);
router.post('/me/documents', authenticate, roleCheck('driver'), driversController.uploadDriverDocument);

router.get('/orders/available', authenticate, roleCheck('driver'), driversController.getAvailableOrders);
router.put('/orders/:id/accept', authenticate, roleCheck('driver'), driversController.acceptOrder);
router.put('/orders/:id/reject', authenticate, roleCheck('driver'), driversController.rejectOrder);
router.put('/orders/:id/pickup', authenticate, roleCheck('driver'), driversController.markPickedUp);
router.put('/orders/:id/deliver', authenticate, roleCheck('driver'), driversController.markDelivered);

router.get('/admin', authenticate, roleCheck('admin'), driversController.getDriversForAdmin);
router.get('/admin/:id', authenticate, roleCheck('admin'), driversController.getDriverById);
router.put('/admin/:id/verify', authenticate, roleCheck('admin'), driversController.verifyDriver);
router.put('/admin/:id/status', authenticate, roleCheck('admin'), driversController.updateDriverStatusByAdmin);

export default router;
