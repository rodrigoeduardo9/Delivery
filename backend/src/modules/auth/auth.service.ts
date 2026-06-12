import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../../config';
import { query } from '../../config/database';
import { JwtPayload, AuthTokens, User } from '../../shared/interfaces';
import { UserRole } from '../../shared/enums';

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12);
}

export async function comparePassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

export function generateAccessToken(payload: JwtPayload): string {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn,
  } as jwt.SignOptions);
}

export function generateRefreshToken(): string {
  return uuidv4() + '-' + uuidv4();
}

export function verifyAccessToken(token: string): JwtPayload {
  return jwt.verify(token, config.jwt.secret) as JwtPayload;
}

export async function generateTokens(user: User): Promise<AuthTokens> {
  const accessToken = generateAccessToken({
    userId: user.id,
    role: user.role as UserRole,
    email: user.email,
  });

  const refreshToken = generateRefreshToken();
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7);

  await query(
    `INSERT INTO refresh_token (user_id, token, expires_at) VALUES ($1, $2, $3)`,
    [user.id, refreshToken, expiresAt]
  );

  return { accessToken, refreshToken };
}

export async function createUser(
  email: string,
  password: string,
  firstName: string,
  lastName: string,
  phone?: string,
  role?: string,
  verificationToken?: string
): Promise<User> {
  const passwordHash = await hashPassword(password);
  const userRole = role || UserRole.CUSTOMER;

  const result = await query(
    `INSERT INTO user_account (email, password_hash, first_name, last_name, phone, role, email_verification_token)
     VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
    [email, passwordHash, firstName, lastName, phone || null, userRole, verificationToken || null]
  );

  const user = result.rows[0];

  if (userRole === UserRole.DRIVER) {
    await query(
      `INSERT INTO driver_profile (user_id) VALUES ($1)`,
      [user.id]
    );
  }

  return user;
}

export async function findUserByEmail(email: string): Promise<User | null> {
  const result = await query(
    `SELECT * FROM user_account WHERE email = $1 AND is_deleted = FALSE`,
    [email]
  );
  return result.rows[0] || null;
}

export async function findUserById(id: string): Promise<User | null> {
  const result = await query(
    `SELECT * FROM user_account WHERE id = $1 AND is_deleted = FALSE`,
    [id]
  );
  return result.rows[0] || null;
}

export async function revokeRefreshToken(token: string): Promise<void> {
  await query(
    `UPDATE refresh_token SET revoked = TRUE WHERE token = $1`,
    [token]
  );
}

export async function validateRefreshToken(token: string): Promise<any> {
  const result = await query(
    `SELECT rt.*, ua.email, ua.role FROM refresh_token rt
     JOIN user_account ua ON rt.user_id = ua.id
     WHERE rt.token = $1 AND rt.revoked = FALSE AND rt.expires_at > NOW()`,
    [token]
  );
  return result.rows[0] || null;
}

export async function updateLastLogin(userId: string): Promise<void> {
  await query(
    `UPDATE user_account SET last_login_at = NOW() WHERE id = $1`,
    [userId]
  );
}
