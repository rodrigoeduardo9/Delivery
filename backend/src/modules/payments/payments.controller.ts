import { Request, Response } from 'express';
import { successResponse, errorResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import { query } from '../../config/database';
import * as paymentsService from './payments.service';

export const processPayment = catchAsync(async (req: Request, res: Response) => {
  const orderResult = await query(
    'SELECT * FROM orders WHERE id = $1 AND customer_id = $2',
    [req.body.order_id, req.user!.userId]
  );

  if (orderResult.rows.length === 0) {
    return errorResponse(res, 'Order not found', 404);
  }

  const payment = await paymentsService.processPayment(orderResult.rows[0], req.body.payment_method);
  return successResponse(res, payment, 201, 'Payment processed successfully');
});

export const refundPayment = catchAsync(async (req: Request, res: Response) => {
  const payment = await paymentsService.refundPayment(req.params.id);
  if (!payment) {
    return errorResponse(res, 'Payment not found', 404);
  }
  return successResponse(res, payment, 200, 'Payment refunded successfully');
});

export const getPaymentHistory = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const { payments, total } = await paymentsService.getPaymentHistory(req.user!.userId, page, limit);
  return paginatedResponse(res, payments, total, page, limit);
});
