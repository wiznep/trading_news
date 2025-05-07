import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BookmarkAnalyticsPage extends StatelessWidget {
  const BookmarkAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final activitySummary = newsProvider.getBookmarkActivitySummary();
    final mostBookmarkedCategories = newsProvider.getMostBookmarkedCategories();
    final bookmarkTrends = newsProvider.getBookmarkTrends(days: 14);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context, activitySummary),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Bookmark Trends'),
            const SizedBox(height: 8),
            _buildTrendsChart(context, bookmarkTrends),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Most Bookmarked Categories'),
            const SizedBox(height: 8),
            _buildCategoriesChart(context, mostBookmarkedCategories),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Category Distribution'),
            const SizedBox(height: 8),
            _buildCategoryList(context, newsProvider.categoryBookmarkCounts),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Map<String, dynamic> summary) {
    final theme = Theme.of(context);

    String lastBookmarkText = 'Never';
    if (summary['mostRecentBookmark'] != null) {
      final DateTime date = summary['mostRecentBookmark'];
      lastBookmarkText = DateFormat.yMMMd().add_jm().format(date);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bookmark Activity Summary',
              style: theme.textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Total Bookmarks',
              '${summary['total']}',
              Icons.bookmark,
            ),
            _buildSummaryRow(
              context,
              'Today',
              '+${summary['today']} / -${summary['todayRemoved']}',
              Icons.today,
            ),
            _buildSummaryRow(
              context,
              'Last 7 Days',
              '${summary['lastWeek']}',
              Icons.calendar_today,
            ),
            _buildSummaryRow(
              context,
              'Last 30 Days',
              '${summary['lastMonth']}',
              Icons.date_range,
            ),
            _buildSummaryRow(
              context,
              'Last Bookmark',
              lastBookmarkText,
              Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTrendsChart(BuildContext context, Map<String, int> trends) {
    final theme = Theme.of(context);

    // Sort the data by date
    final sortedDates = trends.keys.toList()..sort((a, b) => a.compareTo(b));

    // Create bar chart data
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final count = trends[date] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: theme.primaryColor,
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    // Format dates for display
    final dateLabels = sortedDates.map((dateStr) {
      try {
        final parts = dateStr.split('-');
        return '${parts[1]}/${parts[2]}';
      } catch (_) {
        return dateStr;
      }
    }).toList();

    return SizedBox(
      height: 200,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (trends.values.isEmpty
                      ? 0
                      : trends.values.reduce((a, b) => a > b ? a : b) + 1)
                  .toDouble(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black54,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} bookmarks\n${dateLabels[group.x.toInt()]}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 2 != 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dateLabels[value.toInt()],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesChart(
    BuildContext context,
    List<MapEntry<String, int>> categories,
  ) {
    final theme = Theme.of(context);

    // Create data for pie chart
    final totalBookmarks =
        categories.fold<int>(0, (sum, entry) => sum + entry.value);

    final sections = <PieChartSectionData>[];
    final colorList = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < categories.length; i++) {
      final entry = categories[i];
      final percentage = totalBookmarks > 0
          ? (entry.value / totalBookmarks * 100).toStringAsFixed(1)
          : '0';

      sections.add(
        PieChartSectionData(
          color: colorList[i % colorList.length],
          value: entry.value.toDouble(),
          title: '$percentage%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      enabled: true,
                      touchCallback: (_, __) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < categories.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colorList[i % colorList.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                categories[i].key,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              categories[i].value.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, Map<String, int> categories) {
    final theme = Theme.of(context);

    // Sort categories by bookmark count (descending)
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final entry = sortedCategories[index];

          return ListTile(
            title: Text(entry.key),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                entry.value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
