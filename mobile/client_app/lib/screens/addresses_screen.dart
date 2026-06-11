import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/location_provider.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/address_picker.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: Consumer<LocationProvider>(
        builder: (context, location, _) {
          if (location.isLoading) {
            return const LoadingShimmerList();
          }

          final addresses = location.savedAddresses;
          if (addresses.isEmpty) {
            return const EmptyState(
              icon: Icons.location_on_outlined,
              title: 'No addresses saved',
              subtitle: 'Add a delivery address to get started',
              actionLabel: 'Add Address',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length + 1,
            itemBuilder: (_, index) {
              if (index == addresses.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _addAddress(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                  ),
                );
              }

              final addr = addresses[index];
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: addr.isDefault
                          ? AppTheme.primary.withOpacity(0.1)
                          : AppTheme.divider,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: addr.isDefault ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        addr.alias,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (addr.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    addr.fullAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Address'),
                            content: Text('Delete "${addr.alias}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && addr.id != null) {
                          location.deleteAddress(addr.id!);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () => location.selectAddress(addr),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addAddress(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddressPickerDialog(
        initialLatitude: 19.4326,
        initialLongitude: -99.1332,
      ),
    );

    if (result != null && context.mounted) {
      final location = context.read<LocationProvider>();
      final address = Address(
        alias: result['alias'] as String? ?? '',
        street: result['street'] as String? ?? '',
        number: result['number'] as String?,
        colony: result['colony'] as String?,
        city: result['city'] as String?,
        state: result['state'] as String?,
        zipCode: result['zip_code'] as String?,
        reference: result['reference'] as String?,
        latitude: result['latitude'] as double? ?? 0.0,
        longitude: result['longitude'] as double? ?? 0.0,
      );
      await location.addAddress(address);
    }
  }
}
