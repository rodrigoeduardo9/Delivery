import { Request, Response } from 'express';
import { successResponse, errorResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import * as routesService from './routes.service';

export const optimizeRoute = catchAsync(async (req: Request, res: Response) => {
  const { origin, destination, waypoints } = req.body;
  if (!origin || !destination) {
    return errorResponse(res, 'Origin and destination are required', 400);
  }

  const result = await routesService.getRouteOptimization(origin, destination, waypoints || []);
  return successResponse(res, result);
});

export const getETA = catchAsync(async (req: Request, res: Response) => {
  const { origin_lat, origin_lng, dest_lat, dest_lng } = req.query;

  if (!origin_lat || !origin_lng || !dest_lat || !dest_lng) {
    return errorResponse(res, 'Origin and destination coordinates are required', 400);
  }

  const result = await routesService.getETA(
    { lat: parseFloat(origin_lat as string), lng: parseFloat(origin_lng as string) },
    { lat: parseFloat(dest_lat as string), lng: parseFloat(dest_lng as string) }
  );

  return successResponse(res, result);
});

export const getDirections = catchAsync(async (req: Request, res: Response) => {
  const { origin, destination } = req.query;
  if (!origin || !destination) {
    return errorResponse(res, 'Origin and destination are required', 400);
  }

  const result = await routesService.getDirections(origin as string, destination as string);
  return successResponse(res, result);
});
