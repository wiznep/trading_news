import 'package:hive/hive.dart';

class Stock {
  final String symbol;
  final String name;
  final String exchange;
  final double currentPrice;
  final double change;
  final double changePercentage;
  final bool isPositive;
  final double dayHigh;
  final double dayLow;
  final double openPrice;
  final double previousClose;
  final int volume;
  final String sector;
  final String industry;
  final double marketCap;
  final DateTime lastUpdated;
  final List<Map<String, double>>? intradayData;
  final Map<String, String>? keyMetrics;
  final double? pe;
  final double? eps;
  final double? dividendYield;

  Stock({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currentPrice,
    required this.change,
    required this.changePercentage,
    required this.isPositive,
    this.dayHigh = 0.0,
    this.dayLow = 0.0,
    this.openPrice = 0.0,
    this.previousClose = 0.0,
    this.volume = 0,
    this.sector = '',
    this.industry = '',
    this.marketCap = 0.0,
    DateTime? lastUpdated,
    this.intradayData,
    this.keyMetrics,
    this.pe,
    this.eps,
    this.dividendYield,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  factory Stock.fromJson(Map<String, dynamic> json) {
    final currentPrice = (json['currentPrice'] ?? 0.0).toDouble();
    final previousClose = (json['previousClose'] ?? 0.0).toDouble();
    final change = currentPrice - previousClose;
    final changePercentage =
        previousClose > 0 ? (change / previousClose) * 100 : 0.0;

    // Parse intraday data if available
    List<Map<String, double>>? intradayData;
    if (json['intradayData'] != null && json['intradayData'] is List) {
      intradayData = (json['intradayData'] as List)
          .map((item) {
            return {
              'time': (item['time'] ?? 0).toDouble(),
              'value': (item['value'] ?? 0).toDouble(),
            };
          })
          .toList()
          .cast<Map<String, double>>();
    }

    // Parse key metrics
    Map<String, String>? keyMetrics;
    if (json['keyMetrics'] != null && json['keyMetrics'] is Map) {
      keyMetrics = Map<String, String>.from(json['keyMetrics']);
    }

    return Stock(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      exchange: json['exchange'] ?? 'NSE',
      currentPrice: currentPrice,
      change: change,
      changePercentage: changePercentage,
      isPositive: change >= 0,
      dayHigh: (json['dayHigh'] ?? 0.0).toDouble(),
      dayLow: (json['dayLow'] ?? 0.0).toDouble(),
      openPrice: (json['openPrice'] ?? 0.0).toDouble(),
      previousClose: previousClose,
      volume: json['volume'] ?? 0,
      sector: json['sector'] ?? '',
      industry: json['industry'] ?? '',
      marketCap: (json['marketCap'] ?? 0.0).toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      intradayData: intradayData,
      keyMetrics: keyMetrics,
      pe: json['pe'] != null ? (json['pe']).toDouble() : null,
      eps: json['eps'] != null ? (json['eps']).toDouble() : null,
      dividendYield: json['dividendYield'] != null
          ? (json['dividendYield']).toDouble()
          : null,
    );
  }

  // Generate mock stock data
  factory Stock.mock(String symbol, String name,
      {bool positive = true, double volatility = 1.0, String? sector}) {
    // Baseline data for some major Indian stocks
    final baseStockData = {
      'RELIANCE': {'price': 2850.0, 'sector': 'Energy'},
      'TCS': {'price': 3450.0, 'sector': 'IT'},
      'HDFC': {'price': 1700.0, 'sector': 'Financial Services'},
      'INFY': {'price': 1560.0, 'sector': 'IT'},
      'ITC': {'price': 430.0, 'sector': 'FMCG'},
      'SBIN': {'price': 620.0, 'sector': 'Financial Services'},
      'HDFCBANK': {'price': 1650.0, 'sector': 'Financial Services'},
      'BHARTIARTL': {'price': 1180.0, 'sector': 'Telecom'},
      'TATAMOTORS': {'price': 850.0, 'sector': 'Automobile'},
      'ASIANPAINT': {'price': 3150.0, 'sector': 'Consumer Durables'},
      'MARUTI': {'price': 10800.0, 'sector': 'Automobile'},
      'WIPRO': {'price': 450.0, 'sector': 'IT'},
      'HCLTECH': {'price': 1270.0, 'sector': 'IT'},
      'SUNPHARMA': {'price': 1250.0, 'sector': 'Pharma'},
      'DRREDDY': {'price': 5600.0, 'sector': 'Pharma'},
    };

    final basePrice =
        (baseStockData[symbol]?['price'] as num?)?.toDouble() ?? 1000.0;
    final stockSector =
        sector ?? (baseStockData[symbol]?['sector'] as String?) ?? 'Other';

    final random = positive
        ? 0.005 +
            (0.025 * volatility * (DateTime.now().millisecond % 100) / 100)
        : -0.005 -
            (0.025 * volatility * (DateTime.now().millisecond % 100) / 100);

    final change = basePrice * random;
    final currentPrice = basePrice + change;
    final volume = 500000 + (DateTime.now().microsecond % 1000000);

    // Generate mock intraday data (9:15 AM to 3:30 PM IST)
    final List<Map<String, double>> mockIntradayData = [];
    final openingValue = basePrice;
    double tempValue = openingValue;

    for (int minute = 0; minute <= 375; minute += 5) {
      final randFactor = (DateTime.now().millisecond % 200 - 100) / 10000.0;
      tempValue = tempValue * (1 + randFactor);

      final progressToEnd = minute / 375.0;
      tempValue =
          tempValue * (1 - progressToEnd) + currentPrice * progressToEnd;

      mockIntradayData.add({
        'time': minute.toDouble(),
        'value': tempValue,
      });
    }

    // Generate mock key metrics
    final Map<String, String> mockKeyMetrics = {
      'Market Cap': '${(currentPrice * volume / 10000).toStringAsFixed(2)} Cr',
      '52W High': '${(currentPrice * 1.3).toStringAsFixed(2)}',
      '52W Low': '${(currentPrice * 0.7).toStringAsFixed(2)}',
      'Avg Volume': '${(volume * 0.8).toStringAsFixed(0)}',
    };

    final pe = 15.0 + (DateTime.now().second % 25);
    final eps = currentPrice / pe;

    return Stock(
      symbol: symbol,
      name: name,
      exchange: 'NSE',
      currentPrice: currentPrice,
      change: change,
      changePercentage: (change / basePrice) * 100,
      isPositive: change >= 0,
      dayHigh: currentPrice + (currentPrice * 0.02),
      dayLow: currentPrice - (currentPrice * 0.02),
      openPrice: basePrice,
      previousClose: basePrice,
      volume: volume,
      sector: stockSector,
      industry: stockSector,
      marketCap: currentPrice * volume / 10000,
      lastUpdated: DateTime.now(),
      intradayData: mockIntradayData,
      keyMetrics: mockKeyMetrics,
      pe: pe,
      eps: eps,
      dividendYield: 1.0 + (DateTime.now().millisecond % 300) / 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'exchange': exchange,
        'currentPrice': currentPrice,
        'change': change,
        'changePercentage': changePercentage,
        'isPositive': isPositive,
        'dayHigh': dayHigh,
        'dayLow': dayLow,
        'openPrice': openPrice,
        'previousClose': previousClose,
        'volume': volume,
        'sector': sector,
        'industry': industry,
        'marketCap': marketCap,
        'lastUpdated': lastUpdated.toIso8601String(),
        'pe': pe,
        'eps': eps,
        'dividendYield': dividendYield,
      };
}
