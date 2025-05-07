import 'package:flutter/material.dart';
import '../../data/models/news_category.dart';
import '../providers/news_provider.dart';

class BookmarkAnalytics extends StatelessWidget {
  final NewsProvider provider;

  const BookmarkAnalytics({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get analytics data
    final bookmarksByCategory = provider.getBookmarksByCategory();
    final mostBookmarkedCategory =
        _getMostBookmarkedCategory(bookmarksByCategory);
    final recentBookmarks = provider.recentBookmarks;
    final recentBookmarksCount = recentBookmarks.length;
    final totalBookmarks = provider.bookmarkedArticles.length;

    // No analytics if no bookmarks
    if (totalBookmarks == 0) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Bookmark Insights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInsightTile(
                  context,
                  title: '$totalBookmarks',
                  subtitle: 'Total Saved',
                  icon: Icons.bookmark,
                  color: Colors.blue,
                ),
                _buildInsightTile(
                  context,
                  title: '$recentBookmarksCount',
                  subtitle: 'Last 7 Days',
                  icon: Icons.date_range,
                  color: Colors.green,
                ),
                if (mostBookmarkedCategory != null)
                  _buildInsightTile(
                    context,
                    title: mostBookmarkedCategory.name,
                    subtitle: 'Top Category',
                    icon: Icons.category,
                    color: Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  NewsCategory? _getMostBookmarkedCategory(
      Map<String, int> bookmarksByCategory) {
    if (bookmarksByCategory.isEmpty) return null;

    String? topCategoryId;
    int maxCount = 0;

    bookmarksByCategory.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        topCategoryId = category;
      }
    });

    if (topCategoryId == null) return null;
    return NewsCategory.findById(topCategoryId!);
  }
}
