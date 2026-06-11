import { Request, Response } from 'express';
import { successResponse, errorResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import * as usersService from './users.service';

export const getUsers = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const role = req.query.role as string | undefined;
  const search = req.query.search as string | undefined;

  const { users, total } = await usersService.findAllUsers(page, limit, role, search);
  return paginatedResponse(res, users, total, page, limit);
});

export const getUserById = catchAsync(async (req: Request, res: Response) => {
  const user = await usersService.findUserById(req.params.id);
  if (!user) {
    return errorResponse(res, 'User not found', 404);
  }
  return successResponse(res, user);
});

export const updateUser = catchAsync(async (req: Request, res: Response) => {
  const userId = req.params.id || req.user!.userId;
  const user = await usersService.updateUser(userId, req.body);
  if (!user) {
    return errorResponse(res, 'User not found', 404);
  }
  return successResponse(res, user, 200, 'User updated successfully');
});

export const deleteUser = catchAsync(async (req: Request, res: Response) => {
  const deleted = await usersService.softDeleteUser(req.params.id);
  if (!deleted) {
    return errorResponse(res, 'User not found', 404);
  }
  return successResponse(res, null, 200, 'User deleted successfully');
});

export const getMyAddresses = catchAsync(async (req: Request, res: Response) => {
  const addresses = await usersService.findAddressesByUserId(req.user!.userId);
  return successResponse(res, addresses);
});

export const createAddress = catchAsync(async (req: Request, res: Response) => {
  const address = await usersService.createAddress(req.user!.userId, req.body);
  return successResponse(res, address, 201, 'Address created successfully');
});

export const updateAddress = catchAsync(async (req: Request, res: Response) => {
  const address = await usersService.updateAddress(req.params.id, req.user!.userId, req.body);
  if (!address) {
    return errorResponse(res, 'Address not found', 404);
  }
  return successResponse(res, address, 200, 'Address updated successfully');
});

export const deleteAddress = catchAsync(async (req: Request, res: Response) => {
  const deleted = await usersService.deleteAddress(req.params.id, req.user!.userId);
  if (!deleted) {
    return errorResponse(res, 'Address not found', 404);
  }
  return successResponse(res, null, 200, 'Address deleted successfully');
});
