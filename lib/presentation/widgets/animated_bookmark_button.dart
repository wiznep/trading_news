import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../../data/models/news_article.dart';

class AnimatedBookmarkButton extends StatefulWidget {
  final NewsArticle article;
  final Color? color;
  final double size;

  const AnimatedBookmarkButton({
    Key? key,
    required this.article,
    this.color,
    this.size = 20,
  }) : super(key: key);

  @override
  State<AnimatedBookmarkButton> createState() => _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<AnimatedBookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    _isBookmarked = newsProvider.isBookmarked(widget.article);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _controller.forward(from: 0.0);
          newsProvider.toggleBookmark(widget.article);

          // Show feedback
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isBookmarked ? 'Removed from bookmarks' : 'Added to bookmarks',
              ),
              duration: const Duration(seconds: 1),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  newsProvider.toggleBookmark(widget.article);
                },
              ),
            ),
          );
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                size: widget.size,
                color: widget.color ?? Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
