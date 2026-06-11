import { Request, Response, NextFunction } from 'express';
import { query } from '../config/database';

export const auditLog = (action: string, entityType: string) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    const originalJson = res.json.bind(res);
    res.json = function (body: any) {
      if (res.statusCode < 400 && req.user) {
        const entityId = req.params.id || body?.data?.id || null;
        query(
          `INSERT INTO audit_log (user_id, action, entity_type, entity_id, ip_address, user_agent)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [req.user.userId, action, entityType, entityId, req.ip, req.headers['user-agent']]
        ).catch((err) => console.error('Audit log error:', err));
      }
      return originalJson(body);
    };
    next();
  };
};
