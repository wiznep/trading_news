import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool isAppBar;

  const ThemeToggleButton({
    Key? key,
    this.isAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);

    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: isAppBar || isDarkMode ? Colors.white : null,
      ),
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: () {
        themeProvider.toggleTheme();

        // Show a snackbar indicating the theme change
        final snackBar = SnackBar(
          content: Text(
            isDarkMode ? 'Switched to Light Mode' : 'Switched to Dark Mode',
            style: TextStyle(
              color: isDarkMode ? Color(0xFF142045) : Colors.white,
              fontSize: 14,
            ),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: isDarkMode ? Colors.white : Color(0xFF142045),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }
}
