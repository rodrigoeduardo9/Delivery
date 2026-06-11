import { Request, Response } from 'express';
import { successResponse, errorResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import * as productsService from './products.service';

export const getProducts = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const restaurantId = req.query.restaurant_id as string | undefined;
  const category = req.query.category as string | undefined;

  const { products, total } = await productsService.findProducts(page, limit, restaurantId, category);
  return paginatedResponse(res, products, total, page, limit);
});

export const getProductById = catchAsync(async (req: Request, res: Response) => {
  const product = await productsService.getProductWithDetails(req.params.id);
  if (!product) {
    return errorResponse(res, 'Product not found', 404);
  }
  return successResponse(res, product);
});

export const updateProduct = catchAsync(async (req: Request, res: Response) => {
  const product = await productsService.updateProduct(req.params.id, req.body);
  if (!product) {
    return errorResponse(res, 'Product not found', 404);
  }
  return successResponse(res, product, 200, 'Product updated successfully');
});

export const updateVariants = catchAsync(async (req: Request, res: Response) => {
  const variants = await productsService.updateVariants(req.params.id, req.body.variants || []);
  return successResponse(res, variants, 200, 'Variants updated successfully');
});

export const updateExtras = catchAsync(async (req: Request, res: Response) => {
  const extras = await productsService.updateExtras(req.params.id, req.body.extras || []);
  return successResponse(res, extras, 200, 'Extras updated successfully');
});
