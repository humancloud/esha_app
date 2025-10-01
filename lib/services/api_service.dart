import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import '../providers/auth_provider.dart';

class ApiService {
  static final _logger = Logger('ApiService');
  static String get baseUrl =>
      dotenv.env['SERVER_BASE_URL'] ?? 'http://34.93.197.93:9001';

  static Future<Map<String, dynamic>> _makeRequest({
    required String method,
    required String endpoint,
    required BuildContext context,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      return {
        'success': false,
        'message': 'No authentication token found. Please login again.',
      };
    }

    try {
      final url = Uri.parse('$baseUrl$endpoint');
      _logger.info('Making $method request to: $url');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?additionalHeaders,
      };

      if (body != null) {
        _logger.info('Request body: ${jsonEncode(body)}');
      }

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(url, headers: headers)
              .timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await http
              .post(
                url,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http
              .put(
                url,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http
              .delete(url, headers: headers)
              .timeout(const Duration(seconds: 30));
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      _logger.info('Response status: ${response.statusCode}');
      _logger.info('Response body: ${response.body}');

      final responseData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 401) {
        // Token expired or invalid, clear it
        await authProvider.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
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

      _logger.severe('API request error: $errorMessage');

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    required BuildContext context,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      method: 'GET',
      endpoint: endpoint,
      context: context,
      additionalHeaders: headers,
    );
  }

  // POST request
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required BuildContext context,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      method: 'POST',
      endpoint: endpoint,
      context: context,
      body: body,
      additionalHeaders: headers,
    );
  }

  // PUT request
  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required BuildContext context,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      method: 'PUT',
      endpoint: endpoint,
      context: context,
      body: body,
      additionalHeaders: headers,
    );
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete({
    required String endpoint,
    required BuildContext context,
    Map<String, String>? headers,
  }) async {
    return _makeRequest(
      method: 'DELETE',
      endpoint: endpoint,
      context: context,
      additionalHeaders: headers,
    );
  }
}
