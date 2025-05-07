class ApiConstants {
  static const String baseUrl = 'https://newsdata.io/api/1/latest';
  static const String apiKey = 'pub_813387a573a74aca2e88036ba908139dc1155';

  static const Map<String, dynamic> queryParams = {
    'country': 'in',
    'category': 'business',
    'language': 'en',
    'q': 'stock market OR nifty OR sensex OR NSE OR BSE',
  };

  // Constants for Indian market index API
  static const String marketIndexUrl = 'https://api.marketstack.com/v1/eod';
  static const String marketIndexApiKey =
      'YOUR_API_KEY'; // Replace with actual key in production

  // Symbols for the Indian indices we want to track
  static const Map<String, String> indexSymbols = {
    'NIFTY 50': '^NSEI', // NSE NIFTY 50 index
    'SENSEX': '^BSESN', // BSE SENSEX index
    'BANK NIFTY': '^NSEBANK', // NSE Bank index
    'INDIA VIX': '^INDIAVIX', // India volatility index
  };
}
