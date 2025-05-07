class MarketIndex {
  final String name;
  final String symbol;
  final double currentValue;
  final double change;
  final double changePercentage;
  final bool isPositive;
  final double dayHigh;
  final double dayLow;
  final double previousClose;
  final int volume;
  final DateTime lastUpdated;
  final String exchange;
  final List<Map<String, double>>? intradayData;
  final String type; // 'equity', 'sector', 'commodity', etc.

  MarketIndex({
    required this.name,
    required this.symbol,
    required this.currentValue,
    required this.change,
    required this.changePercentage,
    required this.isPositive,
    this.dayHigh = 0.0,
    this.dayLow = 0.0,
    this.previousClose = 0.0,
    this.volume = 0,
    DateTime? lastUpdated,
    this.exchange = '',
    this.intradayData,
    this.type = 'equity',
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  factory MarketIndex.fromJson(
      Map<String, dynamic> json, String indexName, String symbol) {
    final currentValue = (json['close'] ?? 0.0).toDouble();
    final previousClose = (json['open'] ?? 0.0).toDouble();
    final change = currentValue - previousClose;
    final changePercentage =
        previousClose > 0 ? (change / previousClose) * 100 : 0.0;

    // Parse intraday data if available
    List<Map<String, double>>? intradayData;
    if (json['intraday_data'] != null && json['intraday_data'] is List) {
      intradayData = (json['intraday_data'] as List)
          .map((item) {
            return {
              'time': (item['time'] ?? 0).toDouble(),
              'value': (item['value'] ?? 0).toDouble(),
            };
          })
          .toList()
          .cast<Map<String, double>>();
    }

    return MarketIndex(
      name: indexName,
      symbol: symbol,
      currentValue: currentValue,
      change: change,
      changePercentage: changePercentage,
      isPositive: change >= 0,
      dayHigh: (json['high'] ?? 0.0).toDouble(),
      dayLow: (json['low'] ?? 0.0).toDouble(),
      previousClose: previousClose,
      volume: json['volume'] ?? 0,
      lastUpdated:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      exchange: json['exchange'] ?? '',
      intradayData: intradayData,
      type: json['type'] ?? 'equity',
    );
  }

  // Create a mock/sample index with realistic values
  factory MarketIndex.mock(String name, String symbol,
      {bool positive = true, double volatility = 1.0, String? type}) {
    // Baseline values for major Indian indices based on Apr 2023 values
    final baseValues = {
      // Major indices
      '^NSEI': 22380.0, // NIFTY 50
      '^BSESN': 73600.0, // SENSEX
      '^NSEBANK': 48250.0, // BANK NIFTY
      '^INDIAVIX': 14.2, // INDIA VIX

      // Sector indices
      '^CNXIT': 37500.0, // NIFTY IT
      '^CNXPHARMA': 16800.0, // NIFTY PHARMA
      '^CNXAUTO': 20400.0, // NIFTY AUTO
      '^CNXFMCG': 54600.0, // NIFTY FMCG
      '^CNXMETAL': 8200.0, // NIFTY METAL
      '^CNXREALTY': 940.0, // NIFTY REALTY
      '^CNXENERGY': 36800.0, // NIFTY ENERGY
      '^CNXFINSERVICE': 21500.0, // NIFTY FIN SERVICE

      // Market cap based indices
      '^CNXSMALLCAP': 14800.0, // NIFTY SMALLCAP 100
      '^CNXMIDCAP': 43200.0, // NIFTY MIDCAP 100

      // Other important indices
      '^NIFTY100': 18600.0, // NIFTY 100
      '^NIFTY200': 12800.0, // NIFTY 200
    };

    final indexTypes = {
      '^NSEI': 'equity',
      '^BSESN': 'equity',
      '^NSEBANK': 'sector',
      '^INDIAVIX': 'volatility',
      '^CNXIT': 'sector',
      '^CNXPHARMA': 'sector',
      '^CNXAUTO': 'sector',
      '^CNXFMCG': 'sector',
      '^CNXMETAL': 'sector',
      '^CNXREALTY': 'sector',
      '^CNXENERGY': 'sector',
      '^CNXFINSERVICE': 'sector',
      '^CNXSMALLCAP': 'market_cap',
      '^CNXMIDCAP': 'market_cap',
      '^NIFTY100': 'equity',
      '^NIFTY200': 'equity',
    };

    final base = baseValues[symbol] ?? 10000.0;
    final random = positive
        ? 0.005 +
            (0.015 * volatility * (DateTime.now().millisecond % 100) / 100)
        : -0.005 -
            (0.015 * volatility * (DateTime.now().millisecond % 100) / 100);

    final change = base * random;
    final currentValue = base + change;

    // Generate mock intraday data for the past trading day (9:15 AM to 3:30 PM IST)
    final List<Map<String, double>> mockIntradayData = [];
    final openingValue = base;
    double tempValue = openingValue;

    // Market hours in India: 9:15 AM to 3:30 PM
    for (int minute = 0; minute <= 375; minute += 5) {
      // 375 minutes = 6.25 hours
      // Simulate some volatility in price
      final randFactor = (DateTime.now().millisecond % 200 - 100) / 10000.0;
      tempValue = tempValue * (1 + randFactor);

      // Add trend toward final value as we approach market close
      final progressToEnd = minute / 375.0;
      tempValue =
          tempValue * (1 - progressToEnd) + currentValue * progressToEnd;

      mockIntradayData.add({
        'time': minute.toDouble(),
        'value': tempValue,
      });
    }

    return MarketIndex(
      name: name,
      symbol: symbol,
      currentValue: currentValue,
      change: change,
      changePercentage: (change / base) * 100,
      isPositive: change >= 0,
      dayHigh: currentValue + (currentValue * 0.01),
      dayLow: currentValue - (currentValue * 0.01),
      previousClose: base,
      volume: 125000000 + (DateTime.now().second * 10000),
      lastUpdated: DateTime.now(),
      exchange: symbol.contains('BSE') ? 'BSE' : 'NSE',
      intradayData: mockIntradayData,
      type: type ?? indexTypes[symbol] ?? 'equity',
    );
  }
}
