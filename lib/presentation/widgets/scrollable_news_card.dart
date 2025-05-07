import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../../data/models/news_article.dart';
import 'package:share_plus/share_plus.dart';
import 'animated_bookmark_button.dart';
import '../pages/news_detail_page.dart';

class ScrollableNewsCard extends StatelessWidget {
  final NewsArticle article;
  final ScrollPhysics physics;
  final bool showSwipeIndicator;
  final bool compactMode;

  const ScrollableNewsCard({
    Key? key,
    required this.article,
    // This allows us to control the scroll physics from parent
    this.physics = const ClampingScrollPhysics(),
    this.showSwipeIndicator = false,
    this.compactMode = false,
  }) : super(key: key);

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();

    // Use SingleChildScrollView to make the content scrollable
    return SingleChildScrollView(
      // The physics parameter controls how scrolling behaves
      physics: physics,
      child: Column(
        children: [
          // The main card with news content
          InkWell(
            onTap: () {
              // Navigate to the news detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(article: article),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // News Image (placeholder if none available)
                  if (!compactMode)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: article.imageUrl != null
                                ? Image.network(
                                    article.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultImage();
                                    },
                                  )
                                : _buildDefaultImage(),
                          ),
                        ),
                        // Category tags
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Row(
                            children: article.categories
                                .take(2)
                                .map((category) => Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        // Bookmark button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: AnimatedBookmarkButton(
                              article: article,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),

                  Padding(
                    padding: EdgeInsets.all(compactMode ? 12.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with category tags for compact mode
                        if (compactMode)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Wrap(
                              spacing: 8,
                              children: article.categories
                                  .take(2)
                                  .map((category) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),

                        // Title
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: compactMode ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: compactMode ? 2 : null,
                          overflow: compactMode
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                        ),

                        SizedBox(height: compactMode ? 4 : 8),

                        // Description - shorter in compact mode
                        if (!compactMode)
                          Text(
                            article.description,
                            style: const TextStyle(fontSize: 14),
                          )
                        else
                          Text(
                            article.description,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        SizedBox(height: compactMode ? 8 : 16),

                        // Bottom row with date and actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Source and Date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (article.source.isNotEmpty && !compactMode)
                                  Text(
                                    article.source,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  _formatDate(article.pubDate),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: compactMode ? 10 : 12,
                                  ),
                                ),
                              ],
                            ),

                            // Actions
                            Row(
                              children: [
                                // Bookmark button for compact mode
                                if (compactMode)
                                  IconButton(
                                    icon: Icon(
                                      newsProvider.isBookmarked(article)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: 20,
                                      color: Colors.indigo,
                                    ),
                                    onPressed: () {
                                      newsProvider.toggleBookmark(article);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),

                                // Share button
                                IconButton(
                                  icon: const Icon(Icons.share, size: 20),
                                  onPressed: () {
                                    Share.share(
                                      '${article.title}\n\nRead more: ${article.link}',
                                      subject: article.title,
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                ),
                                SizedBox(width: 8),

                                // Read more button
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: Text(compactMode ? '' : 'Read more'),
                                  onPressed: () {
                                    // Navigate to detail page instead of launching URL
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NewsDetailPage(article: article),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: compactMode
                                        ? const EdgeInsets.all(4)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                  ),
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
            ),
          ),

          // Add some extra space at the bottom to make it clear there's more to scroll
          const SizedBox(height: 40),

          // Swipe hint at the bottom - only show if the flag is true
          if (showSwipeIndicator)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_downward,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe for next news',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
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
