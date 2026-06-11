import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_shimmer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(user, auth),
              const SizedBox(height: 24),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'My Addresses',
                onTap: () => Navigator.of(context).pushNamed('/addresses'),
              ),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.favorite_outline,
                title: 'Favorites',
                onTap: () => Navigator.of(context).pushNamed('/favorites'),
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => Navigator.of(context).pushNamed('/notifications'),
              ),
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Order History',
                onTap: () => Navigator.of(context).pushNamed('/order-history'),
              ),
              const Divider(height: 32),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.smart_toy_outlined,
                title: 'Chatbot',
                onTap: () => Navigator.of(context).pushNamed('/chatbot'),
                showBadge: true,
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'FoodDelivery',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
              const Divider(height: 32),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () => _logout(context),
                isDestructive: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user, AuthProvider auth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _pickImage(auth),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.divider,
                    child: user.avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: CachedNetworkImage(
                              imageUrl: user.avatarUrl!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const ShimmerWidget(width: 72, height: 72, borderRadius: 36),
                              errorWidget: (_, __, ___) => const Icon(Icons.person, size: 36, color: AppTheme.textHint),
                            ),
                          )
                        : const Icon(Icons.person, size: 36, color: AppTheme.textHint),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  if (user.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(user.phone!, style: const TextStyle(fontSize: 13, color: AppTheme.textHint)),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editProfile(context, auth),
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showBadge = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.error : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: showBadge
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          : const Icon(Icons.chevron_right, color: AppTheme.textHint),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(AuthProvider auth) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload and update avatar
      // auth.updateAvatar(uploadedUrl);
    }
  }

  void _editProfile(BuildContext context, AuthProvider auth) {
    final nameController = TextEditingController(text: auth.user?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
