import { Request, Response } from 'express';
import { successResponse, errorResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import { query } from '../../config/database';
import * as ordersService from './orders.service';
import * as paymentsService from '../payments/payments.service';

export const createOrder = catchAsync(async (req: Request, res: Response) => {
  const totals = await ordersService.calculateOrderTotal(
    req.body.restaurant_id,
    req.body.items,
    req.body.coupon_code
  );

  const order = await ordersService.createOrder(req.user!.userId, req.body, totals);

  if (req.body.payment_method !== 'cash') {
    try {
      const payment = await paymentsService.processPayment(order, req.body.payment_method);
      await ordersService.updateOrderStatus(order.id, 'confirmed', req.user!.userId);
      return successResponse(res, { order, payment }, 201, 'Order created and payment processed');
    } catch (paymentError: any) {
      return successResponse(res, {
        order,
        payment_error: paymentError.message,
      }, 201, 'Order created but payment failed');
    }
  }

  return successResponse(res, { order }, 201, 'Order created successfully');
});

export const getOrders = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const status = req.query.status as string | undefined;

  let customerId: string | undefined;
  let restaurantId: string | undefined;
  let driverId: string | undefined;

  if (req.user!.role === 'customer') customerId = req.user!.userId;
  else if (req.user!.role === 'restaurant_owner') {
    const result = await query('SELECT id FROM restaurant WHERE owner_id = $1', [req.user!.userId]);
    const ids = result.rows.map((r: any) => r.id);
    if (ids.length > 0) {
      if (req.query.restaurant_id) {
        restaurantId = req.query.restaurant_id as string;
      } else {
        return successResponse(res, []);
      }
    }
  } else if (req.user!.role === 'driver') {
    const result = await query('SELECT id FROM driver_profile WHERE user_id = $1', [req.user!.userId]);
    if (result.rows[0]) driverId = result.rows[0].id;
  }

  const { orders, total } = await ordersService.findOrders(
    customerId, restaurantId, driverId, status, page, limit
  );

  return paginatedResponse(res, orders, total, page, limit);
});

export const getOrderById = catchAsync(async (req: Request, res: Response) => {
  const order = await ordersService.findOrderById(req.params.id);
  if (!order) {
    return errorResponse(res, 'Order not found', 404);
  }
  return successResponse(res, order);
});

export const cancelOrder = catchAsync(async (req: Request, res: Response) => {
  try {
    const order = await ordersService.cancelOrder(
      req.params.id,
      req.user!.userId,
      req.body.reason
    );
    return successResponse(res, order, 200, 'Order cancelled successfully');
  } catch (err: any) {
    return errorResponse(res, err.message, 400);
  }
});

export const updateOrderStatus = catchAsync(async (req: Request, res: Response) => {
  try {
    const order = await ordersService.updateOrderStatus(
      req.params.id,
      req.body.status,
      req.user!.userId,
      req.body.note
    );
    if (!order) {
      return errorResponse(res, 'Order not found', 404);
    }
    return successResponse(res, order, 200, `Order status updated to ${req.body.status}`);
  } catch (err: any) {
    return errorResponse(res, err.message, 400);
  }
});

export const rateOrder = catchAsync(async (req: Request, res: Response) => {
  try {
    const review = await ordersService.rateOrder(
      req.params.id,
      req.user!.userId,
      req.body.rating,
      req.body.review,
      req.body.driver_rating
    );
    return successResponse(res, review, 200, 'Order rated successfully');
  } catch (err: any) {
    return errorResponse(res, err.message, 400);
  }
});

export const calculateOrder = catchAsync(async (req: Request, res: Response) => {
  try {
    const totals = await ordersService.calculateOrderTotal(
      req.body.restaurant_id,
      req.body.items,
      req.body.coupon_code
    );
    return successResponse(res, totals);
  } catch (err: any) {
    return errorResponse(res, err.message, 400);
  }
});

export const reorder = catchAsync(async (req: Request, res: Response) => {
  try {
    const order = await ordersService.reorderFromOrder(req.params.id, req.user!.userId);
    return successResponse(res, { order }, 201, 'Order placed successfully');
  } catch (err: any) {
    return errorResponse(res, err.message, 400);
  }
});

export const getRestaurantCurrentOrders = catchAsync(async (req: Request, res: Response) => {
  const { orders } = await ordersService.findOrders(
    undefined, req.params.id, undefined, 'active', 1, 50
  );
  return successResponse(res, orders);
});

export const getRestaurantOrderHistory = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const { orders, total } = await ordersService.findOrders(
    undefined, req.params.id, undefined, undefined, page, limit
  );
  return paginatedResponse(res, orders, total, page, limit);
});
