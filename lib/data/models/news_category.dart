import 'package:flutter/material.dart';

class NewsCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  int count; // To store the number of articles in this category

  NewsCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.description = '',
    this.count = 0,
  });

  static List<NewsCategory> get categories => [
        NewsCategory(
          id: 'all',
          name: 'All News',
          icon: Icons.newspaper,
          color: Colors.blue,
          description: 'All stock market news from various sources',
        ),
        NewsCategory(
          id: 'market_indices',
          name: 'Indices',
          icon: Icons.show_chart,
          color: Colors.orange,
          description: 'Updates on Nifty, Sensex and other market indices',
        ),
        NewsCategory(
          id: 'stocks',
          name: 'Stocks',
          icon: Icons.trending_up,
          color: Colors.green,
          description: 'News about individual stocks and equities',
        ),
        NewsCategory(
          id: 'economy',
          name: 'Economy',
          icon: Icons.account_balance,
          color: Colors.purple,
          description: 'Economic updates, RBI policies, interest rates',
        ),
        NewsCategory(
          id: 'earnings',
          name: 'Earnings',
          icon: Icons.bar_chart,
          color: Colors.teal,
          description: 'Corporate earnings, results, profits and revenues',
        ),
        NewsCategory(
          id: 'ipo',
          name: 'IPOs',
          icon: Icons.add_chart,
          color: Colors.red,
          description: 'Upcoming IPOs, listings and public offers',
        ),
        NewsCategory(
          id: 'corporate_actions',
          name: 'Corp Actions',
          icon: Icons.announcement,
          color: Colors.amber,
          description: 'Dividends, bonuses, stock splits and other actions',
        ),
        NewsCategory(
          id: 'm&a',
          name: 'M&A',
          icon: Icons.handshake,
          color: Colors.indigo,
          description: 'Mergers, acquisitions and corporate takeovers',
        ),
        NewsCategory(
          id: 'commodities',
          name: 'Commodities',
          icon: Icons.auto_graph,
          color: Colors.brown,
          description: 'Updates on gold, silver, oil and other commodities',
        ),
        NewsCategory(
          id: 'global_markets',
          name: 'Global',
          icon: Icons.public,
          color: Colors.blueGrey,
          description: 'International market news affecting Indian markets',
        ),
        NewsCategory(
          id: 'technology',
          name: 'Tech',
          icon: Icons.computer,
          color: Colors.deepPurple,
          description: 'Technology news impacting stock markets',
        ),
        NewsCategory(
          id: 'market_calls',
          name: 'Expert Calls',
          icon: Icons.person,
          color: Colors.cyan,
          description: 'Expert opinions, buy/sell calls from analysts',
        ),
        NewsCategory(
          id: 'regulations',
          name: 'Regulations',
          icon: Icons.gavel,
          color: Colors.deepOrange,
          description: 'SEBI regulations, compliance and governance news',
        ),
      ];

  static NewsCategory getCategoryById(String id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => NewsCategory(
        id: id,
        name: id.toUpperCase(),
        icon: Icons.label,
        color: Colors.grey,
      ),
    );
  }

  static List<NewsCategory> getCategoriesFromIds(List<String> ids) {
    if (ids.isEmpty) return [getCategoryById('all')];
    return ids.map((id) => getCategoryById(id)).toList();
  }

  // Update counts for all categories based on articles
  static void updateCounts(List<dynamic> articles) {
    // Reset all counts
    for (var category in categories) {
      category.count = 0;
    }

    // Set 'all' category count
    if (categories.isNotEmpty) {
      categories.first.count = articles.length;
    }

    // Count articles per category
    for (var article in articles) {
      if (article.categories != null) {
        for (var categoryId in article.categories) {
          final category = getCategoryById(categoryId);
          if (category.id != 'all') {
            category.count++;
          }
        }
      }
    }
  }
}
