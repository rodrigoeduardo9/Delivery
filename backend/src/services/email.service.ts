import nodemailer from 'nodemailer';
import handlebars from 'handlebars';
import fs from 'fs';
import path from 'path';
import { config } from '../config';
import { logger } from '../config/logger';

let transporter: nodemailer.Transporter | null = null;

function getTransporter(): nodemailer.Transporter | null {
  if (transporter) return transporter;
  if (!config.smtp.host || !config.smtp.user) {
    logger.warn('SMTP not configured — emails will not be sent');
    return null;
  }
  transporter = nodemailer.createTransport({
    host: config.smtp.host,
    port: config.smtp.port,
    secure: config.smtp.port === 465,
    auth: {
      user: config.smtp.user,
      pass: config.smtp.pass,
    },
  });
  return transporter;
}

function loadTemplate(templateName: string): HandlebarsTemplateDelegate {
  const templatePath = path.resolve(__dirname, '../../templates', `${templateName}.hbs`);
  if (!fs.existsSync(templatePath)) {
    logger.warn(`Email template not found: ${templatePath}`);
    return () => '';
  }
  const source = fs.readFileSync(templatePath, 'utf-8');
  return handlebars.compile(source);
}

interface SendEmailParams {
  to: string;
  subject: string;
  template: string;
  context: Record<string, any>;
}

export async function sendEmail(params: SendEmailParams): Promise<boolean> {
  const t = getTransporter();
  if (!t) {
    logger.info(`[EMAIL MOCK] To: ${params.to}, Subject: ${params.subject}, Template: ${params.template}`);
    return false;
  }
  try {
    const html = loadTemplate(params.template)(params.context);
    await t.sendMail({
      from: `"${config.smtp.user}" <${config.smtp.user}>`,
      to: params.to,
      subject: params.subject,
      html,
    });
    logger.info(`Email sent to ${params.to}: ${params.subject}`);
    return true;
  } catch (err) {
    logger.error(`Failed to send email to ${params.to}:`, err);
    return false;
  }
}

export async function sendWelcomeEmail(email: string, name: string, verificationToken: string): Promise<boolean> {
  const baseUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
  return sendEmail({
    to: email,
    subject: 'Welcome to Delivery Platform!',
    template: 'welcome',
    context: {
      name,
      verificationLink: `${baseUrl}/verify-email?token=${verificationToken}`,
    },
  });
}

export async function sendPasswordResetEmail(email: string, name: string, resetToken: string): Promise<boolean> {
  const baseUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
  return sendEmail({
    to: email,
    subject: 'Reset your password',
    template: 'reset-password',
    context: {
      name,
      resetLink: `${baseUrl}/reset-password?token=${resetToken}`,
    },
  });
}

export async function sendOrderConfirmationEmail(
  email: string,
  name: string,
  orderNumber: string,
  items: Array<{ name: string; quantity: number; price: number }>,
  total: number
): Promise<boolean> {
  return sendEmail({
    to: email,
    subject: `Order #${orderNumber} confirmed`,
    template: 'order-confirmation',
    context: {
      name,
      orderNumber,
      items,
      total: `$${total.toFixed(2)}`,
    },
  });
}
