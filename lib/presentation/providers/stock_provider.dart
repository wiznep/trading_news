import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/stock.dart';

class StockProvider with ChangeNotifier {
  List<Stock> _stocks = [];
  List<Stock> _watchlistStocks = [];
  List<String> _watchlistSymbols = [];
  List<Stock> _searchResults = [];
  bool _isLoading = false;
  bool _isWatchlistLoading = false;
  String _searchQuery = '';
  DateTime? _lastUpdated;

  // Refresh interval in seconds (default 30s)
  int _refreshInterval = 30;
  Timer? _refreshTimer;

  List<Stock> get stocks => _stocks;
  List<Stock> get watchlistStocks => _watchlistStocks;
  List<String> get watchlistSymbols => _watchlistSymbols;
  List<Stock> get searchResults => _searchQuery.isEmpty ? [] : _searchResults;
  bool get isLoading => _isLoading;
  bool get isWatchlistLoading => _isWatchlistLoading;
  String get searchQuery => _searchQuery;
  DateTime? get lastUpdated => _lastUpdated;

  StockProvider() {
    _loadWatchlist();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    // Cancel existing timer if any
    _refreshTimer?.cancel();

    // Create new timer
    _refreshTimer = Timer.periodic(
        Duration(seconds: _refreshInterval), (_) => refreshStocks());
  }

  // Allow changing refresh interval
  void setRefreshInterval(int seconds) {
    if (seconds < 5) seconds = 5; // Minimum 5s
    _refreshInterval = seconds;
    _setupAutoRefresh();
  }

