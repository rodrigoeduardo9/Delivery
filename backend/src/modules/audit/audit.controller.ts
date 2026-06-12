import { Request, Response } from 'express';
import { successResponse, paginatedResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import { query } from '../../config/database';

export const getAuditLogs = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 50;
  const offset = (page - 1) * limit;
  const { search, action, start_date, end_date } = req.query;

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (search) {
    conditions.push(`(u.first_name ILIKE $${paramIndex} OR u.last_name ILIKE $${paramIndex} OR a.entity_id::text ILIKE $${paramIndex})`);
    params.push(`%${search}%`);
    paramIndex++;
  }
  if (action) {
    conditions.push(`a.action = $${paramIndex++}`);
    params.push(action);
  }
  if (start_date) {
    conditions.push(`a.created_at >= $${paramIndex++}`);
    params.push(start_date);
  }
  if (end_date) {
    conditions.push(`a.created_at <= $${paramIndex++}`);
    params.push(end_date);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const countResult = await query(`SELECT COUNT(*) FROM audit_log a LEFT JOIN user_account u ON a.user_id = u.id ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].count, 10);

  params.push(limit, offset);
  const result = await query(
    `SELECT a.*, u.first_name || ' ' || u.last_name as admin_name
     FROM audit_log a
     LEFT JOIN user_account u ON a.user_id = u.id
     ${whereClause}
     ORDER BY a.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    params
  );

  return paginatedResponse(res, result.rows, total, page, limit);
});
