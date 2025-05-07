import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/index_provider.dart';
import '../widgets/scrollable_news_card.dart';
import '../widgets/new_category_filter.dart';
import '../widgets/theme_toggle_button.dart';
import '../../data/models/news_category.dart';
import 'search_page.dart';
import '../widgets/market_index_bar.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late IndexProvider indexProvider;
  late NewsProvider newsProvider;
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    Future.microtask(() {
      indexProvider = Provider.of<IndexProvider>(context, listen: false);
      newsProvider = Provider.of<NewsProvider>(context, listen: false);

      // Initial fetch
      indexProvider.fetchIndices();
      newsProvider.fetchNews();

      // Auto-refresh index data every 1 min
      Timer.periodic(const Duration(minutes: 1), (_) {
        indexProvider.fetchIndices();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Refresh both news and indices data
    await Future.wait([
      newsProvider.fetchNews(),
      indexProvider.fetchIndices(),
    ]);

    // Reset to first page when refreshing
    if (_pageController.hasClients && _currentPage != 0) {
      _pageController.jumpToPage(0);
      setState(() {
        _currentPage = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final indexProvider = Provider.of<IndexProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    final filteredArticles = newsProvider.articles;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, size: 26, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'TradeFlash',
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
          // Search Button
          IconButton(
            icon: const Icon(Icons.search, size: 26, color: Colors.white),
            onPressed: () {
              // Navigate to search page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Market Index Bar
          const MarketIndexBar(),

          // Category selector
          if (newsProvider.articles.isNotEmpty ||
              newsProvider.selectedCategory != 'all')
            Column(
              children: [
                NewCategoryFilter(
                  selectedCategory: newsProvider.selectedCategory,
                  onCategoryChanged: (category) {
                    // Animate the category change
                    _animationController.forward(from: 0.0);

                    newsProvider.setCategory(category);
                    // Reset to first page when changing category
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(0);
                    }
                    setState(() {
                      _currentPage = 0;
                    });
                  },
                ),

                // Show related categories if current category has no articles
                if (filteredArticles.isEmpty &&
                    newsProvider.selectedCategory != 'all')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildRelatedCategoriesSuggestion(
                        context, newsProvider),
                  ),
              ],
            ),

          // News Section with PageView for swiping
          Expanded(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeIn,
              ).drive(Tween<double>(begin: 1.0, end: 1.0)),
              child: newsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : newsProvider.errorMessage != null
                      ? Center(child: Text(newsProvider.errorMessage!))
                      : filteredArticles.isEmpty &&
                              newsProvider.selectedCategory == 'all'
                          ? const Center(child: Text("No news articles found."))
                          : filteredArticles.isEmpty
                              ? _buildEmptyCategoryView(context, newsProvider)
                              : RefreshIndicator(
                                  key: _refreshIndicatorKey,
                                  onRefresh: _refreshData,
                                  color: Theme.of(context).primaryColor,
                                  backgroundColor: Colors.white,
                                  displacement: 40.0,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: filteredArticles.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentPage = index;
                                      });
                                    },
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      final article = filteredArticles[index];
                                      // Set NeverScrollableScrollPhysics to allow swiping between pages
                                      // But disable scrolling until the user interacts with the content
                                      return NotificationListener<
                                          ScrollUpdateNotification>(
                                        onNotification: (notification) {
                                          // When scrolling up at the top edge, transition to the previous card
                                          if (notification.scrollDelta! < 0 &&
                                              notification.metrics.pixels ==
                                                  notification.metrics
                                                      .minScrollExtent) {
                                            _pageController.previousPage(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          }

                                          // When scrolling down at the bottom edge, transition to the next card
                                          if (notification.scrollDelta! > 0 &&
                                              notification.metrics.pixels ==
                                                  notification.metrics
                                                      .maxScrollExtent) {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          }

                                          return false;
                                        },
                                        child: ScrollableNewsCard(
                                          article: article,
                                          // Use interactive scroll physics to make scrolling feel natural
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          showSwipeIndicator: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display when a category has no articles
  Widget _buildEmptyCategoryView(
      BuildContext context, NewsProvider newsProvider) {
    final categoryName =
        NewsCategory.getCategoryById(newsProvider.selectedCategory).name;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No articles in $categoryName',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Go to All News'),
            onPressed: () {
              newsProvider.setCategory('all');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to suggest related categories
  Widget _buildRelatedCategoriesSuggestion(
      BuildContext context, NewsProvider newsProvider) {
    final relatedCategories = newsProvider.getRelatedCategories();

    if (relatedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Suggested Categories:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: relatedCategories.take(3).map((categoryId) {
              final category = NewsCategory.getCategoryById(categoryId);
              return ActionChip(
                avatar: Icon(category.icon, size: 16),
                label: Text(category.name),
                onPressed: () {
                  newsProvider.setCategory(categoryId);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
