import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { successResponse, errorResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import { query } from '../../config/database';
import * as authService from './auth.service';
import { sendWelcomeEmail, sendPasswordResetEmail } from '../../services/email.service';

export const register = catchAsync(async (req: Request, res: Response) => {
  const { email, password, first_name, last_name, phone, role } = req.body;

  const existing = await authService.findUserByEmail(email);
  if (existing) {
    return errorResponse(res, 'Email already registered', 409);
  }

  const verificationToken = uuidv4();
  const user = await authService.createUser(email, password, first_name, last_name, phone, role, verificationToken);
  const tokens = await authService.generateTokens(user);

  sendWelcomeEmail(email, first_name, verificationToken);

  return successResponse(res, {
    user: {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role,
      phone: user.phone,
    },
    ...tokens,
  }, 201, 'User registered successfully');
});

export const login = catchAsync(async (req: Request, res: Response) => {
  const { email, password } = req.body;

  const user = await authService.findUserByEmail(email);
  if (!user) {
    return errorResponse(res, 'Invalid email or password', 401);
  }

  if (!user.is_active) {
    return errorResponse(res, 'Account is deactivated', 401);
  }

  const isPasswordValid = await authService.comparePassword(password, user.password_hash);
  if (!isPasswordValid) {
    return errorResponse(res, 'Invalid email or password', 401);
  }

  await authService.updateLastLogin(user.id);
  const tokens = await authService.generateTokens(user);

  return successResponse(res, {
    user: {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role,
      avatar_url: user.avatar_url,
    },
    ...tokens,
  });
});

export const refresh = catchAsync(async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return errorResponse(res, 'Refresh token is required', 400);
  }

  const tokenData = await authService.validateRefreshToken(refreshToken);
  if (!tokenData) {
    return errorResponse(res, 'Invalid or expired refresh token', 401);
  }

  await authService.revokeRefreshToken(refreshToken);

  const user = await authService.findUserById(tokenData.user_id);
  if (!user) {
    return errorResponse(res, 'User not found', 404);
  }

  const tokens = await authService.generateTokens(user);

  return successResponse(res, tokens);
});

export const logout = catchAsync(async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (refreshToken) {
    await authService.revokeRefreshToken(refreshToken);
  }
  return successResponse(res, null, 200, 'Logged out successfully');
});

export const forgotPassword = catchAsync(async (req: Request, res: Response) => {
  const { email } = req.body;

  const user = await authService.findUserByEmail(email);
  if (!user) {
    return successResponse(res, null, 200, 'If the email exists, a reset link has been sent');
  }

  const resetToken = uuidv4();
  const expiresAt = new Date(Date.now() + 60 * 60 * 1000);

  await query(
    `UPDATE user_account SET reset_password_token = $1, reset_password_expires = $2 WHERE id = $3`,
    [resetToken, expiresAt, user.id]
  );

  await sendPasswordResetEmail(email, user.first_name, resetToken);

  return successResponse(res, null, 200, 'If the email exists, a reset link has been sent');
});

export const resetPassword = catchAsync(async (req: Request, res: Response) => {
  const { token, password } = req.body;

  const result = await query(
    `SELECT * FROM user_account WHERE reset_password_token = $1 AND reset_password_expires > NOW()`,
    [token]
  );

  if (result.rows.length === 0) {
    return errorResponse(res, 'Invalid or expired reset token', 400);
  }

  const passwordHash = await authService.hashPassword(password);
  await query(
    `UPDATE user_account SET password_hash = $1, reset_password_token = NULL, reset_password_expires = NULL WHERE id = $2`,
    [passwordHash, result.rows[0].id]
  );

  return successResponse(res, null, 200, 'Password reset successfully');
});

export const verifyEmail = catchAsync(async (req: Request, res: Response) => {
  const { token } = req.body;

  const result = await query(
    `UPDATE user_account SET email_verified = TRUE WHERE email_verification_token = $1 RETURNING *`,
    [token]
  );

  if (result.rows.length === 0) {
    return errorResponse(res, 'Invalid verification token', 400);
  }

  return successResponse(res, null, 200, 'Email verified successfully');
});

export const getMe = catchAsync(async (req: Request, res: Response) => {
  const user = await authService.findUserById(req.user!.userId);
  if (!user) {
    return errorResponse(res, 'User not found', 404);
  }

  let driverProfile = null;
  if (user.role === 'driver') {
    const dpResult = await query('SELECT * FROM driver_profile WHERE user_id = $1', [user.id]);
    driverProfile = dpResult.rows[0] || null;
  }

  return successResponse(res, {
    id: user.id,
    email: user.email,
    first_name: user.first_name,
    last_name: user.last_name,
    role: user.role,
    phone: user.phone,
    avatar_url: user.avatar_url,
    email_verified: user.email_verified,
    driver_profile: driverProfile,
  });
});
