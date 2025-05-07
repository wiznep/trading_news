import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../../data/models/news_article.dart';
import 'package:share_plus/share_plus.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({Key? key, required this.article}) : super(key: key);

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // News Image (placeholder if none available)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?q=80&w=1000',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // 60-word summary
                Text(
                  _formatDescription(article.description),
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 16),

                // Bottom row with date and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date
                    Text(
                      _formatDate(article.pubDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    // Actions
                    Row(
                      children: [
                        // Share button
                        IconButton(
                          icon: const Icon(Icons.share, size: 20),
                          onPressed: () {
                            Share.share(
                              '${article.title}\n\nRead more: ${article.link}',
                              subject: article.title,
                            );
                          },
                        ),

                        // Bookmark button
                        IconButton(
                          icon: Icon(
                            newsProvider.isBookmarked(article)
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            size: 20,
                            color: Colors.indigo,
                          ),
                          onPressed: () {
                            newsProvider.toggleBookmark(article);
                          },
                        ),

                        // Read more button
                        TextButton(
                          child: const Text('Read more'),
                          onPressed: () => _launchUrl(article.link),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDescription(String description) {
    // Limit to ~60 words
    const maxWords = 60;
    final words = description.split(' ');
    if (words.length <= maxWords) return description;

    return '${words.take(maxWords).join(' ')}...';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
