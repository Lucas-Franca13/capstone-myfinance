import 'package:flutter/material.dart';
import 'money_format.dart';

class FinanceEntry {
  const FinanceEntry({
    required this.title,
    required this.category,
    required this.value,
    required this.isIncome,
    required this.createdAt,
  });
  final String title;
  final String category;
  final double value;
  final bool isIncome;
  final DateTime createdAt;
  String get subtitle => '${isIncome ? 'Receita' : 'Despesa'} · $category';
  String get amount => '${isIncome ? '+' : '−'} ${formatBrl(value)}';
  IconData get icon => isIncome ? Icons.south_west : Icons.north_east;
  String get date =>
      '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  String get note => 'Transação registrada neste dispositivo.';
  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'value': value,
    'isIncome': isIncome,
    'createdAt': createdAt.toIso8601String(),
  };
  factory FinanceEntry.fromJson(Map<String, dynamic> json) => FinanceEntry(
    title: json['title'] as String,
    category: json['category'] as String,
    value: (json['value'] as num).toDouble(),
    isIncome: json['isIncome'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class FinanceDocument {
  const FinanceDocument(this.title, this.subtitle, this.icon, this.detail);
  final String title;
  final String subtitle;
  final IconData icon;
  final String detail;
}

const documents = <FinanceDocument>[
  FinanceDocument(
    'Holerite de outubro',
    'Trabalho · 2026',
    Icons.description_outlined,
    'Documento demonstrativo: salário, descontos e valor líquido.',
  ),
  FinanceDocument(
    'Espelho de ponto',
    'Horas · outubro 2026',
    Icons.schedule_outlined,
    'Documento demonstrativo: horas trabalhadas e banco de horas.',
  ),
  FinanceDocument(
    'Informe de rendimentos',
    'Imposto de renda · 2025',
    Icons.receipt_long_outlined,
    'Documento demonstrativo: rendimentos do ano-base.',
  ),
];
