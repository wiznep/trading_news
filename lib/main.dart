import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/news_article.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/providers/news_provider.dart';
import 'presentation/providers/index_provider.dart';
import 'presentation/providers/stock_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NewsArticleAdapter());
  await Hive.openBox<NewsArticle>('bookmarks');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsProvider()..fetchNews()),
        ChangeNotifierProvider(create: (_) => IndexProvider()..fetchIndices()),
        ChangeNotifierProvider(create: (_) => StockProvider()..fetchStocks()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TradeFlash - Indian Stock Market News',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
