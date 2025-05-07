import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/news_provider.dart';
import '../../data/models/news_category.dart';

class NewCategoryFilter extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final bool showCounts;

  const NewCategoryFilter({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.showCounts = true,
  }) : super(key: key);

  @override
  State<NewCategoryFilter> createState() => _NewCategoryFilterState();
}

class _NewCategoryFilterState extends State<NewCategoryFilter>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void didUpdateWidget(NewCategoryFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to selected category when it changes
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _scrollToSelectedCategory();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToSelectedCategory() {
    // Find the index of the selected category
    final categories = NewsCategory.categories;
    final selectedIndex =
        categories.indexWhere((c) => c.id == widget.selectedCategory);

    if (selectedIndex >= 0 && _scrollController.hasClients) {
      // Calculate position to scroll to
      final estimatedItemWidth =
          130.0; // Approximate width of each category item
      final screenWidth = MediaQuery.of(context).size.width;
      final offset = (selectedIndex * estimatedItemWidth) -
          (screenWidth / 2) +
          (estimatedItemWidth / 2);

      // Ensure offset is within bounds
      final maxOffset = _scrollController.position.maxScrollExtent;
      final minOffset = _scrollController.position.minScrollExtent;
      final safeOffset = offset.clamp(minOffset, maxOffset);

      // Scroll with animation
      _scrollController.animateTo(
        safeOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final newsProvider = Provider.of<NewsProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    final categories = NewsCategory.categories;
    final isLoading =
        newsProvider.isLoading && categories.where((c) => c.count > 0).isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filter header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter News',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              if (isLoading) _buildLoadingIndicator(isDarkMode),
            ],
          ),
        ),

        // Category pills
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: isLoading
              ? _buildLoadingCategories(isDarkMode)
              : ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == widget.selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => widget.onCategoryChanged(category.id),
                            borderRadius: BorderRadius.circular(25),
                            splashColor: category.color.withOpacity(0.3),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category.color
                                        .withOpacity(isDarkMode ? 0.8 : 1.0)
                                    : isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: isDarkMode
                                            ? Colors.white12
                                            : Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: category.color.withOpacity(
                                              isDarkMode ? 0.4 : 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category.icon,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : isDarkMode
                                            ? Colors.white70
                                            : category.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Count badge
                                  if (widget.showCounts && category.count > 0)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.3)
                                            : isDarkMode
                                                ? Colors.white.withOpacity(0.15)
                                                : category.color
                                                    .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        category.count.toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? Colors.white
                                              : isDarkMode
                                                  ? Colors.white
                                                  : category.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Active category indicator line
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isDarkMode) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? Colors.white70 : Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCategories(bool isDarkMode) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5, // Show 5 shimmer items
      itemBuilder: (context, index) {
        final double width =
            80.0 + (index * 20) % 40; // Varied widths for visual appeal

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ShimmerCategoryItem(
            width: width,
            isDarkMode: isDarkMode,
            animation: _animationController,
          ),
        );
      },
    );
  }
}

class ShimmerCategoryItem extends StatelessWidget {
  final double width;
  final bool isDarkMode;
  final AnimationController animation;

  const ShimmerCategoryItem({
    Key? key,
    required this.width,
    required this.isDarkMode,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Create the shimmer effect
        final shimmerGradient = LinearGradient(
          colors: isDarkMode
              ? [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  Colors.grey.withOpacity(0.05),
                  Colors.grey.withOpacity(0.1),
                  Colors.grey.withOpacity(0.05),
                ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0 + 2.0 * animation.value, 0.0),
          end: Alignment(1.0 + 2.0 * animation.value, 0.0),
        );

        return Container(
          width: width,
          height: 36,
          decoration: BoxDecoration(
            gradient: shimmerGradient,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        );
      },
    );
  }
}
