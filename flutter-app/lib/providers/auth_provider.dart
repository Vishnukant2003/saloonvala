import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final ApiService _api = ApiService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Initialize - load user from storage
  Future<void> initialize() async {
    await _storage.init();
    final userId = _storage.getUserId();
    if (userId != null) {
      _user = User(
        id: userId,
        name: _storage.getName(),
        mobile: _storage.getPhone(),
        email: _storage.getEmail(),
        role: _storage.getRole(),
        token: _storage.getToken(),
      );
      notifyListeners();
    }
  }

  Future<bool> login({
    required String mobile,
    required String name,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.login(
        mobile: mobile,
        name: name,
        role: role,
      );

      if (response.data != null) {
        final data = response.data!;
        
        // Save user data
        await _storage.saveToken(data['token'] ?? '');
        await _storage.saveUserId(data['id'] ?? -1);
        await _storage.saveName(data['name'] ?? name);
        await _storage.saveRole(data['role'] ?? role);
        await _storage.savePhone(data['mobile'] ?? mobile);
        if (data['email'] != null) {
          await _storage.saveEmail(data['email']);
        }

        // Update user object
        _user = User(
          id: data['id'] as int?,
          name: data['name'] as String?,
          mobile: data['mobile'] as String?,
          email: data['email'] as String?,
          role: data['role'] as String?,
          token: data['token'] as String?,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _user = null;
    _error = null;
    notifyListeners();
  }
}

