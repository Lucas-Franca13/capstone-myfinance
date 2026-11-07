import 'package:flutter/material.dart';
import 'money_format.dart';

class MarketQuote {
  const MarketQuote({
    required this.code,
    required this.name,
    required this.value,
    required this.changePercent,
    required this.updatedAt,
  });
  final String code;
  final String name;
  final double value;
  final double changePercent;
  final DateTime updatedAt;
  String get price => formatBrl(value);
  String get change {
    if (changePercent.abs() < 0.005) return '0,00%';
    return '${changePercent > 0 ? '+' : ''}${changePercent.toStringAsFixed(2).replaceAll('.', ',')}%';
  }

  bool get isNegative => changePercent <= -0.005;
  bool get isNeutral => changePercent.abs() < 0.005;
  IconData get icon => switch (code) {
    'USD' => Icons.attach_money,
    'EUR' => Icons.euro,
    'BTC' => Icons.currency_bitcoin,
    _ => Icons.currency_exchange,
  };
  String get description =>
      'Cotação de $name em reais, consultada na AwesomeAPI.';

  factory MarketQuote.fromApi(String code, Map<String, dynamic> json) {
    final value = double.tryParse('${json['bid']}');
    final change = double.tryParse('${json['pctChange']}');
    final timestamp = int.tryParse('${json['timestamp']}');
    if (value == null ||
        !value.isFinite ||
        value <= 0 ||
        change == null ||
        !change.isFinite ||
        timestamp == null) {
      throw const FormatException('Resposta incompleta da API de cotações.');
    }
    return MarketQuote(
      code: code,
      name: switch (code) {
        'USD' => 'Dólar americano',
        'EUR' => 'Euro',
        'BTC' => 'Bitcoin',
        _ => code,
      },
      value: value,
      changePercent: change,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }
}
