import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import * as chatbotController from './chatbot.controller';

const router = Router();

router.post('/message', authenticate, chatbotController.sendMessage);
router.get('/conversations', authenticate, chatbotController.getConversations);
router.get('/conversations/:id', authenticate, chatbotController.getConversationById);
router.delete('/conversations/:id', authenticate, chatbotController.deleteConversation);

export default router;
