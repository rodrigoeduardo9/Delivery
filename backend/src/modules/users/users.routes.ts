import { Router } from 'express';
import { authenticate, roleCheck } from '../../middleware/auth';
import { validate } from '../../middleware/validate';
import * as usersController from './users.controller';
import { updateUserValidation, createAddressValidation } from './users.validation';

const router = Router();

router.get('/', authenticate, roleCheck('admin'), usersController.getUsers);
router.post('/me/avatar', authenticate, usersController.uploadUserAvatar);
router.get('/me/addresses', authenticate, usersController.getMyAddresses);
router.post('/me/addresses', authenticate, validate(createAddressValidation), usersController.createAddress);
router.put('/me/addresses/:id', authenticate, validate(createAddressValidation), usersController.updateAddress);
router.delete('/me/addresses/:id', authenticate, usersController.deleteAddress);
router.get('/:id', authenticate, usersController.getUserById);
router.put('/:id', authenticate, validate(updateUserValidation), usersController.updateUser);
router.delete('/:id', authenticate, roleCheck('admin'), usersController.deleteUser);
router.put('/:id/role', authenticate, roleCheck('admin'), usersController.changeRole);
router.put('/:id/status', authenticate, roleCheck('admin'), usersController.toggleStatus);

export default router;
