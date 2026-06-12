import { Request, Response } from 'express';
import { successResponse, errorResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import { uploadRestaurantImage, uploadProductImage } from '../../middleware/upload';
import * as restaurantsService from './restaurants.service';

export const createRestaurant = catchAsync(async (req: Request, res: Response) => {
  const restaurant = await restaurantsService.createRestaurant(req.user!.userId, req.body);
  return successResponse(res, restaurant, 201, 'Restaurant created successfully');
});

export const getRestaurants = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const filters = {
    is_active: req.query.is_active !== undefined ? req.query.is_active === 'true' : undefined,
    category: req.query.category as string | undefined,
    search: req.query.search as string | undefined,
  };

  const { restaurants, total } = await restaurantsService.findAllRestaurants(page, limit, filters);
  return paginatedResponse(res, restaurants, total, page, limit);
});

export const getNearbyRestaurants = catchAsync(async (req: Request, res: Response) => {
  const latitude = parseFloat(req.query.lat as string);
  const longitude = parseFloat(req.query.lng as string);
  const radiusKm = parseFloat(req.query.radius as string) || 5;
  const category = req.query.category as string | undefined;
  const search = req.query.search as string | undefined;
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  if (!latitude || !longitude) {
    return errorResponse(res, 'Latitude and longitude are required', 400);
  }

  const { restaurants, total } = await restaurantsService.findNearbyRestaurants(
    latitude, longitude, radiusKm, category, search, page, limit
  );

  return paginatedResponse(res, restaurants, total, page, limit);
});

export const getRestaurantById = catchAsync(async (req: Request, res: Response) => {
  const restaurant = await restaurantsService.findRestaurantById(req.params.id);
  if (!restaurant) {
    return errorResponse(res, 'Restaurant not found', 404);
  }

  const hours = await restaurantsService.findRestaurantHours(req.params.id);
  return successResponse(res, { ...restaurant, hours });
});

export const updateRestaurant = catchAsync(async (req: Request, res: Response) => {
  const restaurant = await restaurantsService.updateRestaurant(req.params.id, req.body);
  if (!restaurant) {
    return errorResponse(res, 'Restaurant not found', 404);
  }
  return successResponse(res, restaurant, 200, 'Restaurant updated successfully');
});

export const updateRestaurantStatus = catchAsync(async (req: Request, res: Response) => {
  const isOpen = await restaurantsService.syncRestaurantStatus(req.params.id);
  return successResponse(res, { is_open: isOpen });
});

export const updateRestaurantHours = catchAsync(async (req: Request, res: Response) => {
  await restaurantsService.upsertRestaurantHours(req.params.id, req.body);
  return successResponse(res, null, 200, 'Hours updated successfully');
});

export const getRestaurantProducts = catchAsync(async (req: Request, res: Response) => {
  const products = await restaurantsService.findProductsByRestaurant(
    req.params.id,
    req.query.category as string | undefined
  );
  return successResponse(res, products);
});

export const createRestaurantProduct = catchAsync(async (req: Request, res: Response) => {
  const product = await restaurantsService.createProduct(req.params.id, req.body);
  return successResponse(res, product, 201, 'Product created successfully');
});

export const updateRestaurantProduct = catchAsync(async (req: Request, res: Response) => {
  const product = await restaurantsService.updateProduct(
    req.params.productId, req.params.id, req.body
  );
  if (!product) {
    return errorResponse(res, 'Product not found', 404);
  }
  return successResponse(res, product, 200, 'Product updated successfully');
});

export const deleteRestaurantProduct = catchAsync(async (req: Request, res: Response) => {
  const deleted = await restaurantsService.deleteProduct(req.params.productId, req.params.id);
  if (!deleted) {
    return errorResponse(res, 'Product not found', 404);
  }
  return successResponse(res, null, 200, 'Product deleted successfully');
});

export const addZone = catchAsync(async (req: Request, res: Response) => {
  const zone = await restaurantsService.addZone(req.params.id, req.body);
  return successResponse(res, zone, 201, 'Delivery zone added successfully');
});

export const getCategories = catchAsync(async (req: Request, res: Response) => {
  const categories = await restaurantsService.getCategories();
  return successResponse(res, categories);
});

export const getRestaurantReviews = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const offset = (page - 1) * limit;

  const { query } = await import('../../config/database');
  const countResult = await query(
    `SELECT COUNT(*) FROM review WHERE restaurant_id = $1 AND is_visible = TRUE`,
    [req.params.id]
  );
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(
    `SELECT r.*, u.first_name, u.last_name, u.avatar_url
     FROM review r JOIN user_account u ON r.customer_id = u.id
     WHERE r.restaurant_id = $1 AND r.is_visible = TRUE
     ORDER BY r.created_at DESC LIMIT $2 OFFSET $3`,
    [req.params.id, limit, offset]
  );

  return paginatedResponse(res, result.rows, total, page, limit);
});

export const getRestaurantAvailability = catchAsync(async (req: Request, res: Response) => {
  const isOpen = await restaurantsService.syncRestaurantStatus(req.params.id);
  return successResponse(res, { is_open: isOpen });
});

export const uploadRestaurantLogo = catchAsync(async (req: Request, res: Response) => {
  uploadRestaurantImage(req, res, async (err) => {
    if (err) return errorResponse(res, err.message, 400);
    if (!req.files || !(req.files as any).logo) return errorResponse(res, 'No logo file uploaded', 400);
    const logoUrl = `/uploads/logos/${(req.files as any).logo[0].filename}`;
    const restaurant = await restaurantsService.updateRestaurant(req.params.id, { logo_url: logoUrl } as any);
    if (!restaurant) return errorResponse(res, 'Restaurant not found', 404);
    return successResponse(res, { logo_url: logoUrl }, 200, 'Logo uploaded successfully');
  });
});

export const uploadRestaurantBanner = catchAsync(async (req: Request, res: Response) => {
  uploadRestaurantImage(req, res, async (err) => {
    if (err) return errorResponse(res, err.message, 400);
    if (!req.files || !(req.files as any).banner) return errorResponse(res, 'No banner file uploaded', 400);
    const bannerUrl = `/uploads/banners/${(req.files as any).banner[0].filename}`;
    const restaurant = await restaurantsService.updateRestaurant(req.params.id, { banner_url: bannerUrl } as any);
    if (!restaurant) return errorResponse(res, 'Restaurant not found', 404);
    return successResponse(res, { banner_url: bannerUrl }, 200, 'Banner uploaded successfully');
  });
});

export const uploadProductImageHandler = catchAsync(async (req: Request, res: Response) => {
  uploadProductImage(req, res, async (err) => {
    if (err) return errorResponse(res, err.message, 400);
    if (!req.file) return errorResponse(res, 'No image file uploaded', 400);
    const imageUrl = `/uploads/products/${req.file.filename}`;
    const product = await restaurantsService.updateProduct(req.params.productId, req.params.id, { image_url: imageUrl } as any);
    if (!product) return errorResponse(res, 'Product not found', 404);
    return successResponse(res, { image_url: imageUrl }, 200, 'Product image uploaded successfully');
  });
});
