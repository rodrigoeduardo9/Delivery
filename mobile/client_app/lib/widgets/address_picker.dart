import 'package:flutter/material.dart';
import '../config/theme.dart';

class AddressPickerDialog extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const AddressPickerDialog({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<AddressPickerDialog> createState() => _AddressPickerDialogState();
}

class _AddressPickerDialogState extends State<AddressPickerDialog> {
  double? _selectedLat;
  double? _selectedLng;
  final _aliasController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _colonyController = TextEditingController();
  final _referenceController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.initialLatitude;
    _selectedLng = widget.initialLongitude;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _colonyController.dispose();
    _referenceController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _aliasController,
              decoration: const InputDecoration(labelText: 'Alias (Home, Work, etc.)', hintText: 'e.g. Home'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Street *', hintText: 'Street name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: 'Number', hintText: '123'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _colonyController,
                    decoration: const InputDecoration(labelText: 'Colony', hintText: 'Colony name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City', hintText: 'City'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(labelText: 'State', hintText: 'State'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _zipController,
              decoration: const InputDecoration(labelText: 'ZIP Code', hintText: '12345'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(labelText: 'Reference', hintText: 'Near the park, etc.'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, size: 48, color: AppTheme.textHint),
                    SizedBox(height: 8),
                    Text('Map will be displayed here', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'alias': _aliasController.text,
                    'street': _streetController.text,
                    'number': _numberController.text,
                    'colony': _colonyController.text,
                    'city': _cityController.text,
                    'state': _stateController.text,
                    'zip_code': _zipController.text,
                    'reference': _referenceController.text,
                    'latitude': _selectedLat ?? widget.initialLatitude,
                    'longitude': _selectedLng ?? widget.initialLongitude,
                  });
                },
                child: const Text('Save Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
