import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import { authLimiter } from '../../middleware/rateLimiter';
import * as authController from './auth.controller';
import {
  registerValidation,
  loginValidation,
  forgotPasswordValidation,
  resetPasswordValidation,
} from './auth.validation';

const router = Router();

router.post('/register', authLimiter, validate(registerValidation), authController.register);
router.post('/login', authLimiter, validate(loginValidation), authController.login);
router.post('/refresh', authLimiter, authController.refresh);
router.post('/logout', authController.logout);
router.post('/forgot-password', authLimiter, validate(forgotPasswordValidation), authController.forgotPassword);
router.post('/reset-password', authLimiter, validate(resetPasswordValidation), authController.resetPassword);
router.post('/verify-email', authLimiter, authController.verifyEmail);
router.get('/me', authenticate, authController.getMe);

export default router;
