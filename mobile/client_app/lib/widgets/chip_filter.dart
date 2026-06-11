import 'package:flutter/material.dart';
import '../config/theme.dart';

class ChipFilter extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final String? label;

  const ChipFilter({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: selected == null,
                onSelected: (_) => onSelected(null),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected == null ? Colors.white : AppTheme.textPrimary,
                  fontSize: 13,
                ),
                backgroundColor: AppTheme.background,
                side: BorderSide.none,
              ),
              const SizedBox(width: 8),
              ...options.map((option) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onSelected(option),
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: selected == option ? Colors.white : AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  backgroundColor: AppTheme.background,
                  side: BorderSide.none,
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
