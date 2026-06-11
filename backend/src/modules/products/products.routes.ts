import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as productsController from './products.controller';
import { updateProductValidation, variantValidation, extraValidation } from './products.validation';

const router = Router();

router.get('/', productsController.getProducts);
router.get('/:id', productsController.getProductById);
router.put('/:id', authenticate, validate(updateProductValidation), productsController.updateProduct);
router.put('/:id/variants', authenticate, validate(variantValidation), productsController.updateVariants);
router.put('/:id/extras', authenticate, validate(extraValidation), productsController.updateExtras);

export default router;
