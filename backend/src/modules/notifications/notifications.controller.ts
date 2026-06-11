import { Request, Response } from 'express';
import { successResponse, errorResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import * as notificationsService from './notifications.service';

export const getNotifications = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const unreadOnly = req.query.unread === 'true';

  const { notifications, total, unread_count } = await notificationsService.findUserNotifications(
    req.user!.userId, page, limit, unreadOnly
  );

  return res.status(200).json({
    success: true,
    data: notifications,
    pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    unread_count,
  });
});

export const markAsRead = catchAsync(async (req: Request, res: Response) => {
  const updated = await notificationsService.markAsRead(req.params.id, req.user!.userId);
  if (!updated) {
    return errorResponse(res, 'Notification not found', 404);
  }
  return successResponse(res, null, 200, 'Notification marked as read');
});

export const markAllAsRead = catchAsync(async (req: Request, res: Response) => {
  await notificationsService.markAllAsRead(req.user!.userId);
  return successResponse(res, null, 200, 'All notifications marked as read');
});
