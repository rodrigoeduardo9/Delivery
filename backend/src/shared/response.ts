import { Response } from 'express';

export function successResponse(res: Response, data: any, statusCode: number = 200, message?: string) {
  return res.status(statusCode).json({
    success: true,
    message: message || 'Operation successful',
    data,
  });
}

export function errorResponse(res: Response, message: string, statusCode: number = 400, errors?: any) {
  return res.status(statusCode).json({
    success: false,
    message,
    errors: errors || undefined,
  });
}

export function paginatedResponse(res: Response, data: any[], total: number, page: number, limit: number, message?: string) {
  return res.status(200).json({
    success: true,
    message: message || 'Data retrieved successfully',
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  });
}
