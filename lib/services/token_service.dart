import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';

/// Data class representing the connection details needed to join a LiveKit room
/// This includes the server URL, room name, participant info, and auth token
class ConnectionDetails {
  final String serverUrl;
  final String roomName;
  final String participantName;
  final String participantToken;

  ConnectionDetails({
    required this.serverUrl,
    required this.roomName,
    required this.participantName,
    required this.participantToken,
  });

  factory ConnectionDetails.fromJson(Map<String, dynamic> json) {
    return ConnectionDetails(
      serverUrl: json['serverUrl'],
      roomName: json['roomName'],
      participantName: json['participantName'],
      participantToken: json['participantToken'],
    );
  }
}

/// A service for creating LiveKit rooms and getting authentication tokens via API
///
/// This service calls the backend API to create a room and get authentication tokens.
/// Setup:
/// 1. Create a .env file with your server configuration:
///    - LIVEKIT_URL=ws://your-livekit-server:7880
///    - SERVER_BASE_URL=http://your-backend-server:9001
///
/// 2. The backend API endpoint should be available at:
///    - POST {SERVER_BASE_URL}/api/v1/livekit/create-room
///
/// For development, you can also use hardcoded credentials by setting
/// `hardcodedServerUrl` and `hardcodedToken` below
class TokenService {
  static final _logger = Logger('TokenService');

  // For hardcoded token usage (development only)
  final String? hardcodedServerUrl = null;
  final String? hardcodedToken = null;

  // Get LiveKit server URL from environment variables
  String? get serverUrl {
    final value = dotenv.env['LIVEKIT_URL'];
    if (value != null) {
      // Remove unwanted double quotes if present
      return value.replaceAll('"', '');
    }
    return null;
  }

  // Get server base URL from environment variables
  String? get serverBaseUrl {
    final value = dotenv.env['SERVER_BASE_URL'];
    if (value != null) {
      // Remove unwanted double quotes if present
      return value.replaceAll('"', '');
    }
    return null;
  }

  /// Main method to get connection details
  /// First tries hardcoded credentials, then calls API to create room
  Future<ConnectionDetails> fetchConnectionDetails({
    required String roomName,
    required String participantName,
    required BuildContext context,
  }) async {
    final hardcodedDetails = fetchHardcodedConnectionDetails(
      roomName: roomName,
      participantName: participantName,
    );

    if (hardcodedDetails != null) {
      return hardcodedDetails;
    }

    return fetchConnectionDetailsWithAPI(
      roomName: roomName,
      participantName: participantName,
      context: context,
    );
  }

  /// Create room and get connection details using API call
  Future<ConnectionDetails> fetchConnectionDetailsWithAPI({
    required String roomName,
    required String participantName,
    required BuildContext context,
  }) async {
    if (serverUrl == null || serverBaseUrl == null) {
      throw Exception(
          'Server configuration is missing. Please check your .env file for LIVEKIT_URL and SERVER_BASE_URL');
    }

    try {
      final token = await createRoomAndGetToken(
        roomName: roomName,
        participantName: participantName,
        context: context,
      );

      return ConnectionDetails(
        serverUrl: serverUrl!,
        roomName: roomName,
        participantName: participantName,
        participantToken: token,
      );
    } catch (e) {
      _logger.severe('Failed to create room and get token: $e');
      throw Exception('Failed to create room and get token: $e');
    }
  }

  /// Create a room and get authentication token via API call
  Future<String> createRoomAndGetToken({
    required String roomName,
    required String participantName,
    required BuildContext context,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      throw Exception('No authentication token found. Please login again.');
    }
    final url = Uri.parse('$serverBaseUrl/api/v1/livekit/create-room');

    _logger.info('Creating room via API: $url');
    _logger.info('Room name: $roomName, Participant: $participantName');

    final requestBody = {
      'roomName': roomName,
      'participantName': participantName,
    };

    _logger.info('Request body: $requestBody');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      _logger.info('API Response status: ${response.statusCode}');
      _logger.info('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data--------------------------------: $responseData');

        if (responseData['success'] == true && responseData['data'] != null) {
          final roomToken = responseData['data']['roomToken'] as String;
          _logger.info(
              'Successfully created room and got token for participant: $participantName R $roomName -------------------------------- $roomToken');
          return roomToken;
        } else {
          throw Exception(
              'API returned unsuccessful response: ${responseData['message'] ?? 'Unknown error'}');
        }
      } else {
        final errorData =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        throw Exception(
            'API request failed with status ${response.statusCode}: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.severe('API call failed: $e');
      rethrow;
    }
  }

  ConnectionDetails? fetchHardcodedConnectionDetails({
    required String roomName,
    required String participantName,
  }) {
    if (hardcodedServerUrl == null || hardcodedToken == null) {
      return null;
    }

    return ConnectionDetails(
      serverUrl: hardcodedServerUrl!,
      roomName: roomName,
      participantName: participantName,
      participantToken: hardcodedToken!,
    );
  }
}
