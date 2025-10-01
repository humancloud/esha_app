import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthService {
  static String get baseUrl =>
      dotenv.env['SERVER_BASE_URL'] ?? 'http://34.93.197.93:9001';

  // Sign up method
  static Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auth/signup');
      print('Sign up URL: $url'); // Debug log
      print('Request body: ${jsonEncode({
            'username': username,
            'email': email,
            'password': password,
          })}'); // Debug log

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30)); // Add timeout

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
          'message': 'Account created successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Sign up failed',
        };
      }
    } catch (e) {
      String errorMessage = 'Network error: ${e.toString()}';

      if (e is HandshakeException) {
        errorMessage =
            'Connection security error. Please check server configuration.';
      } else if (e is SocketException) {
        errorMessage =
            'Cannot connect to server. Please check your internet connection.';
      } else if (e is HttpException) {
        errorMessage = 'HTTP error: ${e.message}';
      } else if (e is TimeoutException) {
        errorMessage = 'Request timed out. Please try again.';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Sign in method
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/auth/login');
      print('Sign in URL: $url'); // Debug log
      print('Request body: ${jsonEncode({
            'email': email,
            'password': password,
          })}'); // Debug log

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30)); // Add timeout

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token to Provider and secure storage if context is provided
        if (context != null && responseData['data']?['token'] != null) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          await authProvider.setToken(
            responseData['data']['token'],
            responseData['data']['user']?['id']?.toString(),
          );
          print(
              'Token saved successfully: ${responseData['data']['token']}'); // Debug log
        }

        return {
          'success': true,
          'data': responseData,
          'message': 'Sign in successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Sign in failed',
        };
      }
    } catch (e) {
      String errorMessage = 'Network error: ${e.toString()}';

      if (e is HandshakeException) {
        errorMessage =
            'Connection security error. Please check server configuration.';
      } else if (e is SocketException) {
        errorMessage =
            'Cannot connect to server. Please check your internet connection.';
      } else if (e is HttpException) {
        errorMessage = 'HTTP error: ${e.message}';
      } else if (e is TimeoutException) {
        errorMessage = 'Request timed out. Please try again.';
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Logout method
  static Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.clearToken();
  }
}
