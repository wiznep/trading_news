import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/scrollable_news_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../../data/models/news_category.dart';
import 'search_page.dart';
import '../providers/theme_provider.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sortOption = 'newest'; // Options: newest, oldest, alphabetical
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshBookmarks() async {
    // Force UI refresh by triggering setState
    setState(() {});
    // This returns immediately as bookmarks are stored locally
    // but the pattern is consistent with the home page
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    var bookmarks = newsProvider.bookmarkedArticles;

    // Apply category filter
    if (_selectedCategory != 'all') {
      bookmarks = bookmarks
          .where((article) => article.categories.contains(_selectedCategory))
          .toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      bookmarks = bookmarks
          .where((article) =>
              article.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              article.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'newest':
        bookmarks.sort((a, b) {
          try {
            final dateA = DateTime.parse(a.pubDate);
            final dateB = DateTime.parse(b.pubDate);
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });
        break;
      case 'oldest':
        bookmarks.sort((a, b) {
          try {
            final dateA = DateTime.parse(a.pubDate);
            final dateB = DateTime.parse(b.pubDate);
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0;
          }
        });
        break;
      case 'alphabetical':
        bookmarks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmarks, size: 26, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Bookmarks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Color(0xFF142045), // darkSurfaceColor
                      Color(0xFF1A296B), // darker blue
                    ]
                  : [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withBlue(150),
                    ],
            ),
          ),
        ),
        actions: [
          // Theme Toggle
          const ThemeToggleButton(),
          // Sort button
          IconButton(
            icon: const Icon(Icons.sort, size: 26, color: Colors.white),
            onPressed: () => _showSortOptions(context),
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search, size: 26, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const SearchPage(searchInBookmarks: true)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bookmarks list
          Expanded(
            child: bookmarks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border,
                            size: 70, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory != 'all' || _searchQuery.isNotEmpty
                              ? "No matching bookmarks found"
                              : "No bookmarks yet",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCategory != 'all' || _searchQuery.isNotEmpty
                              ? "Try a different filter or search term"
                              : "Start saving news you like",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refreshBookmarks,
                    color: isDarkMode
                        ? Color(0xFF4F68FF)
                        : Theme.of(context).primaryColor,
                    backgroundColor:
                        isDarkMode ? Color(0xFF192552) : Colors.white,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final article = bookmarks[index];
                        return Dismissible(
                          key: Key(article.link),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(left: 300),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: isDarkMode
                                    ? Color(0xFF142045)
                                    : Colors.white,
                                title: Text(
                                  'Remove Bookmark',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to remove this bookmark?',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Color(0xFF4F68FF)
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            newsProvider.toggleBookmark(article);
                          },
                          child: ScrollableNewsCard(
                            article: article,
                            showSwipeIndicator: false,
                            compactMode: true,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Show sorting options dialog
  void _showSortOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Color(0xFF142045) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'Sort by',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            tileColor: isDarkMode ? Color(0xFF192552) : Colors.grey.shade200,
          ),
          RadioListTile<String>(
            title: Text(
              'Newest first',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            value: 'newest',
            groupValue: _sortOption,
            activeColor:
                isDarkMode ? Color(0xFF4F68FF) : Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() => _sortOption = value!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: Text(
              'Oldest first',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            value: 'oldest',
            groupValue: _sortOption,
            activeColor:
                isDarkMode ? Color(0xFF4F68FF) : Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() => _sortOption = value!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: Text(
              'Alphabetical',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            value: 'alphabetical',
            groupValue: _sortOption,
            activeColor:
                isDarkMode ? Color(0xFF4F68FF) : Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() => _sortOption = value!);
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
