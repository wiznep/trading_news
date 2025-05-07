import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/news_article.dart';

class NewsApiService {
  final Dio _dio = Dio();

  Future<List<NewsArticle>> fetchNews({String? query}) async {
    try {
      final Map<String, dynamic> params = {
        'apikey': ApiConstants.apiKey,
        ...ApiConstants.queryParams,
      };

      if (query != null && query.isNotEmpty) {
        params['q'] = query;
      }

      final response = await _dio.get(
        ApiConstants.baseUrl,
        queryParameters: params,
      );
      final List articles = response.data['results'] ?? [];
      return articles.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching news: $e');
      rethrow;
    }
  }
}
