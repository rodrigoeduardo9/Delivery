import { logger } from '../config/logger';

let firebaseApp: any = null;

function getFirebaseApp() {
  if (firebaseApp) return firebaseApp;
  try {
    const admin = require('firebase-admin');
    const serviceAccount = process.env.FCM_SERVICE_ACCOUNT_PATH
      ? require(process.env.FCM_SERVICE_ACCOUNT_PATH)
      : null;
    if (serviceAccount) {
      firebaseApp = admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
      logger.info('Firebase initialized');
    }
  } catch (err) {
    logger.warn('Firebase not configured — push notifications disabled');
  }
  return firebaseApp;
}

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
  userId: string;
}

export async function sendPushNotification(payload: PushPayload): Promise<boolean> {
  const app = getFirebaseApp();
  if (!app) {
    logger.info(`[PUSH MOCK] To user ${payload.userId}: ${payload.title}`);
    return false;
  }
  try {
    const { query } = require('../config/database');
    const result = await query('SELECT fcm_token FROM user_account WHERE id = $1 AND fcm_token IS NOT NULL', [payload.userId]);
    if (!result.rows[0]?.fcm_token) return false;
    await app.messaging().send({
      token: result.rows[0].fcm_token,
      notification: { title: payload.title, body: payload.body },
      data: payload.data || {},
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    return true;
  } catch (err) {
    logger.error('Push notification failed:', err);
    return false;
  }
}

export async function sendPushToMultiple(userIds: string[], title: string, body: string, data?: Record<string, string>): Promise<void> {
  for (const userId of userIds) {
    await sendPushNotification({ title, body, data, userId });
  }
}
