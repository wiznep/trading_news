import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/scrollable_news_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../../data/models/news_article.dart';

class SearchPage extends StatefulWidget {
  final bool searchInBookmarks;

  const SearchPage({
    Key? key,
    this.searchInBookmarks = false,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Popular search terms
  final List<String> _popularSearchTerms = [
    'Nifty',
    'Sensex',
    'RBI',
    'IPO',
    'Bitcoin',
    'Tech stocks',
    'Inflation',
  ];

  @override
  void initState() {
    super.initState();
    // Focus search field when page opens
    Future.microtask(() => FocusScope.of(context).requestFocus(FocusNode()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshSearch() async {
    if (_searchQuery.isEmpty || widget.searchInBookmarks) {
      // No need to refresh if there's no query or searching in bookmarks
      setState(() {});
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Fetch fresh results for the current search query
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    try {
      await newsProvider.fetchNews(query: _searchQuery);
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _handleSearch(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchQuery = query;
        _isSearching = true;
      });

      final newsProvider = Provider.of<NewsProvider>(context, listen: false);

      if (widget.searchInBookmarks) {
        // We don't need to fetch when searching bookmarks
        setState(() {
          _isSearching = false;
        });
      } else {
        // Fetch news with the search query
        newsProvider.fetchNews(query: query).then((_) {
          setState(() {
            _isSearching = false;
          });
        }).catchError((error) {
          setState(() {
            _isSearching = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.searchInBookmarks
                ? 'Search in bookmarks...'
                : 'Search news...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _searchController.clear(),
            ),
          ),
          style: const TextStyle(fontSize: 16),
          onSubmitted: (_) => _handleSearch(context),
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _handleSearch(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search description or popular terms
          if (_searchQuery.isEmpty && !_isSearching)
            _buildSearchSuggestions(context)
          else if (_isSearching)
            _buildLoadingState()
          else
            _buildResultsHeader(_getFilteredResults(newsProvider).length),

          // Results
          Expanded(
            child: _searchQuery.isEmpty && !_isSearching
                ? _buildInitialState()
                : _isSearching
                    ? const SizedBox() // Loading indicator is shown above
                    : _buildSearchResults(_getFilteredResults(newsProvider)),
          ),
        ],
      ),
    );
  }

  // Get results based on whether we're searching in bookmarks or all news
  List<NewsArticle> _getFilteredResults(NewsProvider provider) {
    if (widget.searchInBookmarks) {
      return provider.bookmarkedArticles
          .where((article) =>
              article.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              article.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    } else {
      return provider.articles;
    }
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.searchInBookmarks
                ? 'Search in your bookmarks'
                : 'Popular searches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (!widget.searchInBookmarks)
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: _popularSearchTerms.map((term) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = term;
                    _handleSearch(context);
                  },
                  child: Chip(
                    label: Text(term),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    side: BorderSide.none,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              'Enter keywords to filter your saved articles',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Searching for "$_searchQuery"...',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(int resultCount) {
    final searchLocation = widget.searchInBookmarks ? "bookmarks" : "articles";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        '$resultCount $searchLocation found for "$_searchQuery"',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.searchInBookmarks ? Icons.bookmark_border : Icons.search,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            widget.searchInBookmarks
                ? 'Search your bookmarked articles'
                : 'Search for financial news',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.searchInBookmarks
                ? 'Find articles you\'ve saved for later'
                : 'Try searching for companies, markets, or financial terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<NewsArticle> articles) {
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check for typos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshSearch,
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return ScrollableNewsCard(
            article: articles[index],
            compactMode: true,
          );
        },
      ),
    );
  }
}
