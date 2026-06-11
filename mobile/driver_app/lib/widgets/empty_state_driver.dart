import 'package:flutter/material.dart';
import '../config/theme.dart';

class EmptyStateDriver extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? child;

  const EmptyStateDriver({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = 'Nothing here',
    this.subtitle = '',
    this.actionLabel,
    this.onAction,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.textHint.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppTheme.textHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTheme.heading2.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: 16),
              child!,
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
