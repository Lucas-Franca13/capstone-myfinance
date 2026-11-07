import 'dart:convert';
import 'package:http/http.dart' as http;
import '../market_data.dart';

class QuoteRepository {
  QuoteRepository(this.client);
  final http.Client client;
  static final Uri endpoint = Uri.https(
    'economia.awesomeapi.com.br',
    '/json/last/USD-BRL,EUR-BRL,BTC-BRL',
  );
  static final Uri documentation = Uri.https(
    'docs.awesomeapi.com.br',
    '/api-de-moedas',
  );
  Future<List<MarketQuote>> loadQuotes() async {
    try {
      final response = await client
          .get(endpoint)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Formato inválido da API.');
      }
      return ['USD', 'EUR', 'BTC'].map((code) {
        final raw = decoded['${code}BRL'];
        if (raw is! Map<String, dynamic>) {
          throw FormatException('Cotação $code ausente.');
        }
        return MarketQuote.fromApi(code, raw);
      }).toList();
    } catch (_) {
      throw Exception(
        'Não foi possível carregar as cotações. Verifique a conexão e tente novamente.',
      );
    }
  }
}
