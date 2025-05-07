import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/news_article.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_bookmark_button.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsArticle article;

  const NewsDetailPage({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool _isLoading = false;
  bool _isRefreshing = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Refresh article data
  Future<void> _refreshArticle() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Fetch news with search query to update the article
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      await newsProvider.fetchNews(query: widget.article.title);

      // Show a snackbar to indicate refresh is complete
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article refreshed'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not refresh article: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);

    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshArticle,
        color: isDarkMode
            ? const Color(0xFF4F68FF)
            : Theme.of(context).primaryColor,
        backgroundColor: isDarkMode ? const Color(0xFF142045) : Colors.white,
        displacement: 40.0,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with image
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: isDarkMode
                  ? const Color(0xFF142045)
                  : Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Article image with gradient overlay
                    widget.article.imageUrl != null
                        ? Image.network(
                            widget.article.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(isDarkMode);
                            },
                          )
                        : _buildPlaceholderImage(isDarkMode),

                    // Gradient overlay for better text visibility
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),

                    // Category chips at top
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 72,
                      right: 16,
                      child: Row(
                        children: [
                          if (widget.article.categories.isNotEmpty)
                            ...widget.article.categories.take(2).map(
                                  (category) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Chip(
                                      label: Text(
                                        category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: Colors.black54,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                          const Spacer(),
                          // Bookmark button
                          AnimatedBookmarkButton(
                            article: widget.article,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    // Title and source at bottom
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 56, // Space for the share button
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.article.source.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                widget.article.source,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Text(
                            widget.article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Share button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.share,
                          color: isDarkMode
                              ? const Color(0xFF142045)
                              : Theme.of(context).primaryColor,
                        ),
                        onPressed: () => _shareArticle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Article content
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.article.pubDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Article description/content
                    Text(
                      widget.article.description,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Related stocks section if available
                    if (widget.article.relatedStocks != null &&
                        widget.article.relatedStocks!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Related Stocks',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.article.relatedStocks!
                                .map(
                                  (stock) => Chip(
                                    label: Text(
                                      stock,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    backgroundColor: isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Impact indicator if available
                    if (widget.article.stockImpact != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market Impact',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildImpactIndicator(
                              widget.article.stockImpact!, isDarkMode),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Read full article button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: isDarkMode
                              ? const Color(0xFF4F68FF)
                              : Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: _isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.launch),
                        label: Text(
                            _isLoading ? 'Opening...' : 'Read Full Article'),
                        onPressed: _isLoading ? null : () => _launchArticle(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    Center(
                      child: Text(
                        'Share this article with your friends',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildShareButton(Icons.share, 'Share', _shareArticle),
                        const SizedBox(width: 16),
                        _buildShareButton(
                          Icons.bookmark,
                          newsProvider.isBookmarked(widget.article)
                              ? 'Bookmarked'
                              : 'Bookmark',
                          () => newsProvider.toggleBookmark(widget.article),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Pull down to refresh article',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.4)
                              : Colors.black38,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build impact indicator
  Widget _buildImpactIndicator(String impact, bool isDarkMode) {
    Color color;
    IconData icon;
    String text;

    switch (impact.toLowerCase()) {
      case 'positive':
        color = Colors.green;
        icon = Icons.trending_up;
        text = 'Positive Impact';
        break;
      case 'negative':
        color = Colors.red;
        icon = Icons.trending_down;
        text = 'Negative Impact';
        break;
      default:
        color = Colors.amber;
        icon = Icons.trending_flat;
        text = 'Neutral Impact';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build share buttons
  Widget _buildShareButton(IconData icon, String label, VoidCallback onTap) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Launch the article URL
  Future<void> _launchArticle() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final uri = Uri.parse(widget.article.link);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open article: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Share the article
  void _shareArticle() {
    Share.share(
      '${widget.article.title}\n\nRead more: ${widget.article.link}',
      subject: widget.article.title,
    );
  }

  // Format the date
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  // Build placeholder image
  Widget _buildPlaceholderImage(bool isDarkMode) {
    return Container(
      color: isDarkMode ? const Color(0xFF1A296B) : Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image,
          size: 80,
          color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
        ),
      ),
    );
  }
}
