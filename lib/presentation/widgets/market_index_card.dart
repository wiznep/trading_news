import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/market_index.dart';

class MarketIndexCard extends StatelessWidget {
  final MarketIndex index;
  final bool isExpanded;
  final VoidCallback? onTap;

  const MarketIndexCard({
    Key? key,
    required this.index,
    this.isExpanded = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format numbers with commas and proper decimal places
    final NumberFormat formatter = NumberFormat.decimalPattern();
    final currencyFormatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: index.name.contains('VIX') ? 2 : 1,
    );

    // Time formatting
    final timeFormatter = DateFormat('h:mm a');

    // Create a gradient background based on whether the index is positive or negative
    final Color primaryColor =
        index.isPositive ? Colors.green.shade600 : Colors.red.shade600;
    final Color secondaryColor =
        index.isPositive ? Colors.green.shade800 : Colors.red.shade800;
    final TextStyle valueStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index name row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        index.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Exchange badge
                    if (index.exchange.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          index.exchange,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Main value
                Row(
                  children: [
                    Icon(
                      index.isPositive
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currencyFormatter.format(index.currentValue),
                      style: valueStyle,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Change value and percentage
                Text(
                  '${index.isPositive ? "+" : ""}${currencyFormatter.format(index.change)} (${index.isPositive ? "+" : ""}${index.changePercentage.toStringAsFixed(2)}%)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Expanded details
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white30, height: 1),
                  const SizedBox(height: 10),

                  // High/Low
                  _buildDataRow(
                    'Day Range:',
                    '${currencyFormatter.format(index.dayLow)} - ${currencyFormatter.format(index.dayHigh)}',
                  ),

                  _buildDataRow(
                    'Prev Close:',
                    currencyFormatter.format(index.previousClose),
                  ),

                  if (index.volume > 0)
                    _buildDataRow(
                      'Volume:',
                      formatter.format(index.volume),
                    ),
                ],

                // Last updated
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Updated: ${timeFormatter.format(index.lastUpdated)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
