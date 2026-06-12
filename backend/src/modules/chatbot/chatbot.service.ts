import OpenAI from 'openai';
import { config } from '../../config';
import { query } from '../../config/database';
import { logger } from '../../config/logger';

let openai: OpenAI | null = null;

function getOpenAI(): OpenAI {
  if (!openai) {
    openai = new OpenAI({ apiKey: config.openai.apiKey });
  }
  return openai;
}

const SYSTEM_PROMPT = `You are a helpful customer support assistant for a food delivery platform called "DeliveryApp".
Your capabilities:
1. Help customers find restaurants and menu items
2. Provide order status updates
3. Answer FAQs about delivery, payments, and policies
4. Help with common issues

Keep responses concise and friendly. If you need specific order or restaurant information,
ask for the order ID or restaurant name. If you cannot help, offer to connect the user
with human support.

Available tools:
- get_order_status: Get the status of an order by ID
- search_restaurants: Find restaurants by name, cuisine, or location
- get_restaurant_info: Get details about a specific restaurant
- get_product_info: Get details about a specific product
- get_faq: Answer common questions

Today's date: ${new Date().toLocaleDateString()}`;

interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

async function getOrderStatus(orderId: string): Promise<string> {
  const result = await query(
    `SELECT o.status, o.order_number, o.total, o.created_at, r.name as restaurant_name
     FROM orders o JOIN restaurant r ON o.restaurant_id = r.id
     WHERE o.id = $1`,
    [orderId]
  );
  if (result.rows.length === 0) return 'Order not found.';
  const o = result.rows[0];
  return `Order #${o.order_number} from ${o.restaurant_name} is currently: ${o.status}. Total: $${o.total}. Created: ${new Date(o.created_at).toLocaleString()}`;
}

async function searchRestaurants(searchTerm: string): Promise<string> {
  const result = await query(
    `SELECT name, slug, city, rating, delivery_fee FROM restaurant
     WHERE is_active = TRUE AND is_deleted = FALSE AND (name ILIKE $1 OR description ILIKE $1)
     LIMIT 5`,
    [`%${searchTerm}%`]
  );
  if (result.rows.length === 0) return 'No restaurants found.';
  return result.rows.map((r: any) =>
    `• ${r.name} - ${r.city} (Rating: ${r.rating || 'N/A'}, Delivery fee: $${r.delivery_fee})`
  ).join('\n');
}

async function getRestaurantInfo(restaurantId: string): Promise<string> {
  const result = await query(
    `SELECT r.name, r.description, r.city, r.address, r.phone, r.rating,
            r.delivery_fee, r.minimum_order, r.is_active, r.created_at,
            json_agg(json_build_object('name', p.name, 'price', p.price, 'category', p.category)) as products
     FROM restaurant r
     LEFT JOIN product p ON p.restaurant_id = r.id AND p.is_deleted = FALSE
     WHERE r.id = $1 AND r.is_deleted = FALSE
     GROUP BY r.id`,
    [restaurantId]
  );
  if (result.rows.length === 0) return 'Restaurant not found.';
  const r = result.rows[0];
  let reply = `📍 *${r.name}*\n${r.description || ''}\n${r.address}, ${r.city}\nPhone: ${r.phone || 'N/A'} | Rating: ${r.rating || 'N/A'} | Delivery fee: $${r.delivery_fee} | Min order: $${r.minimum_order}`;
  if (r.products?.length) {
    const grouped: Record<string, any[]> = {};
    for (const p of r.products) {
      if (!p.name) continue;
      const cat = p.category || 'General';
      if (!grouped[cat]) grouped[cat] = [];
      grouped[cat].push(p);
    }
    reply += '\n\n📋 Menu:';
    for (const [cat, items] of Object.entries(grouped)) {
      reply += `\n  *${cat}*: `;
      reply += items.map((p: any) => `${p.name} ($${p.price})`).join(', ');
    }
  }
  return reply;
}

async function getProductInfo(productId: string): Promise<string> {
  const result = await query(
    `SELECT p.name, p.description, p.price, p.category, p.image_url, p.is_available, r.name as restaurant_name
     FROM product p JOIN restaurant r ON p.restaurant_id = r.id
     WHERE p.id = $1 AND p.is_deleted = FALSE`,
    [productId]
  );
  if (result.rows.length === 0) return 'Product not found.';
  const p = result.rows[0];
  return `🍽 *${p.name}*\n${p.description || 'No description'}\nPrice: $${p.price} | Category: ${p.category || 'General'}\nRestaurant: ${p.restaurant_name} | Available: ${p.is_available ? 'Yes' : 'No'}`;
}

async function executeToolCall(toolName: string, args: any): Promise<string> {
  switch (toolName) {
    case 'get_order_status':
      return getOrderStatus(args.order_id);
    case 'search_restaurants':
      return searchRestaurants(args.search_term);
    case 'get_restaurant_info':
      return getRestaurantInfo(args.restaurant_id);
    case 'get_product_info':
      return getProductInfo(args.product_id);
    default:
      return `Unknown tool: ${toolName}`;
  }
}

export async function processMessage(
  message: string,
  conversationHistory: ChatMessage[] = []
): Promise<{ reply: string; conversation_id?: string }> {
  try {
    const client = getOpenAI();

    const messages: ChatMessage[] = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...conversationHistory.slice(-10),
      { role: 'user', content: message },
    ];

    const response = await client.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages,
      temperature: 0.7,
      max_tokens: 500,
      functions: [
        {
          name: 'get_order_status',
          description: 'Get the status of a delivery order',
          parameters: {
            type: 'object',
            properties: { order_id: { type: 'string', description: 'Order UUID' } },
            required: ['order_id'],
          },
        },
        {
          name: 'search_restaurants',
          description: 'Search for restaurants by name or cuisine',
          parameters: {
            type: 'object',
            properties: { search_term: { type: 'string', description: 'Search term for restaurant name or cuisine' } },
            required: ['search_term'],
          },
        },
        {
          name: 'get_restaurant_info',
          description: 'Get full details about a specific restaurant including its menu',
          parameters: {
            type: 'object',
            properties: { restaurant_id: { type: 'string', description: 'Restaurant UUID' } },
            required: ['restaurant_id'],
          },
        },
        {
          name: 'get_product_info',
          description: 'Get details about a specific product/menu item',
          parameters: {
            type: 'object',
            properties: { product_id: { type: 'string', description: 'Product UUID' } },
            required: ['product_id'],
          },
        },
      ],
      function_call: 'auto',
    });

    const responseMessage = response.choices[0]?.message;

    if (responseMessage?.function_call) {
      const { name, arguments: args } = responseMessage.function_call;
      const parsedArgs = JSON.parse(args || '{}');
      const toolResult = await executeToolCall(name, parsedArgs);

      const secondResponse = await client.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          ...messages,
          responseMessage,
          {
            role: 'function',
            name,
            content: toolResult,
          },
        ],
        temperature: 0.7,
        max_tokens: 300,
      });

      return { reply: secondResponse.choices[0]?.message?.content || 'I could not process your request.' };
    }

    return { reply: responseMessage?.content || 'I could not process your request.' };
  } catch (error: any) {
    logger.error('Chatbot error:', error);
    return { reply: 'Sorry, I encountered an error. Please try again or contact support.' };
  }
}
