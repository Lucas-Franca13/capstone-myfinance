import 'package:flutter/foundation.dart';
import '../market_data.dart';
import '../services/quote_repository.dart';

enum MarketStatus { loading, ready, error }

class MarketController extends ChangeNotifier {
  MarketController(this.repository);
  final QuoteRepository repository;
  MarketStatus status = MarketStatus.loading;
  List<MarketQuote> quotes = [];
  String? message;
  Future<void> load() async {
    status = MarketStatus.loading;
    message = null;
    notifyListeners();
    try {
      quotes = await repository.loadQuotes();
      status = MarketStatus.ready;
    } catch (error) {
      status = MarketStatus.error;
      message = '$error';
    }
    notifyListeners();
  }
}
