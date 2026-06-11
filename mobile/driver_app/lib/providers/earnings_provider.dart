import 'package:flutter/foundation.dart';
import '../models/driver_earning.dart';
import '../services/earnings_service.dart';

enum EarningsPeriod { today, week, month }

class EarningsProvider extends ChangeNotifier {
  final EarningsService _earningsService;

  EarningsSummary? _summary;
  List<DriverEarning> _earningsHistory = [];
  List<WeeklyEarning> _weeklyChart = [];
  EarningsPeriod _selectedPeriod = EarningsPeriod.today;
  bool _isLoading = false;
  String? _error;

  EarningsProvider({required EarningsService earningsService})
      : _earningsService = earningsService;

  EarningsSummary? get summary => _summary;
  List<DriverEarning> get earningsHistory => _earningsHistory;
  List<WeeklyEarning> get weeklyChart => _weeklyChart;
  EarningsPeriod get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get todayTotal => _summary?.todayTotal ?? 0.0;
  double get todayDeliveries => (_summary?.todayDeliveries ?? 0).toDouble();
  double get weekTotal => _summary?.weekTotal ?? 0.0;
  double get monthTotal => _summary?.monthTotal ?? 0.0;

  void setPeriod(EarningsPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<void> loadSummary() async {
    _isLoading = true;
    notifyListeners();

    final result = await _earningsService.getSummary();
    if (result.success) {
      _summary = result.data;
      _error = null;
    } else {
      _error = result.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWeeklyChart() async {
    final result = await _earningsService.getWeeklyChart();
    if (result.success) {
      _weeklyChart = result.data ?? [];
      notifyListeners();
    }
  }

  Future<void> loadHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _earningsService.getHistory(
      startDate: startDate,
      endDate: endDate,
    );
    if (result.success) {
      _earningsHistory = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
