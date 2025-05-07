import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/news_provider.dart';
import '../providers/stock_provider.dart';
import '../../data/models/news_article.dart';

class StockNewsCard extends StatelessWidget {
  final NewsArticle article;
  final Function? onSwipeUp;
  final Function? onSwipeDown;

  const StockNewsCard({
    Key? key,
    required this.article,
    this.onSwipeUp,
    this.onSwipeDown,
  }) : super(key: key);

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final stockProvider = context.watch<StockProvider>();
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _launchUrl(article.link),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News Image with Category Label
            Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: article.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildPlaceholderImage(context),
                          )
                        : _buildPlaceholderImage(context),
                  ),
                ),

                // Source Label
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.source.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Impact Label (if available)
                if (article.stockImpact != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getImpactColor(article.stockImpact!)
                            .withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.stockImpact!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: theme.textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 12),

                  // 60-word summary
                  Text(
                    _formatDescription(article.description),
                    style: theme.textTheme.bodyMedium,
                  ),

                  // Related Stocks (if available)
                  if (article.relatedStocks != null &&
                      article.relatedStocks!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: article.relatedStocks!.map((symbol) {
                          return InkWell(
                            onTap: () {
                              // TODO: Navigate to stock detail page
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: theme.colorScheme.secondary
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                symbol,
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Bottom row with date and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      Text(
                        _formatDate(article.pubDate),
                        style: theme.textTheme.bodySmall,
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
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              newsProvider.toggleBookmark(article);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Swipe indicator
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Tap to read full article',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final theme = Theme.of(context);
    final primaryCategoryId =
        article.categories.isNotEmpty ? article.categories.first : 'all';

    // Different placeholder background colors based on category
    final Map<String, Color> categoryColors = {
      'market_indices': Colors.orange.shade200,
      'stocks': Colors.green.shade200,
      'economy': Colors.purple.shade200,
      'earnings': Colors.teal.shade200,
      'ipo': Colors.red.shade200,
      'corporate_actions': Colors.amber.shade200,
      'm&a': Colors.indigo.shade200,
      'commodities': Colors.brown.shade200,
      'global_markets': Colors.blueGrey.shade200,
      'technology': Colors.deepPurple.shade200,
    };

    final backgroundColor =
        categoryColors[primaryCategoryId] ?? Colors.grey.shade200;

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(primaryCategoryId),
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              primaryCategoryId.toUpperCase().replaceAll('_', ' '),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'market_indices':
        return Icons.show_chart;
      case 'stocks':
        return Icons.trending_up;
      case 'economy':
        return Icons.account_balance;
      case 'earnings':
        return Icons.bar_chart;
      case 'ipo':
        return Icons.add_chart;
      case 'corporate_actions':
        return Icons.announcement;
      case 'm&a':
        return Icons.handshake;
      case 'commodities':
        return Icons.auto_graph;
      case 'global_markets':
        return Icons.public;
      case 'technology':
        return Icons.computer;
      default:
        return Icons.newspaper;
    }
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inHours < 24) {
        if (difference.inHours < 1) {
          return '${difference.inMinutes} min ago';
        }
        return '${difference.inHours} hr ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
