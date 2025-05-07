import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/market_index.dart';
import '../../data/datasources/remote/market_index_service.dart';

class IndexProvider with ChangeNotifier {
  final MarketIndexService _marketIndexService = MarketIndexService();

  List<MarketIndex> _indices = [];
  bool _isLoading = false;
  DateTime? _lastUpdated;

  List<MarketIndex> get indices => _indices;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;

  // Refresh interval in seconds (default 60s = 1min)
  int _refreshInterval = 60;
  Timer? _refreshTimer;

  IndexProvider() {
    // Set up auto-refresh initially
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    // Cancel existing timer if any
    _refreshTimer?.cancel();

    // Create new timer
    _refreshTimer = Timer.periodic(
        Duration(seconds: _refreshInterval), (_) => fetchIndices());
  }

  // Allow changing refresh interval
  void setRefreshInterval(int seconds) {
    if (seconds < 5) seconds = 5; // Minimum 5s
    _refreshInterval = seconds;
    _setupAutoRefresh();
  }

  Future<void> fetchIndices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final indices = await _marketIndexService.fetchIndices();
      _indices = indices;
      _lastUpdated = DateTime.now();
    } catch (e) {
      print('Error in IndexProvider: $e');
      // Keep old data if available
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
