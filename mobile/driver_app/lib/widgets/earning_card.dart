import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/formatters.dart';

class EarningCard extends StatelessWidget {
  final String title;
  final double amount;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const EarningCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppTheme.textHint,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppFormatters.currency(amount),
                style: AppTheme.amountLarge.copyWith(
                  color: color,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTheme.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTheme.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
