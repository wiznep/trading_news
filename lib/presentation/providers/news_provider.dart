import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasources/remote/news_api_service.dart';
import '../../../data/models/news_article.dart';
import '../../../data/models/news_category.dart';
import 'package:provider/provider.dart';

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService = NewsApiService();

  List<NewsArticle> _articles = [];
  List<NewsArticle> get articles => _getFilteredArticles();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'all';
  String get selectedCategory => _selectedCategory;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  // Set to track which categories are represented in the current article set
  Set<String> _availableCategories = {'all'};
  Set<String> get availableCategories => _availableCategories;

  // Stats tracking
  int _bookmarkCount = 0;
  int get bookmarkCount => _bookmarkCount;

  // Timestamp for last bookmark action
  DateTime? _lastBookmarkAction;
  DateTime? get lastBookmarkAction => _lastBookmarkAction;

  // Bookmark history and analytics
  Map<String, int> _categoryBookmarkCounts = {};
  Map<String, DateTime> _bookmarkHistory = {};
  int _bookmarksAddedToday = 0;
  int _bookmarksRemovedToday = 0;

  // Getters for bookmark analytics
  Map<String, int> get categoryBookmarkCounts => _categoryBookmarkCounts;
  Map<String, DateTime> get bookmarkHistory => _bookmarkHistory;
  int get bookmarksAddedToday => _bookmarksAddedToday;
  int get bookmarksRemovedToday => _bookmarksRemovedToday;

  NewsProvider() {
    _loadSavedCategory();
    _loadBookmarkStats();
    _loadBookmarkAnalytics();
  }

  // Load the last selected category from SharedPreferences
  Future<void> _loadSavedCategory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategory = prefs.getString('selected_category');
      if (savedCategory != null) {
        _selectedCategory = savedCategory;
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, just use the default 'all' category
      print('Error loading saved category: $e');
    }
  }

  // Save the selected category to SharedPreferences
  Future<void> _saveCategory(String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_category', category);
    } catch (e) {
      print('Error saving category: $e');
    }
  }

  // Load bookmark statistics
  Future<void> _loadBookmarkStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bookmarkCount = prefs.getInt('bookmark_count') ?? 0;
      final lastActionTime = prefs.getInt('last_bookmark_time');
      if (lastActionTime != null) {
        _lastBookmarkAction =
            DateTime.fromMillisecondsSinceEpoch(lastActionTime);
      }
    } catch (e) {
      print('Error loading bookmark stats: $e');
    }
  }

  // Load bookmark analytics data
  Future<void> _loadBookmarkAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load category bookmark counts
      final categoryCountsJson = prefs.getString('category_bookmark_counts');
      if (categoryCountsJson != null) {
        final Map<String, dynamic> decoded =
            Map<String, dynamic>.from(_decodeJson(categoryCountsJson) ?? {});
        _categoryBookmarkCounts =
            decoded.map((key, value) => MapEntry(key, value as int));
      }

      // Load bookmark history (timestamps)
      final historyJson = prefs.getString('bookmark_history');
      if (historyJson != null) {
        final Map<String, dynamic> decoded =
            Map<String, dynamic>.from(_decodeJson(historyJson) ?? {});
        _bookmarkHistory = decoded.map((key, value) =>
            MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value as int)));
      }

      // Load daily stats
      final today = _getTodayFormatted();
      _bookmarksAddedToday = prefs.getInt('bookmarks_added_$today') ?? 0;
      _bookmarksRemovedToday = prefs.getInt('bookmarks_removed_$today') ?? 0;
    } catch (e) {
      print('Error loading bookmark analytics: $e');
    }
  }

  // Save bookmark statistics
  Future<void> _saveBookmarkStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bookmark_count', _bookmarkCount);
      if (_lastBookmarkAction != null) {
        await prefs.setInt(
            'last_bookmark_time', _lastBookmarkAction!.millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Error saving bookmark stats: $e');
    }
  }

  // Save bookmark analytics data
  Future<void> _saveBookmarkAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save category bookmark counts
      await prefs.setString(
          'category_bookmark_counts', _encodeJson(_categoryBookmarkCounts));

      // Save bookmark history
      final historyToSave = Map<String, int>.from(_bookmarkHistory
          .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)));
      await prefs.setString('bookmark_history', _encodeJson(historyToSave));

      // Save daily stats
      final today = _getTodayFormatted();
      await prefs.setInt('bookmarks_added_$today', _bookmarksAddedToday);
      await prefs.setInt('bookmarks_removed_$today', _bookmarksRemovedToday);
    } catch (e) {
      print('Error saving bookmark analytics: $e');
    }
  }

  // Helper to encode Map to JSON string
  String _encodeJson(Map<dynamic, dynamic> data) {
    return data.toString(); // Simple encoding for shared prefs
  }

  // Helper to decode JSON string to Map
  Map<String, dynamic>? _decodeJson(String jsonString) {
    try {
      // Convert string representation of map to actual map
      final String processed = jsonString
          .replaceAll('{', '{"')
          .replaceAll(': ', '": ')
          .replaceAll(', ', ', "')
          .replaceAll('}"', '}');

      // Parse the modified string manually
      Map<String, dynamic> result = {};
      final entries = processed.substring(1, processed.length - 1).split(', ');

      for (final entry in entries) {
        if (entry.isEmpty) continue;
        final parts = entry.split('": ');
        if (parts.length != 2) continue;

        String key = parts[0].replaceAll('"', '');
        String valueStr = parts[1];

        // Try to parse value to appropriate type
        dynamic value;
        if (valueStr == 'null') {
          value = null;
        } else if (valueStr == 'true') {
          value = true;
        } else if (valueStr == 'false') {
          value = false;
        } else if (int.tryParse(valueStr) != null) {
          value = int.parse(valueStr);
        } else if (double.tryParse(valueStr) != null) {
          value = double.parse(valueStr);
        } else {
          // Default to string with quotes removed
          value = valueStr.replaceAll('"', '');
        }

        result[key] = value;
      }

      return result;
    } catch (e) {
      print('Error decoding JSON: $e');
      return null;
    }
  }

  // Get today's date in YYYY-MM-DD format for stats tracking
  String _getTodayFormatted() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<NewsArticle> _getFilteredArticles() {
    if (_selectedCategory == 'all' &&
        (_searchQuery == null || _searchQuery!.isEmpty)) {
      return _articles;
    }

    return _articles.where((article) {
      bool matchesCategory = _selectedCategory == 'all' ||
          article.categories.contains(_selectedCategory);

      bool matchesSearch = _searchQuery == null ||
          _searchQuery!.isEmpty ||
          article.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
          article.description
              .toLowerCase()
              .contains(_searchQuery!.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _saveCategory(category); // Save the selected category
    notifyListeners();
  }

  Future<void> fetchNews({String? query}) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = query;
    notifyListeners();

    try {
      final response = await _apiService.fetchNews(query: query);
      _articles = response;

      // Update available categories
      _updateAvailableCategories();

      // Update category counts
      NewsCategory.updateCounts(_articles);
    } catch (e) {
      _errorMessage = 'Failed to load news.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update the set of available categories based on current articles
  void _updateAvailableCategories() {
    _availableCategories = {'all'};
    for (var article in _articles) {
      _availableCategories.addAll(article.categories);
    }
  }

  // ✅ BOOKMARK METHODS START HERE

  Box<NewsArticle> get _bookmarkBox => Hive.box<NewsArticle>('bookmarks');

  List<NewsArticle> get bookmarkedArticles => _bookmarkBox.values.toList();

  void toggleBookmark(NewsArticle article) {
    final key = _bookmarkBox.keys.firstWhere(
      (k) => _bookmarkBox.get(k)?.link == article.link,
      orElse: () => null,
    );

    // Update timestamp and stats
    _lastBookmarkAction = DateTime.now();

    if (key != null) {
      // Remove bookmark
      _bookmarkBox.delete(key);

      // Update analytics for removal
      _updateCategoryBookmarkCounts(article, false);
      _bookmarkHistory.remove(article.link);
      _bookmarksRemovedToday++;
    } else {
      // Add bookmark
      _bookmarkBox.add(article);
      _bookmarkCount++;

      // Update analytics for addition
      _updateCategoryBookmarkCounts(article, true);
      _bookmarkHistory[article.link] = DateTime.now();
      _bookmarksAddedToday++;
    }

    _saveBookmarkStats();
    _saveBookmarkAnalytics();
    notifyListeners();
  }

  // Update category bookmark counts when adding/removing bookmarks
  void _updateCategoryBookmarkCounts(NewsArticle article, bool isAdding) {
    for (var category in article.categories) {
      if (isAdding) {
        _categoryBookmarkCounts[category] =
            (_categoryBookmarkCounts[category] ?? 0) + 1;
      } else {
        final currentCount = _categoryBookmarkCounts[category] ?? 0;
        if (currentCount > 0) {
          _categoryBookmarkCounts[category] = currentCount - 1;
        }
      }
    }
  }

  bool isBookmarked(NewsArticle article) {
    return _bookmarkBox.values.any((a) => a.link == article.link);
  }

  // Get recent bookmarks (last 7 days)
  List<NewsArticle> get recentBookmarks {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return bookmarkedArticles.where((article) {
      try {
        final articleDate = DateTime.parse(article.pubDate);
        return articleDate.isAfter(sevenDaysAgo);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get related categories for the current category
  List<String> getRelatedCategories() {
    if (_selectedCategory == 'all' || _getFilteredArticles().isEmpty) {
      return [];
    }

    // Find categories that overlap with current articles
    Set<String> relatedCats = {};
    for (var article in _getFilteredArticles()) {
      for (var category in article.categories) {
        if (category != _selectedCategory) {
          relatedCats.add(category);
        }
      }
    }

    return relatedCats.toList();
  }

  // Get bookmarks by category
  Map<String, int> getBookmarksByCategory() {
    return _categoryBookmarkCounts;
  }

  // Get bookmark trend data - number of bookmarks added per day over last 30 days
  Map<String, int> getBookmarkTrends({int days = 30}) {
    final Map<String, int> dailyBookmarks = {};
    final now = DateTime.now();

    // Initialize all days with zero
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateFormatted =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailyBookmarks[dateFormatted] = 0;
    }

    // Count bookmarks by date added
    for (var entry in _bookmarkHistory.entries) {
      final bookmarkDate = entry.value;
      if (now.difference(bookmarkDate).inDays <= days) {
        final dateFormatted =
            '${bookmarkDate.year}-${bookmarkDate.month.toString().padLeft(2, '0')}-${bookmarkDate.day.toString().padLeft(2, '0')}';
        dailyBookmarks[dateFormatted] =
            (dailyBookmarks[dateFormatted] ?? 0) + 1;
      }
    }

    return dailyBookmarks;
  }

  // Get most bookmarked categories
  List<MapEntry<String, int>> getMostBookmarkedCategories({int limit = 5}) {
    final sortedEntries = _categoryBookmarkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).toList();
  }

  // Get bookmark activity summary
  Map<String, dynamic> getBookmarkActivitySummary() {
    final now = DateTime.now();
    int lastWeekCount = 0;
    int lastMonthCount = 0;

    for (var entry in _bookmarkHistory.entries) {
      final bookmarkDate = entry.value;
      final daysDifference = now.difference(bookmarkDate).inDays;

      if (daysDifference <= 7) {
        lastWeekCount++;
      }

      if (daysDifference <= 30) {
        lastMonthCount++;
      }
    }

    return {
      'today': _bookmarksAddedToday,
      'todayRemoved': _bookmarksRemovedToday,
      'lastWeek': lastWeekCount,
      'lastMonth': lastMonthCount,
      'total': _bookmarkCount,
      'mostRecentBookmark': _lastBookmarkAction,
    };
  }

  // Clear all bookmarks (with analytics update)
  Future<void> clearAllBookmarks() async {
    await _bookmarkBox.clear();
    _bookmarkCount = 0;
    _categoryBookmarkCounts.clear();
    _bookmarkHistory.clear();
    _lastBookmarkAction = DateTime.now();

    // Record in analytics that all bookmarks were removed
    final today = _getTodayFormatted();
    _bookmarksRemovedToday += _bookmarkBox.values.length;

    await _saveBookmarkStats();
    await _saveBookmarkAnalytics();
    notifyListeners();
  }

  // Clear search results and reset to default state
  void clearSearch() {
    _searchQuery = null;
    // Reload news without query
    fetchNews();
  }
}
