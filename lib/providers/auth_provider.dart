import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class AuthProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static final _logger = Logger('AuthProvider');

  String? _token;
  String? _userId;
  bool _isLoggedIn = false;
  bool _isLoading = true; // Start with loading state

  // Getters
  String? get token => _token;
  String? get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final userId = await _storage.read(key: _userIdKey);

      if (token != null) {
        _token = token;
        _userId = userId;
        _isLoggedIn = true;
        _isLoading = false;
      } else {
        // No token found, set loading to false
        _isLoading = false;
      }
      notifyListeners();
    } catch (e) {
      _logger.severe('Error loading token from storage: $e');
      // Set loading to false even if there's an error
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setToken(String token, String? userId) async {
    try {
      print('AuthProvider: Saving token to storage: $token'); // Debug log
      await _storage.write(key: _tokenKey, value: token);
      if (userId != null) {
        await _storage.write(key: _userIdKey, value: userId);
      }

      _token = token;
      _userId = userId;
      _isLoggedIn = true;
      _isLoading = false;

      print(
          'AuthProvider: Auth state updated, isLoggedIn: $_isLoggedIn'); // Debug log
      notifyListeners();
    } catch (e) {
      _logger.severe('Error saving token to storage: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userIdKey);

      _token = null;
      _userId = null;
      _isLoggedIn = false;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _logger.severe('Error clearing token from storage: $e');
    }
  }
}
