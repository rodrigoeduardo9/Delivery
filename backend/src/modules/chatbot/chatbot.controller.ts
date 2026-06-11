import { Request, Response } from 'express';
import { successResponse, errorResponse } from '../../shared/response';
import { catchAsync } from '../../middleware/errorHandler';
import { query } from '../../config/database';
import * as chatbotService from './chatbot.service';

export const sendMessage = catchAsync(async (req: Request, res: Response) => {
  const { message, conversation_id } = req.body;

  if (!message || message.trim().length === 0) {
    return errorResponse(res, 'Message is required', 400);
  }

  let conversationHistory: any[] = [];

  if (conversation_id) {
    const historyResult = await query(
      `SELECT sender_id, content, message_type FROM chat_message
       WHERE conversation_id = $1 ORDER BY created_at ASC LIMIT 20`,
      [conversation_id]
    );
    conversationHistory = historyResult.rows.map((m: any) => ({
      role: m.sender_id === req.user?.userId ? 'user' : 'assistant',
      content: m.content,
    }));
  }

  const result = await chatbotService.processMessage(message, conversationHistory);

  if (req.user && conversation_id) {
    await query(
      `INSERT INTO chat_message (conversation_id, sender_id, content) VALUES ($1, $2, $3)`,
      [conversation_id, req.user.userId, message]
    );
  }

  return successResponse(res, {
    reply: result.reply,
    conversation_id: conversation_id || result.conversation_id,
  });
});

export const getConversations = catchAsync(async (req: Request, res: Response) => {
  const result = await query(
    `SELECT * FROM chat_conversation WHERE customer_id = $1 ORDER BY updated_at DESC`,
    [req.user!.userId]
  );
  return successResponse(res, result.rows);
});

export const getConversationById = catchAsync(async (req: Request, res: Response) => {
  const conversation = await query(
    `SELECT * FROM chat_conversation WHERE id = $1`,
    [req.params.id]
  );
  if (conversation.rows.length === 0) {
    return errorResponse(res, 'Conversation not found', 404);
  }

  const messages = await query(
    `SELECT cm.*, ua.first_name, ua.last_name FROM chat_message cm
     LEFT JOIN user_account ua ON cm.sender_id = ua.id
     WHERE cm.conversation_id = $1 ORDER BY cm.created_at ASC`,
    [req.params.id]
  );

  return successResponse(res, { ...conversation.rows[0], messages: messages.rows });
});

export const deleteConversation = catchAsync(async (req: Request, res: Response) => {
  const result = await query(
    `DELETE FROM chat_conversation WHERE id = $1 AND customer_id = $2 RETURNING id`,
    [req.params.id, req.user!.userId]
  );
  if (result.rows.length === 0) {
    return errorResponse(res, 'Conversation not found', 404);
  }
  return successResponse(res, null, 200, 'Conversation deleted');
});
