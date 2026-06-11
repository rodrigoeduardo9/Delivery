import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import * as notificationsController from './notifications.controller';

const router = Router();

router.get('/', authenticate, notificationsController.getNotifications);
router.put('/:id/read', authenticate, notificationsController.markAsRead);
router.put('/read-all', authenticate, notificationsController.markAllAsRead);

export default router;
