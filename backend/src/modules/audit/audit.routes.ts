import { Router } from 'express';
import { authenticate, roleCheck } from '../../middleware/auth';
import { getAuditLogs } from './audit.controller';

const router = Router();

router.get('/', authenticate, roleCheck('admin'), getAuditLogs);

export default router;
