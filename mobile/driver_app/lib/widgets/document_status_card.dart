import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/driver_document.dart';

class DocumentStatusCard extends StatelessWidget {
  final String documentType;
  final List<DriverDocument> documents;
  final VoidCallback onUpload;

  const DocumentStatusCard({
    super.key,
    required this.documentType,
    required this.documents,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final activeDoc = documents.isNotEmpty ? documents.first : null;
    final status = activeDoc?.status ?? 'missing';
    final statusLabel = activeDoc?.statusLabel ?? 'Not uploaded';
    final isVerified = activeDoc?.isVerified ?? false;
    final isPending = activeDoc?.isPending ?? false;
    final isExpired = activeDoc?.isExpired ?? false;
    final isRejected = activeDoc?.isRejected ?? false;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'verified':
        statusColor = AppTheme.success;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppTheme.warning;
        statusIcon = Icons.access_time;
        break;
      case 'expired':
        statusColor = AppTheme.error;
        statusIcon = Icons.error;
        break;
      case 'rejected':
        statusColor = AppTheme.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.textHint;
        statusIcon = Icons.cloud_upload_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _documentIcon(documentType),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentType,
                    style:
                        AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (isExpired && activeDoc?.expiresAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Expired: ${_formatDate(activeDoc!.expiresAt!)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.error.withOpacity(0.7),
                        ),
                      ),
                    ),
                  if (isRejected && activeDoc?.rejectionReason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        activeDoc!.rejectionReason!,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.error.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (status == 'missing' || isRejected || isExpired)
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Upload', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            else if (isVerified)
              const Icon(Icons.check_circle, color: AppTheme.success, size: 24),
          ],
        ),
      ),
    );
  }

  IconData _documentIcon(String type) {
    switch (type) {
      case "Driver's License":
      case 'driver_license':
        return Icons.badge;
      case 'Vehicle Insurance':
      case 'vehicle_insurance':
        return Icons.shield;
      case 'Vehicle Registration':
      case 'vehicle_registration':
        return Icons.description;
      case 'Background Check':
      case 'background_check':
        return Icons.assignment;
      case 'Health Certificate':
      case 'health_certificate':
        return Icons.health_and_safety;
      default:
        return Icons.folder;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }
}
