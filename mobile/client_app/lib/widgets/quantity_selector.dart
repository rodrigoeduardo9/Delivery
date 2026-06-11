import 'package:flutter/material.dart';
import '../config/theme.dart';

class QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: value > min ? () => onChanged(value - 1) : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.remove,
                size: 18,
                color: value > min ? AppTheme.textPrimary : AppTheme.textHint,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const SizedBox(minWidth: 28),
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: value < max ? () => onChanged(value + 1) : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.add,
                size: 18,
                color: value < max ? AppTheme.textPrimary : AppTheme.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
