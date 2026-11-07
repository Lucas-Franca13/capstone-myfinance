import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalRepository {
  Future<List<String>> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
  Future<bool> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<double?> getDouble(String key);
  Future<void> setDouble(String key, double value);
}

class SharedPreferencesRepository implements LocalRepository {
  SharedPreferencesRepository(this.preferences);
  final SharedPreferencesAsync preferences;
  @override
  Future<List<String>> getStringList(String key) async =>
      await preferences.getStringList(key) ?? [];
  @override
  Future<void> setStringList(String key, List<String> value) =>
      preferences.setStringList(key, value);
  @override
  Future<bool> getBool(String key) async =>
      await preferences.getBool(key) ?? false;
  @override
  Future<void> setBool(String key, bool value) =>
      preferences.setBool(key, value);
  @override
  Future<double?> getDouble(String key) => preferences.getDouble(key);
  @override
  Future<void> setDouble(String key, double value) =>
      preferences.setDouble(key, value);
}
