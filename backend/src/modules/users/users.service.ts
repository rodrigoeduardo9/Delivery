import { query } from '../../config/database';
import { User, Address } from '../../shared/interfaces';

export async function findAllUsers(
  page: number = 1,
  limit: number = 20,
  role?: string,
  search?: string,
  status?: string
): Promise<{ users: User[]; total: number }> {
  const offset = (page - 1) * limit;
  const conditions: string[] = ['is_deleted = FALSE'];
  const params: any[] = [];
  let paramIndex = 1;

  if (role) {
    conditions.push(`role = $${paramIndex++}`);
    params.push(role);
  }

  if (status) {
    if (status === 'active') {
      conditions.push(`is_active = TRUE`);
    } else if (status === 'suspended') {
      conditions.push(`is_active = FALSE`);
    }
  }

  if (search) {
    conditions.push(`(first_name ILIKE $${paramIndex} OR last_name ILIKE $${paramIndex} OR email ILIKE $${paramIndex})`);
    params.push(`%${search}%`);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const countResult = await query(`SELECT COUNT(*) FROM user_account ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].count, 10);

  const result = await query(
    `SELECT id, email, phone, first_name, last_name, role, avatar_url, email_verified,
            is_active, last_login_at, created_at, updated_at
     FROM user_account ${whereClause}
     ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  return { users: result.rows, total };
}

export async function toggleUserStatus(id: string): Promise<User | null> {
  const result = await query(
    `UPDATE user_account SET is_active = NOT is_active WHERE id = $1 AND is_deleted = FALSE RETURNING id, email, first_name, last_name, role, is_active`,
    [id]
  );
  return result.rows[0] || null;
}

export async function findUserById(id: string): Promise<User | null> {
  const result = await query(
    `SELECT id, email, phone, first_name, last_name, role, avatar_url, email_verified,
            phone_verified, is_active, last_login_at, created_at, updated_at
     FROM user_account WHERE id = $1 AND is_deleted = FALSE`,
    [id]
  );
  return result.rows[0] || null;
}

export async function updateUser(id: string, data: Partial<User>): Promise<User | null> {
  const fields: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  for (const [key, value] of Object.entries(data)) {
    if (value !== undefined && ['first_name', 'last_name', 'phone', 'avatar_url'].includes(key)) {
      fields.push(`${key} = $${paramIndex++}`);
      params.push(value);
    }
  }

  if (fields.length === 0) {
    return findUserById(id);
  }

  params.push(id);
  const result = await query(
    `UPDATE user_account SET ${fields.join(', ')} WHERE id = $${paramIndex} AND is_deleted = FALSE RETURNING id, email, phone, first_name, last_name, role, avatar_url, email_verified, is_active, created_at, updated_at`,
    params
  );
  return result.rows[0] || null;
}

export async function softDeleteUser(id: string): Promise<boolean> {
  const result = await query(
    `UPDATE user_account SET is_deleted = TRUE, is_active = FALSE WHERE id = $1 RETURNING id`,
    [id]
  );
  return result.rows.length > 0;
}

export async function findAddressesByUserId(userId: string): Promise<Address[]> {
  const result = await query(
    `SELECT * FROM address WHERE user_id = $1 ORDER BY is_default DESC, created_at DESC`,
    [userId]
  );
  return result.rows;
}

export async function createAddress(userId: string, data: any): Promise<Address> {
  if (data.is_default) {
    await query(`UPDATE address SET is_default = FALSE WHERE user_id = $1`, [userId]);
  }

  const result = await query(
    `INSERT INTO address (user_id, label, street, number, complement, neighborhood, city, state, zip_code, latitude, longitude, is_default)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *`,
    [
      userId, data.label || 'Home', data.street, data.number || null,
      data.complement || null, data.neighborhood || null, data.city, data.state,
      data.zip_code, data.latitude || null, data.longitude || null, data.is_default || false,
    ]
  );
  return result.rows[0];
}

export async function updateAddress(addressId: string, userId: string, data: any): Promise<Address | null> {
  if (data.is_default) {
    await query(`UPDATE address SET is_default = FALSE WHERE user_id = $1`, [userId]);
  }

  const fields: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;
  const allowedFields = ['label', 'street', 'number', 'complement', 'neighborhood', 'city', 'state', 'zip_code', 'latitude', 'longitude', 'is_default'];

  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      fields.push(`${key} = $${paramIndex++}`);
      params.push(data[key]);
    }
  }

  if (fields.length === 0) return null;

  params.push(addressId, userId);
  const result = await query(
    `UPDATE address SET ${fields.join(', ')} WHERE id = $${paramIndex} AND user_id = $${paramIndex + 1} RETURNING *`,
    params
  );
  return result.rows[0] || null;
}

export async function deleteAddress(addressId: string, userId: string): Promise<boolean> {
  const result = await query(
    `DELETE FROM address WHERE id = $1 AND user_id = $2 RETURNING id`,
    [addressId, userId]
  );
  return result.rows.length > 0;
}
