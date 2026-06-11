import * as admin from 'firebase-admin';
import nodemailer from 'nodemailer';
import { config } from '../../config';
import { query } from '../../config/database';
import { Notification } from '../../shared/interfaces';
import { logger } from '../../config/logger';

let firebaseInitialized = false;

function initFirebase() {
  if (firebaseInitialized) return;
  try {
    const serviceAccount = require(config.firebase.serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    firebaseInitialized = true;
  } catch (error) {
    logger.warn('Firebase not configured, push notifications disabled');
  }
}

let transporter: nodemailer.Transporter | null = null;

function initMailer() {
  if (transporter) return;
  if (config.smtp.user && config.smtp.pass) {
    transporter = nodemailer.createTransport({
      host: config.smtp.host,
      port: config.smtp.port,
      secure: config.smtp.port === 465,
      auth: {
        user: config.smtp.user,
        pass: config.smtp.pass,
      },
    });
  } else {
    logger.warn('SMTP not configured, email notifications disabled');
  }
}

export async function sendPushNotification(
  userId: string,
  title: string,
  body: string,
  data?: any
): Promise<void> {
  initFirebase();

  if (!firebaseInitialized) return;

  try {
    const deviceResult = await query(
      `SELECT fcm_token FROM user_account WHERE id = $1 AND fcm_token IS NOT NULL`,
      [userId]
    );

    if (deviceResult.rows.length === 0) return;

    const message = {
      notification: { title, body },
      data: data ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])) : {},
      token: deviceResult.rows[0].fcm_token,
    };

    await admin.messaging().send(message);
  } catch (error: any) {
    logger.error('Push notification error:', error);
  }
}

export async function sendEmail(
  to: string,
  subject: string,
  html: string
): Promise<void> {
  initMailer();
  if (!transporter) return;

  try {
    await transporter.sendMail({
      from: `"Delivery Platform" <${config.smtp.user}>`,
      to,
      subject,
      html,
    });
  } catch (error: any) {
    logger.error('Email sending error:', error);
  }
}

export async function createNotification(
  userId: string,
  type: string,
  title: string,
  body?: string,
  data?: any
): Promise<Notification> {
  const result = await query(
    `INSERT INTO notification (user_id, type, title, body, data)
     VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [userId, type, title, body || null, data ? JSON.stringify(data) : null]
  );

  await sendPushNotification(userId, title, body || '', data);

  return result.rows[0];
}

export async function findUserNotifications(
  userId: string,
  page: number = 1,
  limit: number = 20,
  unreadOnly: boolean = false
): Promise<{ notifications: Notification[]; total: number; unread_count: number }> {
  const offset = (page - 1) * limit;
  const conditions = ['user_id = $1'];
  const params: any[] = [userId];
  let paramIndex = 2;

  if (unreadOnly) {
    conditions.push(`is_read = FALSE`);
  }

  const whereClause = conditions.join(' AND ');

  const countResult = await query(
    `SELECT COUNT(*) FROM notification WHERE ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count, 10);

  const unreadResult = await query(
    `SELECT COUNT(*) FROM notification WHERE user_id = $1 AND is_read = FALSE`,
    [userId]
  );
  const unreadCount = parseInt(unreadResult.rows[0].count, 10);

  params.push(limit, offset);
  const result = await query(
    `SELECT * FROM notification WHERE ${whereClause} ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    params
  );

  return { notifications: result.rows, total, unread_count: unreadCount };
}

export async function markAsRead(notificationId: string, userId: string): Promise<boolean> {
  const result = await query(
    `UPDATE notification SET is_read = TRUE, read_at = NOW() WHERE id = $1 AND user_id = $2 RETURNING id`,
    [notificationId, userId]
  );
  return result.rows.length > 0;
}

export async function markAllAsRead(userId: string): Promise<void> {
  await query(
    `UPDATE notification SET is_read = TRUE, read_at = NOW() WHERE user_id = $1 AND is_read = FALSE`,
    [userId]
  );
}
