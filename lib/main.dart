import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'controllers/finance_controller.dart';
import 'controllers/market_controller.dart';
import 'main_shell.dart';
import 'services/local_repository.dart';
import 'services/quote_repository.dart';

void main() => runApp(const MyFinanceApp());

class MyFinanceApp extends StatefulWidget {
  const MyFinanceApp({super.key, this.httpClient, this.localRepository});
  final http.Client? httpClient;
  final LocalRepository? localRepository;

  @override
  State<MyFinanceApp> createState() => _MyFinanceAppState();
}

class _MyFinanceAppState extends State<MyFinanceApp> {
  late final http.Client _client = widget.httpClient ?? http.Client();
  late final MarketController _market = MarketController(
    QuoteRepository(_client),
  )..load();
  late final FinanceController _finance = FinanceController(
    widget.localRepository ??
        SharedPreferencesRepository(SharedPreferencesAsync()),
  )..load();
  final _lightTheme = buildFinanceTheme(Brightness.light);
  final _darkTheme = buildFinanceTheme(Brightness.dark);

  @override
  void dispose() {
    _market.dispose();
    _finance.dispose();
    if (widget.httpClient == null) _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: _market),
      ChangeNotifierProvider.value(value: _finance),
    ],
    child: Selector<FinanceController, bool>(
      selector: (_, finance) => finance.darkMode,
      builder: (_, darkMode, _) => MaterialApp(
        title: 'MyFinance',
        debugShowCheckedModeBanner: false,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        themeAnimationDuration: Duration.zero,
        home: const MainShell(),
      ),
    ),
  );
}
