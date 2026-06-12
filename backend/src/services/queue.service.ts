import Queue from 'bull';
import IORedis from 'ioredis';
import { logger } from '../config/logger';

function createBullRedis(): IORedis {
  return new IORedis({
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD || 'delivery_redis_pass',
    maxRetriesPerRequest: null,
    enableReadyCheck: false,
    retryStrategy: (times) => Math.min(times * 100, 3000),
  });
}

const emailQueue = new Queue('email', {
  createClient: () => createBullRedis(),
});

const pushQueue = new Queue('push', {
  createClient: () => createBullRedis(),
});

emailQueue.process(async (job) => {
  const { sendEmail } = require('./email.service');
  await sendEmail(job.data);
  logger.info(`Email job processed: ${job.id}`);
});

pushQueue.process(async (job) => {
  const { sendPushNotification } = require('./push.service');
  await sendPushNotification(job.data);
  logger.info(`Push job processed: ${job.id}`);
});

export async function queueEmail(data: { to: string; subject: string; template: string; context: any }): Promise<void> {
  await emailQueue.add(data, {
    attempts: 3,
    backoff: { type: 'exponential', delay: 2000 },
  });
}

export async function queuePush(data: { title: string; body: string; userId: string; data?: Record<string, string> }): Promise<void> {
  await pushQueue.add(data, {
    attempts: 3,
    backoff: { type: 'exponential', delay: 1000 },
  });
}

export async function closeQueues(): Promise<void> {
  await emailQueue.close();
  await pushQueue.close();
}
