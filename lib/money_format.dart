String formatBrl(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${value < 0 ? '−' : ''}R\$ $whole,${parts.last}';
}
