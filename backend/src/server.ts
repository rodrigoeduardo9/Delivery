import app from './app';
import { config } from './config';
import { logger } from './config/logger';
import { getRedis, closeRedis } from './config/redis';
import { setupWebSocket, closeWebSocket } from './services/websocket.service';

const server = app.listen(config.port, () => {
  logger.info(`Server running on port ${config.port} in ${config.nodeEnv} mode`);
  logger.info(`Health check: http://localhost:${config.port}/api/v1/health`);

  try {
    setupWebSocket(server);
  } catch (err) {
    logger.warn('WebSocket setup failed (Redis may be unavailable):', err);
  }

  try {
    getRedis();
  } catch (err) {
    logger.warn('Redis setup failed (Redis may be unavailable):', err);
  }
});

const gracefulShutdown = async (signal: string) => {
  logger.info(`${signal} received. Shutting down gracefully...`);

  await closeWebSocket();
  await closeRedis();

  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });

  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10000).unref();
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

process.on('unhandledRejection', (reason: any) => {
  logger.error('Unhandled Rejection:', reason);
});

process.on('uncaughtException', (error: Error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

export default server;
