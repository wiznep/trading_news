import 'package:flutter/material.dart';
import '../../data/models/news_category.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: NewsCategory.categories.length,
        itemBuilder: (context, index) {
          final category = NewsCategory.categories[index];
          final isSelected = category.id == selectedCategory;

          // Determine appropriate colors based on category and selection state
          final LinearGradient gradient = isSelected
              ? _getGradientForCategory(category.id, context)
              : LinearGradient(
                  colors: [Colors.grey.shade100, Colors.grey.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );

          return Hero(
            tag: 'category_${category.id}',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Chip
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onCategoryChanged(category.id),
                      borderRadius: BorderRadius.circular(24),
                      splashColor:
                          Theme.of(context).primaryColor.withOpacity(0.3),
                      highlightColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category.icon,
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.name,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            // Count badge
                            if (category.count > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.3)
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  category.count.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Indicator Line
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(top: 6),
                    height: 3,
                    width: isSelected ? 30 : 0,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  LinearGradient _getGradientForCategory(
      String categoryId, BuildContext context) {
    // Define category-specific gradients for visual distinction
    switch (categoryId) {
      case 'market':
        return const LinearGradient(
          colors: [Color(0xFF1A76D2), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'stocks':
        return const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'economy':
        return const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'crypto':
        return const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFB8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ipo':
        return const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'tech':
        return const LinearGradient(
          colors: [Color(0xFF00ACC1), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'trending':
        return const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFD84315)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'global':
        return const LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'results':
        return const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'all':
      default:
        return LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withBlue(150)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
