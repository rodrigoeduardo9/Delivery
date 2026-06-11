import { Request, Response } from 'express';
import { successResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import * as reportsService from './reports.service';

export const getAdminOverview = catchAsync(async (req: Request, res: Response) => {
  const data = await reportsService.getAdminOverview();
  return successResponse(res, data);
});

export const getOrderReport = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const startDate = req.query.start_date as string | undefined;
  const endDate = req.query.end_date as string | undefined;

  const { orders, total } = await reportsService.getOrderReport(startDate, endDate, page, limit);
  return paginatedResponse(res, orders, total, page, limit);
});

export const getRevenueReport = catchAsync(async (req: Request, res: Response) => {
  const startDate = req.query.start_date as string | undefined;
  const endDate = req.query.end_date as string | undefined;

  const data = await reportsService.getRevenueReport(startDate, endDate);
  return successResponse(res, data);
});

export const getDriverReport = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  const { drivers, total } = await reportsService.getDriverPerformanceReport(page, limit);
  return paginatedResponse(res, drivers, total, page, limit);
});

export const getRestaurantReport = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  const { restaurants, total } = await reportsService.getRestaurantPerformanceReport(page, limit);
  return paginatedResponse(res, restaurants, total, page, limit);
});

export const getExport = catchAsync(async (req: Request, res: Response) => {
  const format = req.params.format;
  const type = req.query.type as string || 'orders';

  let data: any;
  if (type === 'orders') {
    const { orders } = await reportsService.getOrderReport(undefined, undefined, 1, 10000);
    data = orders;
  } else if (type === 'revenue') {
    data = await reportsService.getRevenueReport();
  } else {
    data = [];
  }

  if (format === 'csv') {
    if (!Array.isArray(data)) data = [data];
    const headers = Object.keys(data[0] || {}).join(',');
    const rows = data.map((row: any) =>
      Object.values(row)
        .map((v) => (typeof v === 'string' ? `"${v.replace(/"/g, '""')}"` : v))
        .join(',')
    );
    const csv = [headers, ...rows].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename=${type}_report.csv`);
    return res.send(csv);
  }

  return successResponse(res, data);
});

export const getRestaurantOverview = catchAsync(async (req: Request, res: Response) => {
  const data = await reportsService.getRestaurantOverview(req.params.id);
  return successResponse(res, data);
});

export const getRestaurantSales = catchAsync(async (req: Request, res: Response) => {
  const startDate = req.query.start_date as string | undefined;
  const endDate = req.query.end_date as string | undefined;

  const data = await reportsService.getRestaurantSalesReport(req.params.id, startDate, endDate);
  return successResponse(res, data);
});
