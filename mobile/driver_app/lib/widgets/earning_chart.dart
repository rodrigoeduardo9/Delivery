import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/driver_earning.dart';

class EarningChart extends StatelessWidget {
  final List<WeeklyEarning> data;

  const EarningChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available', style: AppTheme.bodySmall),
      );
    }

    final maxAmount = data.fold<double>(
        0, (max, e) => e.amount > max ? e.amount : max);
    final barMax = maxAmount > 0 ? maxAmount * 1.2 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (index) {
              final item = data[index];
              final height = barMax > 0 ? item.amount / barMax : 0.0;
              final isToday = _isToday(item.date);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (item.amount > 0)
                        Text(
                          '\$${item.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isToday ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        height: height * 120,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.primaryLight.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: data.map((item) {
            final isToday = _isToday(item.date);
            return Expanded(
              child: Text(
                DateFormat('E').format(item.date).substring(0, 3),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  color: isToday ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
