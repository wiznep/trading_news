import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/index_provider.dart';
import 'market_index_card.dart';
import 'package:intl/intl.dart';

class MarketIndexBar extends StatefulWidget {
  const MarketIndexBar({Key? key}) : super(key: key);

  @override
  State<MarketIndexBar> createState() => _MarketIndexBarState();
}

class _MarketIndexBarState extends State<MarketIndexBar> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final indexProvider = Provider.of<IndexProvider>(context);
    final indices = indexProvider.indices;
    final lastUpdated = indexProvider.lastUpdated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and refresh button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Market Indices',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (indexProvider.isLoading)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  if (lastUpdated != null)
                    Text(
                      'Updated: ${DateFormat.jm().format(lastUpdated)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: indexProvider.isLoading
                        ? null
                        : () => indexProvider.fetchIndices(),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Indices cards
        SizedBox(
          height: 150, // Fixed height based on card size
          child: indexProvider.isLoading && indices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Loading market data...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : indices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart,
                              size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No market data available',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          TextButton(
                            onPressed: () => indexProvider.fetchIndices(),
                            child: const Text('Tap to refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: indices.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      itemBuilder: (context, index) {
                        return MarketIndexCard(
                          index: indices[index],
                          isExpanded: _expandedIndex == index,
                          onTap: () {
                            setState(() {
                              if (_expandedIndex == index) {
                                _expandedIndex = null;
                              } else {
                                _expandedIndex = index;
                              }
                            });
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
