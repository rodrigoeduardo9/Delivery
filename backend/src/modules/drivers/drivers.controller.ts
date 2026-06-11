import { Request, Response } from 'express';
import { successResponse, errorResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import { query } from '../../config/database';
import * as driversService from './drivers.service';

export const getMyProfile = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  const locationResult = await query(
    'SELECT * FROM driver_current_location WHERE driver_profile_id = $1',
    [profile.id]
  );

  return successResponse(res, {
    ...profile,
    current_location: locationResult.rows[0] || null,
  });
});

export const updateMyProfile = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.updateDriverProfile(req.user!.userId, req.body);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }
  return successResponse(res, profile, 200, 'Profile updated successfully');
});

export const updateLocation = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  await driversService.updateDriverLocation(
    profile.id,
    req.body.latitude,
    req.body.longitude,
    req.body.accuracy,
    req.body.heading,
    req.body.speed
  );

  return successResponse(res, null, 200, 'Location updated');
});

export const updateStatus = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.updateDriverStatus(req.user!.userId, req.body.status);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }
  return successResponse(res, profile, 200, `Status updated to ${req.body.status}`);
});

export const getEarnings = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  const { earnings, total, total_amount } = await driversService.getDriverEarnings(
    profile.id, page, limit
  );

  return paginatedResponse(res, earnings, total, page, limit);
});

export const getMyHistory = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  const { orders, total } = await driversService.getDriverOrderHistory(profile.id, page, limit);
  return paginatedResponse(res, orders, total, page, limit);
});

export const getAvailableOrders = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  const { orders, total } = await driversService.findAvailableOrders(profile.id, page, limit);
  return paginatedResponse(res, orders, total, page, limit);
});

export const acceptOrder = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  const order = await driversService.acceptOrder(profile.id, req.params.id);
  if (!order) {
    return errorResponse(res, 'Order not available or already assigned', 409);
  }

  return successResponse(res, order, 200, 'Order accepted');
});

export const rejectOrder = catchAsync(async (req: Request, res: Response) => {
  return successResponse(res, null, 200, 'Order rejected');
});

export const markPickedUp = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  const order = await driversService.markAsPickedUp(profile.id, req.params.id);
  if (!order) {
    return errorResponse(res, 'Cannot mark as picked up', 400);
  }

  return successResponse(res, order, 200, 'Order marked as picked up');
});

export const markDelivered = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileByUserId(req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver profile not found', 404);
  }

  const order = await driversService.markAsDelivered(profile.id, req.params.id);
  if (!order) {
    return errorResponse(res, 'Cannot mark as delivered', 400);
  }

  return successResponse(res, order, 200, 'Order delivered successfully');
});

export const getDriversForAdmin = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const status = req.query.status as string | undefined;
  const verified = req.query.verified !== undefined ? req.query.verified === 'true' : undefined;

  const { drivers, total } = await driversService.findDriversForAdmin(page, limit, status, verified);
  return paginatedResponse(res, drivers, total, page, limit);
});

export const getDriverById = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.getDriverProfileById(req.params.id);
  if (!profile) {
    return errorResponse(res, 'Driver not found', 404);
  }
  return successResponse(res, profile);
});

export const verifyDriver = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.verifyDriver(req.params.id, req.user!.userId);
  if (!profile) {
    return errorResponse(res, 'Driver not found', 404);
  }
  return successResponse(res, profile, 200, 'Driver verified successfully');
});

export const updateDriverStatusByAdmin = catchAsync(async (req: Request, res: Response) => {
  const profile = await driversService.updateDriverStatusByAdmin(req.params.id, req.body.status);
  if (!profile) {
    return errorResponse(res, 'Driver not found', 404);
  }
  return successResponse(res, profile, 200, 'Driver status updated');
});
