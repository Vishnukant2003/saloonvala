import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token
  String? getToken() {
    return _prefs?.getString(AppConstants.keyToken);
  }

  Future<bool> saveToken(String token) async {
    await init();
    return await _prefs?.setString(AppConstants.keyToken, token) ?? false;
  }

  // User ID
  int? getUserId() {
    final id = _prefs?.getInt(AppConstants.keyUserId);
    return id != null && id > 0 ? id : null;
  }

  Future<bool> saveUserId(int userId) async {
    await init();
    return await _prefs?.setInt(AppConstants.keyUserId, userId) ?? false;
  }

  // Name
  String? getName() {
    return _prefs?.getString(AppConstants.keyName);
  }

  Future<bool> saveName(String name) async {
    await init();
    return await _prefs?.setString(AppConstants.keyName, name) ?? false;
  }

  // Role
  String? getRole() {
    return _prefs?.getString(AppConstants.keyRole);
  }

  Future<bool> saveRole(String role) async {
    await init();
    return await _prefs?.setString(AppConstants.keyRole, role) ?? false;
  }

  // Phone
  String? getPhone() {
    return _prefs?.getString(AppConstants.keyPhone);
  }

  Future<bool> savePhone(String phone) async {
    await init();
    return await _prefs?.setString(AppConstants.keyPhone, phone) ?? false;
  }

  // Email
  String? getEmail() {
    return _prefs?.getString(AppConstants.keyEmail);
  }

  Future<bool> saveEmail(String email) async {
    await init();
    return await _prefs?.setString(AppConstants.keyEmail, email) ?? false;
  }

  // Shop Live Status
  bool isShopLive() {
    return _prefs?.getBool(AppConstants.keyShopLive) ?? false;
  }

  Future<bool> setShopLive(bool isLive) async {
    await init();
    return await _prefs?.setBool(AppConstants.keyShopLive, isLive) ?? false;
  }

  // Clear all data
  Future<bool> clear() async {
    await init();
    return await _prefs?.clear() ?? false;
  }
}

