import { Router } from 'express';
import { authenticate, roleCheck } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as paymentsController from './payments.controller';
import { processPaymentValidation } from './payments.validation';

const router = Router();

router.post('/process', authenticate, validate(processPaymentValidation), paymentsController.processPayment);
router.post('/refund/:id', authenticate, roleCheck('admin'), paymentsController.refundPayment);
router.get('/history', authenticate, paymentsController.getPaymentHistory);

export default router;
