import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

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

/// A service for generating LiveKit authentication tokens using JWT
///
/// This service generates JWT tokens for LiveKit authentication.
/// Setup:
/// 1. Create a .env file with your LiveKit credentials:
///    - LIVEKIT_URL=wss://your-app.livekit.cloud
///    - LIVEKIT_API_KEY=your_api_key_here
///    - LIVEKIT_API_SECRET=your_api_secret_here
///
/// 2. Get your credentials from the LiveKit dashboard:
///    - Sign up at https://cloud.livekit.io
///    - Create a project and get your API key and secret
///
/// For development, you can also use hardcoded credentials by setting
/// `hardcodedServerUrl` and `hardcodedToken` below
///
/// See https://docs.livekit.io/home/get-started/authentication for more information
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

  // Get API key from environment variables
  String? get apiKey {
    final value = dotenv.env['LIVEKIT_API_KEY'];
    if (value != null) {
      // Remove unwanted double quotes if present
      return value.replaceAll('"', '');
    }
    return null;
  }

  // Get API secret from environment variables
  String? get apiSecret {
    final value = dotenv.env['LIVEKIT_API_SECRET'];
    if (value != null) {
      // Remove unwanted double quotes if present
      return value.replaceAll('"', '');
    }
    return null;
  }

  /// Main method to get connection details
  /// First tries hardcoded credentials, then generates JWT token
  Future<ConnectionDetails> fetchConnectionDetails({
    required String roomName,
    required String participantName,
  }) async {
    final hardcodedDetails = fetchHardcodedConnectionDetails(
      roomName: roomName,
      participantName: participantName,
    );

    if (hardcodedDetails != null) {
      return hardcodedDetails;
    }

    return fetchConnectionDetailsWithJWT(
      roomName: roomName,
      participantName: participantName,
    );
  }

  /// Generate connection details using JWT token
  ConnectionDetails fetchConnectionDetailsWithJWT({
    required String roomName,
    required String participantName,
  }) {
    if (serverUrl == null || apiKey == null || apiSecret == null) {
      throw Exception(
          'LiveKit configuration is missing. Please check your .env file for LIVEKIT_URL, LIVEKIT_API_KEY, and LIVEKIT_API_SECRET');
    }

    try {
      final token = generateJWT(
        apiKey: apiKey!,
        apiSecret: apiSecret!,
        roomName: roomName,
        participantName: participantName,
      );

      return ConnectionDetails(
        serverUrl: serverUrl!,
        roomName: roomName,
        participantName: participantName,
        participantToken: token,
      );
    } catch (e) {
      _logger.severe('Failed to generate JWT token: $e');
      throw Exception('Failed to generate JWT token');
    }
  }

  /// Generate a JWT token for LiveKit authentication
  String generateJWT({
    required String apiKey,
    required String apiSecret,
    required String roomName,
    required String participantName,
    Duration? validity,
  }) {
    final now = DateTime.now();
    final validityDuration = validity ?? const Duration(hours: 1);
    final expiration = now.add(validityDuration);

    // Create the JWT payload
    final payload = {
      'iss': apiKey,
      'sub': participantName,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiration.millisecondsSinceEpoch ~/ 1000,
      'video': {
        'room': roomName,
        'roomJoin': true,
        'canPublish': true,
        'canSubscribe': true,
        'canPublishData': true,
      },
    };

    // Create and sign the JWT
    final jwt = JWT(payload);
    final token = jwt.sign(SecretKey(apiSecret));

    _logger.info(
        'Generated JWT token for participant: $participantName in room: $roomName');
    return token;
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
