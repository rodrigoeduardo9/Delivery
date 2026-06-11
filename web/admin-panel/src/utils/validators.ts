import { z } from 'zod';

export const emailSchema = z.string().email('Invalid email address');

export const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
  .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
  .regex(/[0-9]/, 'Password must contain at least one number');

export const phoneSchema = z
  .string()
  .regex(/^(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}$/, 'Invalid phone number');

export const urlSchema = z.string().url('Invalid URL');

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, 'Password is required'),
});

export const commissionSchema = z.object({
  commission_rate: z
    .number()
    .min(0, 'Commission must be at least 0')
    .max(100, 'Commission cannot exceed 100'),
});

export const settingsSchema = z.object({
  platform_name: z.string().min(1, 'Platform name is required'),
  support_email: emailSchema,
  default_currency: z.string().length(3, 'Currency code must be 3 characters'),
  default_commission_rate: z.number().min(0).max(100),
  base_delivery_fee: z.number().min(0),
  per_km_rate: z.number().min(0),
  free_delivery_threshold: z.number().min(0).optional(),
  session_timeout_minutes: z.number().min(1).max(1440),
  min_payout_amount: z.number().min(0),
});

export type LoginFormData = z.infer<typeof loginSchema>;
export type SettingsFormData = z.infer<typeof settingsSchema>;
