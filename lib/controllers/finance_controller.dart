import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../demo_data.dart';
import '../services/local_repository.dart';

class FinanceController extends ChangeNotifier {
  FinanceController(this.repository);
  final LocalRepository repository;
  bool loading = true;
  bool hideBalance = false;
  bool darkMode = false;
  double? budget;
  List<FinanceEntry> entries = [];
  Set<String> favorites = {};
  String? error;
  Future<void>? _loadFuture;
  Future<void> load() => _loadFuture ??= _load();
  Future<void> _load() async {
    try {
      favorites = (await repository.getStringList('favorites')).toSet();
      hideBalance = await repository.getBool('hideBalance');
      darkMode = await repository.getBool('darkMode');
      budget = await repository.getDouble('budget');
      entries = (await repository.getStringList('entries'))
          .map(
            (item) =>
                FinanceEntry.fromJson(jsonDecode(item) as Map<String, dynamic>),
          )
          .toList();
      error = null;
    } catch (_) {
      error = 'Não foi possível ler os dados salvos neste dispositivo.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  double get balance => entries.fold(
    0,
    (sum, entry) => sum + (entry.isIncome ? entry.value : -entry.value),
  );

  Future<void> _saveEntries(List<FinanceEntry> value) =>
      repository.setStringList(
        'entries',
        value.map((item) => jsonEncode(item.toJson())).toList(),
      );

  Future<void> addEntry(FinanceEntry entry) async {
    await load();
    if (error != null) throw StateError(error!);
    final updated = [entry, ...entries];
    await _saveEntries(updated);
    entries = updated;
    notifyListeners();
  }

  /// Remove da memória antes do primeiro `await`: o `Dismissible` exige que
  /// o item saia da árvore no mesmo frame. Retorna a posição para restauração.
  Future<int> removeEntry(FinanceEntry entry) async {
    if (error != null) throw StateError(error!);
    final index = entries.indexOf(entry);
    if (index < 0) return index;
    entries = [...entries]..removeAt(index);
    notifyListeners();
    try {
      await _saveEntries(entries);
    } catch (_) {
      _insertAt(entry, index);
      rethrow;
    }
    return index;
  }

  Future<void> restoreEntry(FinanceEntry entry, int index) async {
    if (error != null) throw StateError(error!);
    if (entries.contains(entry)) return;
    _insertAt(entry, index);
    try {
      await _saveEntries(entries);
    } catch (_) {
      entries = [...entries]..remove(entry);
      notifyListeners();
      rethrow;
    }
  }

  void _insertAt(FinanceEntry entry, int index) {
    entries = [...entries]..insert(index.clamp(0, entries.length), entry);
    notifyListeners();
  }

  Future<void> toggleFavorite(String code) async {
    await load();
    if (error != null) throw StateError(error!);
    final updated = {...favorites};
    if (!updated.add(code)) updated.remove(code);
    await repository.setStringList('favorites', updated.toList());
    favorites = updated;
    notifyListeners();
  }

  Future<void> setHideBalance(bool value) async {
    await load();
    if (error != null) throw StateError(error!);
    await repository.setBool('hideBalance', value);
    hideBalance = value;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await load();
    if (error != null) throw StateError(error!);
    if (darkMode == value) return;
    darkMode = value;
    notifyListeners();
    try {
      await repository.setBool('darkMode', value);
    } catch (_) {
      darkMode = !value;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setBudget(double value) async {
    await load();
    if (error != null) throw StateError(error!);
    await repository.setDouble('budget', value);
    budget = value;
    notifyListeners();
  }
}
