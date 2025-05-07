import 'package:hive/hive.dart';
part 'news_article.g.dart';

@HiveType(typeId: 0)
class NewsArticle {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String link;
  @HiveField(3)
  final String pubDate;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final List<String> categories;
  @HiveField(6)
  final String? imageUrl;
  @HiveField(7)
  final String source;
  @HiveField(8)
  final bool isRead;
  @HiveField(9)
  final List<String>? relatedStocks;
  @HiveField(10)
  final String? stockImpact;
  @HiveField(11)
  final double? sentimentScore;

  NewsArticle({
    required this.id,
    required this.title,
    required this.link,
    required this.pubDate,
    required this.description,
    this.categories = const [],
    this.imageUrl,
    this.source = '',
    this.isRead = false,
    this.relatedStocks,
    this.stockImpact,
    this.sentimentScore,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    List<String> categoryList = [];
    if (json['category'] != null) {
      if (json['category'] is List) {
        categoryList =
            (json['category'] as List).map((item) => item.toString()).toList();
      } else if (json['category'] is String) {
        categoryList = [(json['category'] as String)];
      }
    }

    // Extract related stocks if available
    List<String>? stocksList;
    if (json['related_stocks'] != null) {
      if (json['related_stocks'] is List) {
        stocksList = (json['related_stocks'] as List)
            .map((item) => item.toString())
            .toList();
      } else if (json['related_stocks'] is String) {
        stocksList = [(json['related_stocks'] as String)];
      }
    }

    // Assign default categories based on keywords in title or description
    if (categoryList.isEmpty) {
      final String combinedText =
          (json['title'] ?? '') + ' ' + (json['description'] ?? '');
      final String lowerText = combinedText.toLowerCase();

      if (lowerText.contains('nifty') ||
          lowerText.contains('sensex') ||
          lowerText.contains('index')) {
        categoryList.add('market_indices');
      } else if (lowerText.contains('stock') ||
          lowerText.contains('share') ||
          lowerText.contains('equity')) {
        categoryList.add('stocks');
      } else if (lowerText.contains('rbi') ||
          lowerText.contains('economy') ||
          lowerText.contains('inflation') ||
          lowerText.contains('policy') ||
          lowerText.contains('interest rate')) {
        categoryList.add('economy');
      } else if (lowerText.contains('results') ||
          lowerText.contains('profit') ||
          lowerText.contains('revenue') ||
          lowerText.contains('earnings')) {
        categoryList.add('earnings');
      } else if (lowerText.contains('ipo') ||
          lowerText.contains('listing') ||
          lowerText.contains('public offer')) {
        categoryList.add('ipo');
      } else if (lowerText.contains('dividend') ||
          lowerText.contains('bonus') ||
          lowerText.contains('split')) {
        categoryList.add('corporate_actions');
      } else if (lowerText.contains('merger') ||
          lowerText.contains('acquisition') ||
          lowerText.contains('takeover')) {
        categoryList.add('m&a');
      } else if (lowerText.contains('commodity') ||
          lowerText.contains('gold') ||
          lowerText.contains('oil')) {
        categoryList.add('commodities');
      } else if (lowerText.contains('global') ||
          lowerText.contains('international') ||
          lowerText.contains('world')) {
        categoryList.add('global_markets');
      }
    }

    // Determine stock impact if not provided
    String? impact = json['stock_impact'];
    if (impact == null) {
      final String lowerTitle = (json['title'] ?? '').toLowerCase();
      if (lowerTitle.contains('surge') ||
          lowerTitle.contains('jump') ||
          lowerTitle.contains('rise') ||
          lowerTitle.contains('gain') ||
          lowerTitle.contains('positive')) {
        impact = 'positive';
      } else if (lowerTitle.contains('plunge') ||
          lowerTitle.contains('fall') ||
          lowerTitle.contains('drop') ||
          lowerTitle.contains('negative') ||
          lowerTitle.contains('loss')) {
        impact = 'negative';
      } else {
        impact = 'neutral';
      }
    }

    return NewsArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      pubDate: json['pubDate'] ?? '',
      description: json['description'] ?? '',
      categories: categoryList,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? null,
      source: json['source_id'] ?? json['source'] ?? '',
      relatedStocks: stocksList,
      stockImpact: impact,
      sentimentScore: json['sentiment_score'] != null
          ? double.tryParse(json['sentiment_score'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'link': link,
        'pubDate': pubDate,
        'description': description,
        'categories': categories,
        'imageUrl': imageUrl,
        'source': source,
        'isRead': isRead,
        'relatedStocks': relatedStocks,
        'stockImpact': stockImpact,
        'sentimentScore': sentimentScore,
      };
}
