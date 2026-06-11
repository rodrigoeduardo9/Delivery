import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/earnings_provider.dart';
import '../models/driver_earning.dart';
import '../widgets/earning_card.dart';
import '../widgets/earning_chart.dart';
import '../utils/formatters.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  DateTimeRange? _dateRange;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<EarningsProvider>();
      prov.loadSummary();
      prov.loadWeeklyChart();
      prov.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Consumer<EarningsProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading && prov.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await prov.loadSummary();
              await prov.loadWeeklyChart();
              await prov.loadHistory();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(prov),
                  const SizedBox(height: 12),
                  _buildSummaryCards(prov),
                  const SizedBox(height: 16),
                  _buildBreakdown(prov),
                  const SizedBox(height: 16),
                  if (prov.weeklyChart.isNotEmpty) ...[
                    _buildWeeklyChart(prov),
                    const SizedBox(height: 16),
                  ],
                  if (_showFilters) _buildDateFilter(prov),
                  _buildEarningsList(prov),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(EarningsProvider prov) {
    return Row(
      children: [
        _PeriodChip(
          label: 'Today',
          selected: prov.selectedPeriod == EarningsPeriod.today,
          onTap: () {
            prov.setPeriod(EarningsPeriod.today);
          },
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Week',
          selected: prov.selectedPeriod == EarningsPeriod.week,
          onTap: () {
            prov.setPeriod(EarningsPeriod.week);
          },
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Month',
          selected: prov.selectedPeriod == EarningsPeriod.month,
          onTap: () {
            prov.setPeriod(EarningsPeriod.month);
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCards(EarningsProvider prov) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: EarningCard(
                title: 'Today',
                amount: prov.todayTotal,
                subtitle: '${prov.summary?.todayDeliveries ?? 0} deliveries',
                icon: Icons.today,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EarningCard(
                title: 'This Week',
                amount: prov.weekTotal,
                subtitle: '${prov.summary?.weekDeliveries ?? 0} deliveries',
                icon: Icons.date_range,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        EarningCard(
          title: 'This Month',
          amount: prov.monthTotal,
          subtitle: '${prov.summary?.monthDeliveries ?? 0} deliveries',
          icon: Icons.calendar_month,
          color: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildBreakdown(EarningsProvider prov) {
    final summary = prov.summary;
    if (summary == null) return const SizedBox.shrink();

    double basePay, tips, bonuses;
    switch (prov.selectedPeriod) {
      case EarningsPeriod.today:
        basePay = summary.todayAmount;
        tips = summary.todayTips;
        bonuses = summary.todayBonus;
        break;
      case EarningsPeriod.week:
        basePay = summary.weekAmount;
        tips = summary.weekTips;
        bonuses = summary.weekBonus;
        break;
      case EarningsPeriod.month:
        basePay = summary.monthAmount;
        tips = summary.monthTips;
        bonuses = summary.monthBonus;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breakdown', style: AppTheme.heading3),
            const Divider(),
            _breakdownRow('Base Pay', basePay, Icons.receipt, AppTheme.primary),
            _breakdownRow('Tips', tips, Icons.volunteer_activism, AppTheme.accent),
            _breakdownRow('Bonuses', bonuses, Icons.celebration, AppTheme.success),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, double amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTheme.bodyText)),
          Text(
            AppFormatters.currency(amount),
            style: AppTheme.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(EarningsProvider prov) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Earnings', style: AppTheme.heading3),
            const Divider(),
            SizedBox(
              height: 160,
              child: EarningChart(data: prov.weeklyChart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter(EarningsProvider prov) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(
                  _dateRange != null
                      ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                      : 'Select dates',
                ),
              ),
            ),
            if (_dateRange != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() => _dateRange = null);
                  prov.loadHistory();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      context.read<EarningsProvider>().loadHistory(
            startDate: picked.start,
            endDate: picked.end,
          );
    }
  }

  Widget _buildEarningsList(EarningsProvider prov) {
    if (prov.earningsHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48, color: AppTheme.textHint),
                const SizedBox(height: 8),
                Text('No earnings yet', style: AppTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Earnings', style: AppTheme.heading3),
        const SizedBox(height: 8),
        ...prov.earningsHistory.map((earning) => _buildEarningItem(earning)),
      ],
    );
  }

  Widget _buildEarningItem(DriverEarning earning) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _earningColor(earning.type).withOpacity(0.2),
          child: Icon(
            _earningIcon(earning.type),
            color: _earningColor(earning.type),
            size: 20,
          ),
        ),
        title: Text(
          earning.orderNumber ?? earning.typeLabel,
          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy - HH:mm').format(earning.date),
          style: AppTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.currency(earning.total),
              style: AppTheme.bodyText.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.success,
              ),
            ),
            if (earning.tip > 0)
              Text(
                '+${AppFormatters.currency(earning.tip)} tip',
                style: AppTheme.caption.copyWith(color: AppTheme.accent),
              ),
          ],
        ),
      ),
    );
  }

  IconData _earningIcon(String type) {
    switch (type) {
      case 'delivery':
        return Icons.delivery_dining;
      case 'tip':
        return Icons.volunteer_activism;
      case 'bonus':
        return Icons.celebration;
      default:
        return Icons.receipt;
    }
  }

  Color _earningColor(String type) {
    switch (type) {
      case 'delivery':
        return AppTheme.primary;
      case 'tip':
        return AppTheme.accent;
      case 'bonus':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