  // Load watchlist from shared preferences
  Future<void> _loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    _watchlistSymbols = prefs.getStringList('watchlist') ?? [];
    await fetchWatchlistStocks();
  }

  // Save watchlist to shared preferences
  Future<void> _saveWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('watchlist', _watchlistSymbols);
  }

  // Add stock to watchlist
  Future<void> addToWatchlist(String symbol) async {
    if (!_watchlistSymbols.contains(symbol)) {
      _watchlistSymbols.add(symbol);
      await _saveWatchlist();
      await fetchWatchlistStocks();
    }
  }

  // Remove stock from watchlist
  Future<void> removeFromWatchlist(String symbol) async {
    if (_watchlistSymbols.contains(symbol)) {
      _watchlistSymbols.remove(symbol);
      _watchlistStocks.removeWhere((stock) => stock.symbol == symbol);
      await _saveWatchlist();
      notifyListeners();
    }
  }

  // Check if a stock is in watchlist
  bool isInWatchlist(String symbol) {
    return _watchlistSymbols.contains(symbol);
  }

  // Fetch stock data for watchlist
  Future<void> fetchWatchlistStocks() async {
    if (_watchlistSymbols.isEmpty) {
      _watchlistStocks = [];
      notifyListeners();
      return;
    }

    _isWatchlistLoading = true;
    notifyListeners();

    try {
      // In a real app, this would call an API service
      // For now, we'll use mock data
      _watchlistStocks = _watchlistSymbols.map((symbol) {
        // Find corresponding company name
        final name = _getCompanyName(symbol);
        return Stock.mock(symbol, name);
      }).toList();

      _lastUpdated = DateTime.now();
    } catch (e) {
      print('Error fetching watchlist stocks: $e');
    } finally {
      _isWatchlistLoading = false;
      notifyListeners();
    }
  }

  // Fetch all stocks or top stocks
  Future<void> fetchStocks({int limit = 50}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would call an API service
      // For now, we'll use mock data for top Indian stocks
      final topStocks = [
        {'symbol': 'RELIANCE', 'name': 'Reliance Industries Ltd.'},
        {'symbol': 'TCS', 'name': 'Tata Consultancy Services Ltd.'},
        {'symbol': 'HDFCBANK', 'name': 'HDFC Bank Ltd.'},
        {'symbol': 'INFY', 'name': 'Infosys Ltd.'},
        {'symbol': 'HINDUNILVR', 'name': 'Hindustan Unilever Ltd.'},
        {'symbol': 'ICICIBANK', 'name': 'ICICI Bank Ltd.'},
        {'symbol': 'SBIN', 'name': 'State Bank of India'},
        {'symbol': 'BHARTIARTL', 'name': 'Bharti Airtel Ltd.'},
        {'symbol': 'ITC', 'name': 'ITC Ltd.'},
        {'symbol': 'KOTAKBANK', 'name': 'Kotak Mahindra Bank Ltd.'},
        {'symbol': 'LT', 'name': 'Larsen & Toubro Ltd.'},
        {'symbol': 'AXISBANK', 'name': 'Axis Bank Ltd.'},
        {'symbol': 'BAJFINANCE', 'name': 'Bajaj Finance Ltd.'},
        {'symbol': 'ASIANPAINT', 'name': 'Asian Paints Ltd.'},
        {'symbol': 'MARUTI', 'name': 'Maruti Suzuki India Ltd.'},
        {'symbol': 'SUNPHARMA', 'name': 'Sun Pharmaceutical Industries Ltd.'},
        {'symbol': 'NESTLEIND', 'name': 'Nestle India Ltd.'},
        {'symbol': 'HCLTECH', 'name': 'HCL Technologies Ltd.'},
        {'symbol': 'TATAMOTORS', 'name': 'Tata Motors Ltd.'},
        {'symbol': 'ULTRACEMCO', 'name': 'UltraTech Cement Ltd.'},
      ];

      // Create mock stock data
      _stocks = topStocks.take(limit).map((stock) {
        final bool positive = (DateTime.now().millisecond % 2 == 0);
        return Stock.mock(
          stock['symbol']!,
          stock['name']!,
          positive: positive,
          volatility: 1.0 + (DateTime.now().second % 10) / 10,
        );
      }).toList();

      _lastUpdated = DateTime.now();
    } catch (e) {
      print('Error fetching stocks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search for stocks
  Future<void> searchStocks(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would call an API service
      // For now, we'll filter from a larger list of stocks
      final allStocks = [
        {'symbol': 'RELIANCE', 'name': 'Reliance Industries Ltd.'},
        {'symbol': 'TCS', 'name': 'Tata Consultancy Services Ltd.'},
        {'symbol': 'HDFCBANK', 'name': 'HDFC Bank Ltd.'},
        {'symbol': 'INFY', 'name': 'Infosys Ltd.'},
        {'symbol': 'HINDUNILVR', 'name': 'Hindustan Unilever Ltd.'},
        {'symbol': 'ICICIBANK', 'name': 'ICICI Bank Ltd.'},
        {'symbol': 'SBIN', 'name': 'State Bank of India'},
        {'symbol': 'BHARTIARTL', 'name': 'Bharti Airtel Ltd.'},
        {'symbol': 'ITC', 'name': 'ITC Ltd.'},
        {'symbol': 'KOTAKBANK', 'name': 'Kotak Mahindra Bank Ltd.'},
        {'symbol': 'LT', 'name': 'Larsen & Toubro Ltd.'},
        {'symbol': 'AXISBANK', 'name': 'Axis Bank Ltd.'},
        {'symbol': 'BAJFINANCE', 'name': 'Bajaj Finance Ltd.'},
        {'symbol': 'ASIANPAINT', 'name': 'Asian Paints Ltd.'},
        {'symbol': 'MARUTI', 'name': 'Maruti Suzuki India Ltd.'},
        {'symbol': 'SUNPHARMA', 'name': 'Sun Pharmaceutical Industries Ltd.'},
        {'symbol': 'NESTLEIND', 'name': 'Nestle India Ltd.'},
        {'symbol': 'HCLTECH', 'name': 'HCL Technologies Ltd.'},
        {'symbol': 'TATAMOTORS', 'name': 'Tata Motors Ltd.'},
        {'symbol': 'ULTRACEMCO', 'name': 'UltraTech Cement Ltd.'},
        {'symbol': 'WIPRO', 'name': 'Wipro Ltd.'},
        {'symbol': 'DRREDDY', 'name': 'Dr. Reddy\'s Laboratories Ltd.'},
        {'symbol': 'ADANIENT', 'name': 'Adani Enterprises Ltd.'},
        {'symbol': 'BAJAJFINSV', 'name': 'Bajaj Finserv Ltd.'},
        {'symbol': 'TITAN', 'name': 'Titan Company Ltd.'},
        {'symbol': 'POWERGRID', 'name': 'Power Grid Corporation of India Ltd.'},
        {'symbol': 'NTPC', 'name': 'NTPC Ltd.'},
        {'symbol': 'ONGC', 'name': 'Oil and Natural Gas Corporation Ltd.'},
        {'symbol': 'GRASIM', 'name': 'Grasim Industries Ltd.'},
        {'symbol': 'INDUSINDBK', 'name': 'IndusInd Bank Ltd.'},
      ];

      final filteredStocks = allStocks.where((stock) {
        return stock['symbol']!.contains(query.toUpperCase()) ||
            stock['name']!.toLowerCase().contains(query.toLowerCase());
      }).toList();

      _searchResults = filteredStocks.map((stock) {
        final bool positive = (DateTime.now().millisecond % 2 == 0);
        return Stock.mock(
          stock['symbol']!,
          stock['name']!,
          positive: positive,
        );
      }).toList();
    } catch (e) {
      print('Error searching stocks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh all stock data
  Future<void> refreshStocks() async {
    await Future.wait([
      fetchStocks(),
      fetchWatchlistStocks(),
    ]);
  }

  // Helper method to get company name from symbol
  String _getCompanyName(String symbol) {
    final companyMap = {
      'RELIANCE': 'Reliance Industries Ltd.',
      'TCS': 'Tata Consultancy Services Ltd.',
      'HDFCBANK': 'HDFC Bank Ltd.',
      'INFY': 'Infosys Ltd.',
      'HINDUNILVR': 'Hindustan Unilever Ltd.',
      'ICICIBANK': 'ICICI Bank Ltd.',
      'SBIN': 'State Bank of India',
      'BHARTIARTL': 'Bharti Airtel Ltd.',
      'ITC': 'ITC Ltd.',
      'KOTAKBANK': 'Kotak Mahindra Bank Ltd.',
      'LT': 'Larsen & Toubro Ltd.',
      'AXISBANK': 'Axis Bank Ltd.',
      'BAJFINANCE': 'Bajaj Finance Ltd.',
      'ASIANPAINT': 'Asian Paints Ltd.',
      'MARUTI': 'Maruti Suzuki India Ltd.',
      'SUNPHARMA': 'Sun Pharmaceutical Industries Ltd.',
      'NESTLEIND': 'Nestle India Ltd.',
      'HCLTECH': 'HCL Technologies Ltd.',
      'TATAMOTORS': 'Tata Motors Ltd.',
      'ULTRACEMCO': 'UltraTech Cement Ltd.',
      'WIPRO': 'Wipro Ltd.',
      'DRREDDY': 'Dr. Reddy\'s Laboratories Ltd.',
      'ADANIENT': 'Adani Enterprises Ltd.',
      'BAJAJFINSV': 'Bajaj Finserv Ltd.',
      'TITAN': 'Titan Company Ltd.',
    };

    return companyMap[symbol] ?? 'Unknown Company';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
