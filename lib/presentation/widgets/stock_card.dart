import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/stock.dart';
import '../providers/stock_provider.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final bool showActions;
  final bool compact;
  final Function? onTap;

  const StockCard({
    Key? key,
    required this.stock,
    this.showActions = true,
    this.compact = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stockProvider = context.watch<StockProvider>();
    final isInWatchlist = stockProvider.isInWatchlist(stock.symbol);

    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 16,
          vertical: compact ? 4 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Symbol, name and watchlist
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stock symbol and name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.symbol,
                          style: TextStyle(
                            fontSize: compact ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (!compact)
                          Text(
                            stock.name,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Watchlist button
                  if (showActions)
                    IconButton(
                      icon: Icon(
                        isInWatchlist ? Icons.star : Icons.star_border,
                        color: isInWatchlist
                            ? Colors.amber
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () {
                        if (isInWatchlist) {
                          stockProvider.removeFromWatchlist(stock.symbol);
                        } else {
                          stockProvider.addToWatchlist(stock.symbol);
                        }
                      },
                    ),
                ],
              ),

              SizedBox(height: compact ? 8 : 16),

              // Price and change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${stock.currentPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: compact ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        stock.isPositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: stock.isPositive ? Colors.green : Colors.red,
                        size: compact ? 16 : 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stock.isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)} '
                        '(${stock.isPositive ? '+' : ''}${stock.changePercentage.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: stock.isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (!compact) ...[
                const SizedBox(height: 16),

                // Additional stock data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDataItem(
                        'Open', '₹${stock.openPrice.toStringAsFixed(2)}'),
                    _buildDataItem(
                        'High', '₹${stock.dayHigh.toStringAsFixed(2)}'),
                    _buildDataItem(
                        'Low', '₹${stock.dayLow.toStringAsFixed(2)}'),
                  ],
                ),

                const SizedBox(height: 8),

                // More stock data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDataItem(
                        'P/E', stock.pe?.toStringAsFixed(2) ?? 'N/A'),
                    _buildDataItem('Volume', _formatLargeNumber(stock.volume)),
                    _buildDataItem('Sector', stock.sector),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatLargeNumber(int number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toString();
  }
}
