import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import * as routesController from './routes.controller';

const router = Router();

router.post('/optimize', authenticate, routesController.optimizeRoute);
router.post('/eta', authenticate, routesController.getETA);
router.get('/directions', authenticate, routesController.getDirections);

export default router;
