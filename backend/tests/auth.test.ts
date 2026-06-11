import request from 'supertest';
import app from '../src/app';

describe('Auth Endpoints', () => {
  describe('POST /api/v1/auth/register', () => {
    it('should return 422 for invalid data', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({ email: 'invalid' });

      expect(res.status).toBe(422);
      expect(res.body.success).toBe(false);
    });

    it('should return 422 for missing password', async () => {
      const res = await request(app)
        .post('/api/v1/auth/register')
        .send({
          email: 'test@example.com',
          password: 'short',
          first_name: 'Test',
          last_name: 'User',
        });

      expect(res.status).toBe(422);
    });
  });

  describe('POST /api/v1/auth/login', () => {
    it('should return 422 for empty body', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({});

      expect(res.status).toBe(422);
    });

    it('should return 422 for missing password', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({ email: 'test@example.com' });

      expect(res.status).toBe(422);
    });
  });

  describe('POST /api/v1/auth/refresh', () => {
    it('should return 400 for missing token', async () => {
      const res = await request(app)
        .post('/api/v1/auth/refresh')
        .send({});

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/auth/me', () => {
    it('should return 401 without token', async () => {
      const res = await request(app)
        .get('/api/v1/auth/me');

      expect(res.status).toBe(401);
    });

    it('should return 401 with invalid token', async () => {
      const res = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', 'Bearer invalid-token');

      expect(res.status).toBe(401);
    });
  });

  describe('POST /api/v1/auth/forgot-password', () => {
    it('should return 422 for invalid email', async () => {
      const res = await request(app)
        .post('/api/v1/auth/forgot-password')
        .send({ email: 'not-an-email' });

      expect(res.status).toBe(422);
    });
  });

  describe('Health Check', () => {
    it('should return 200 for health endpoint', async () => {
      const res = await request(app).get('/api/v1/health');

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toContain('Delivery Platform API');
    });
  });
});
