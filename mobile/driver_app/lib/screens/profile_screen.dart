import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../models/driver_document.dart';
import '../widgets/document_status_card.dart';
import '../utils/formatters.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isEditing = false;
  String? _selectedVehicleType;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (_, authProv, __) {
          final profile = authProv.driverProfile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_isEditing) {
            _nameController.text = profile.name;
            _phoneController.text = profile.phone ?? '';
          }

          return RefreshIndicator(
            onRefresh: () => authProv.loadDriverProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(authProv),
                  const SizedBox(height: 16),
                  _buildStatsCards(authProv),
                  const SizedBox(height: 16),
                  if (!_isEditing) ...[
                    _buildVehicleInfo(authProv),
                    const SizedBox(height: 16),
                    _buildDocumentsSection(authProv),
                    const SizedBox(height: 16),
                    _buildSettingsSection(),
                    const SizedBox(height: 16),
                    _buildLogoutButton(authProv),
                  ] else
                    _buildEditForm(authProv),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProv) {
    final profile = authProv.driverProfile!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? () => _pickImage(authProv) : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? Text(
                            profile.name.isNotEmpty
                                ? profile.name[0].toUpperCase()
                                : 'D',
                            style: const TextStyle(
                                fontSize: 32, color: AppTheme.primary),
                          )
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 16, color: AppTheme.accent),
                const SizedBox(width: 4),
                Text(
                  '${profile.rating.toStringAsFixed(1)}',
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              profile.memberSince != null
                  ? 'Member since ${DateFormat('MMMM yyyy').format(profile.memberSince!)}'
                  : 'Driver',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(AuthProvider authProv) {
    final profile = authProv.driverProfile!;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.delivery_dining,
            label: 'Deliveries',
            value: '${profile.totalDeliveries}',
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.attach_money,
            label: 'Earnings',
            value: AppFormatters.currency(profile.totalEarnings),
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            label: 'On-Time',
            value: '${profile.onTimeRate}%',
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            label: 'Accepted',
            value: '${profile.acceptanceRate}%',
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfo(AuthProvider authProv) {
    final profile = authProv.driverProfile!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.secondaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                profile.vehicleType == 'Motorcycle'
                    ? Icons.motorcycle
                    : profile.vehicleType == 'Bicycle'
                        ? Icons.pedal_bike
                        : Icons.directions_car,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle', style: AppTheme.bodySmall),
                  Text(
                    profile.vehicleType,
                    style:
                        AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (profile.vehiclePlate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile.vehiclePlate!,
                  style: AppTheme.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(AuthProvider authProv) {
    final documents = authProv.documents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Documents', style: AppTheme.heading3),
            TextButton.icon(
              onPressed: () => _addDocument(authProv),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Upload'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...AppConstants.documentTypes.map((docType) {
          final existingDoc = documents.where((d) => d.typeLabel == docType).toList();
          return DocumentStatusCard(
            documentType: docType,
            documents: existingDoc,
            onUpload: () => _addDocument(authProv, type: docType),
          );
        }),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive order alerts'),
            value: true,
            activeColor: AppTheme.primary,
            onChanged: (val) {},
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Sound Alerts'),
            subtitle: const Text('Play sound on new orders'),
            value: true,
            activeColor: AppTheme.primary,
            onChanged: (val) {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language, color: AppTheme.textSecondary),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.headset_mic, color: AppTheme.textSecondary),
            title: const Text('Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support contact: support@delivery.com')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(AuthProvider authProv) {
    final profile = authProv.driverProfile!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: AppTheme.heading3),
            const Divider(),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedVehicleType ?? profile.vehicleType,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: AppConstants.vehicleTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedVehicleType = val);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveProfile(authProv),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProv) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(authProv),
        icon: const Icon(Icons.logout, color: AppTheme.error),
        label: const Text(
          'Logout',
          style: TextStyle(color: AppTheme.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _pickImage(AuthProvider authProv) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _addDocument(AuthProvider authProv, {String? type}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (image != null) {
        final docType = type ?? 'driver_license';
        final success = await authProv.submitDocument(image.path, docType);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Document submitted' : 'Failed to submit'),
              backgroundColor: success ? AppTheme.success : AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile(AuthProvider authProv) async {
    final success = await authProv.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      vehicleType: _selectedVehicleType,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated' : 'Failed to update'),
          backgroundColor: success ? AppTheme.success : AppTheme.error,
        ),
      );
      if (success) {
        setState(() => _isEditing = false);
      }
    }
  }

  void _confirmLogout(AuthProvider authProv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              authProv.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
