import { query } from '../../config/database';
import { Product, ProductVariant, ProductExtra } from '../../shared/interfaces';

export async function findProductById(id: string): Promise<Product | null> {
  const result = await query(
    `SELECT * FROM product WHERE id = $1 AND is_deleted = FALSE`,
    [id]
  );
  return result.rows[0] || null;
}

export async function findProducts(
  page: number = 1,
  limit: number = 20,
  restaurantId?: string,
  category?: string
): Promise<{ products: Product[]; total: number }> {
  const offset = (page - 1) * limit;
  const conditions: string[] = ['is_deleted = FALSE'];
  const params: any[] = [];
  let paramIndex = 1;

  if (restaurantId) {
    conditions.push(`restaurant_id = $${paramIndex++}`);
    params.push(restaurantId);
  }

  if (category) {
    conditions.push(`category = $${paramIndex++}`);
    params.push(category);
  }

  const whereClause = conditions.join(' AND ');

  const countResult = await query(`SELECT COUNT(*) FROM product WHERE ${whereClause}`, params);
  const total = parseInt(countResult.rows[0].count, 10);

  params.push(limit, offset);
  const result = await query(
    `SELECT * FROM product WHERE ${whereClause} ORDER BY sort_order ASC, name ASC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    params
  );

  return { products: result.rows, total };
}

export async function getProductWithDetails(id: string): Promise<any> {
  const product = await findProductById(id);
  if (!product) return null;

  const variants = await query(
    `SELECT * FROM product_variant WHERE product_id = $1 ORDER BY sort_order ASC`,
    [id]
  );

  const extras = await query(
    `SELECT * FROM product_extra WHERE product_id = $1 ORDER BY sort_order ASC`,
    [id]
  );

  return { ...product, variants: variants.rows, extras: extras.rows };
}

export async function updateProduct(id: string, data: any): Promise<Product | null> {
  const fields: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;
  const allowedFields = [
    'name', 'description', 'price', 'discounted_price', 'image_url',
    'category', 'is_available', 'is_featured', 'stock', 'preparation_time_min', 'sort_order',
  ];

  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      fields.push(`${key} = $${paramIndex++}`);
      params.push(data[key]);
    }
  }

  if (fields.length === 0) return findProductById(id);

  params.push(id);
  const result = await query(
    `UPDATE product SET ${fields.join(', ')} WHERE id = $${paramIndex} AND is_deleted = FALSE RETURNING *`,
    params
  );
  return result.rows[0] || null;
}

export async function updateVariants(productId: string, variants: any[]): Promise<ProductVariant[]> {
  await query(`DELETE FROM product_variant WHERE product_id = $1`, [productId]);

  const results: ProductVariant[] = [];
  for (let i = 0; i < variants.length; i++) {
    const v = variants[i];
    const result = await query(
      `INSERT INTO product_variant (product_id, name, price_adjustment, is_available, sort_order)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [productId, v.name, v.price_adjustment || 0, v.is_available !== false, i]
    );
    results.push(result.rows[0]);
  }
  return results;
}

export async function updateExtras(productId: string, extras: any[]): Promise<ProductExtra[]> {
  await query(`DELETE FROM product_extra WHERE product_id = $1`, [productId]);

  const results: ProductExtra[] = [];
  for (let i = 0; i < extras.length; i++) {
    const e = extras[i];
    const result = await query(
      `INSERT INTO product_extra (product_id, name, price, is_available, max_quantity, sort_order)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [productId, e.name, e.price, e.is_available !== false, e.max_quantity || 5, i]
    );
    results.push(result.rows[0]);
  }
  return results;
}
