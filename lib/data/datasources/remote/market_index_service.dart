import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:math';
import '../../../core/constants/api_constants.dart';
import '../../models/market_index.dart';

class MarketIndexService {
  final Dio _dio = Dio();
  final Random _random = Random();

  // Fetch market indices data
  Future<List<MarketIndex>> fetchIndices() async {
    try {
      // In real implementation, we'd use the actual API call
      // return await _fetchIndicesFromApi();

      // Since we need a working demo without requiring API keys,
      // we'll use mock data that looks realistic
      return await _fetchMockIndices();
    } catch (e) {
      print('Error fetching market indices: $e');
      // Fallback to mock data if API fails
      return _createMockIndices();
    }
  }

  // Real API implementation (commented out for demo)
  Future<List<MarketIndex>> _fetchIndicesFromApi() async {
    final List<MarketIndex> indices = [];

    try {
      // For each index symbol, make an API request
      for (final entry in ApiConstants.indexSymbols.entries) {
        final indexName = entry.key;
        final symbol = entry.value;

        final response = await _dio.get(
          ApiConstants.marketIndexUrl,
          queryParameters: {
            'access_key': ApiConstants.marketIndexApiKey,
            'symbols': symbol,
            'limit': 1,
          },
        );

        if (response.statusCode == 200 &&
            response.data != null &&
            response.data['data'] != null &&
            response.data['data'].isNotEmpty) {
          final indexData = response.data['data'][0];
          indices.add(MarketIndex.fromJson(indexData, indexName, symbol));
        }
      }

      return indices;
    } catch (e) {
      print('API Error: $e');
      throw e;
    }
  }

  // For demo purposes, create realistic mock data
  Future<List<MarketIndex>> _fetchMockIndices() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(500)));
    return _createMockIndices();
  }

  List<MarketIndex> _createMockIndices() {
    // Get random trend for the day (more indices will be positive than negative)
    final marketTrend = _random.nextDouble() > 0.35;
    final volatilityFactor = 0.7 + (_random.nextDouble() * 0.6); // 0.7 to 1.3

    // List of indices to display
    return ApiConstants.indexSymbols.entries.map((entry) {
      final name = entry.key;
      final symbol = entry.value;

      // For VIX, often moves opposite to market trend
      if (symbol == '^INDIAVIX') {
        return MarketIndex.mock(name, symbol,
            positive: !marketTrend,
            volatility: volatilityFactor * 1.5); // VIX is more volatile
      }

      // Random chance for an index to go against market trend
      final followsTrend = _random.nextDouble() > 0.2;
      final isPositive = followsTrend ? marketTrend : !marketTrend;

      // Different indices have different volatility
      double volatility = volatilityFactor;
      if (symbol == '^NSEBANK') {
        volatility *= 1.2; // Bank Nifty is more volatile
      }

      return MarketIndex.mock(name, symbol,
          positive: isPositive, volatility: volatility);
    }).toList();
  }
}
