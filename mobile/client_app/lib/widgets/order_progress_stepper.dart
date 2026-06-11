import 'package:flutter/material.dart';
import '../config/theme.dart';

class OrderProgressStepper extends StatelessWidget {
  final String currentStatus;

  const OrderProgressStepper({
    super.key,
    required this.currentStatus,
  });

  static const steps = [
    _StepData('Confirmed', Icons.check_circle_outline),
    _StepData('Preparing', Icons.restaurant),
    _StepData('On the way', Icons.motorcycle),
    _StepData('Delivered', Icons.home),
  ];

  int get _currentIndex {
    switch (currentStatus) {
      case 'confirmed':
        return 0;
      case 'preparing':
        return 1;
      case 'on_the_way':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) _buildStep(i),
      ],
    );
  }

  Widget _buildStep(int index) {
    final step = steps[index];
    final isCompleted = index < _currentIndex;
    final isCurrent = index == _currentIndex;
    final isFuture = index > _currentIndex;

    Color circleColor;
    Color lineColor;
    IconData icon;
    Color iconColor;

    if (isCompleted) {
      circleColor = AppTheme.success;
      lineColor = AppTheme.success;
      icon = Icons.check_circle;
      iconColor = Colors.white;
    } else if (isCurrent) {
      circleColor = AppTheme.primary;
      lineColor = AppTheme.divider;
      icon = step.icon;
      iconColor = Colors.white;
    } else {
      circleColor = AppTheme.divider;
      lineColor = AppTheme.divider;
      icon = step.icon;
      iconColor = AppTheme.textHint;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: circleColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (index < steps.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: lineColor,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: index < steps.length - 1 ? 16 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      color: isFuture ? AppTheme.textHint : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final String label;
  final IconData icon;

  const _StepData(this.label, this.icon);
}
