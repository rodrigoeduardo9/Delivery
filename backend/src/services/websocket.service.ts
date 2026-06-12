import { Server as HTTPServer } from 'http';
import { Server, Socket } from 'socket.io';
import { verifyAccessToken } from '../modules/auth/auth.service';
import { getRedis } from '../config/redis';
import { logger } from '../config/logger';

let io: Server | null = null;

export function getIO(): Server {
  if (!io) throw new Error('Socket.IO not initialized');
  return io;
}

export function setupWebSocket(httpServer: HTTPServer): Server {
  io = new Server(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
      credentials: true,
    },
    transports: ['websocket', 'polling'],
    pingInterval: 10000,
    pingTimeout: 5000,
  });

  const redis = getRedis();

  io.use(async (socket, next) => {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) {
      return next(new Error('Authentication required'));
    }
    try {
      const decoded = verifyAccessToken(token as string);
      (socket as any).user = decoded;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket: Socket) => {
    const user = (socket as any).user;
    logger.info(`WebSocket connected: user=${user.userId} role=${user.role}`);

    socket.join(`user:${user.userId}`);

    if (user.role === 'driver') {
      socket.join('drivers');
    }

    socket.on('join_order', (orderId: string) => {
      socket.join(`order:${orderId}`);
    });

    socket.on('leave_order', (orderId: string) => {
      socket.leave(`order:${orderId}`);
    });

    socket.on('driver:location', async (data: { latitude: number; longitude: number; orderId?: string }) => {
      socket.broadcast.to(`order:${data.orderId}`).emit('driver:location_update', {
        driverId: user.userId,
        latitude: data.latitude,
        longitude: data.longitude,
        timestamp: new Date().toISOString(),
      });

      if (redis) {
        const key = `driver:location:${user.userId}`;
        await redis.setex(key, 30, JSON.stringify(data));
      }
    });

    socket.on('disconnect', () => {
      logger.info(`WebSocket disconnected: user=${user.userId}`);
    });
  });

  logger.info('WebSocket server initialized');
  return io;
}

export function emitOrderEvent(orderId: string, event: string, data: any): void {
  if (!io) return;
  io.to(`order:${orderId}`).emit(event, data);
  io.to(`user:${data.customerId}`).emit('notification', {
    type: 'order_update',
    title: 'Order update',
    body: data.message || '',
    orderId,
  });
}

export async function closeWebSocket(): Promise<void> {
  if (io) {
    await io.close();
    io = null;
  }
}
