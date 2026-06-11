import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import cookieParser from 'cookie-parser';
import { config } from './config';
import { generalLimiter } from './middleware/rateLimiter';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './config/logger';

import authRoutes from './modules/auth/auth.routes';
import usersRoutes from './modules/users/users.routes';
import restaurantsRoutes from './modules/restaurants/restaurants.routes';
import productsRoutes from './modules/products/products.routes';
import ordersRoutes from './modules/orders/orders.routes';
import paymentsRoutes from './modules/payments/payments.routes';
import driversRoutes from './modules/drivers/drivers.routes';
import routesRoutes from './modules/routes/routes.routes';
import notificationsRoutes from './modules/notifications/notifications.routes';
import chatbotRoutes from './modules/chatbot/chatbot.routes';
import reportsRoutes from './modules/reports/reports.routes';

const app = express();

app.use(helmet());
app.use(cors({
  origin: config.corsOrigin,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(compression());
app.use(cookieParser());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

if (config.nodeEnv === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined', {
    stream: { write: (message: string) => logger.info(message.trim()) },
  }));
}

app.use(generalLimiter);

app.get('/api/v1/health', (req, res) => {
  res.json({
    success: true,
    message: 'Delivery Platform API is running',
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
  });
});

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', usersRoutes);
app.use('/api/v1/restaurants', restaurantsRoutes);
app.use('/api/v1/products', productsRoutes);
app.use('/api/v1/orders', ordersRoutes);
app.use('/api/v1/payments', paymentsRoutes);
app.use('/api/v1/drivers', driversRoutes);
app.use('/api/v1/routes', routesRoutes);
app.use('/api/v1/notifications', notificationsRoutes);
app.use('/api/v1/chatbot', chatbotRoutes);
app.use('/api/v1/reports', reportsRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.path} not found`,
  });
});

app.use(errorHandler);

export default app;
