import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  static const _kKey = 'user_profile_v1';

  UserProfile _profile = const UserProfile();
  bool _loaded = false;
  bool _saving = false;

  UserProfile get profile => _profile;
  bool get isLoaded => _loaded;
  bool get isSaving => _saving;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(raw));
      } catch (_) {/* ignore bad data */}
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> save(UserProfile next) async {
    _saving = true;
    notifyListeners();
    _profile = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(next.toJson()));
    _saving = false;
    notifyListeners();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
    _profile = const UserProfile();
    notifyListeners();
  }
}
