import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Simple JWT token generator for LiveKit local development
/// This is a basic implementation for development purposes only
class LiveKitTokenGenerator {
  static const String apiKey = 'devkey'; // Your LiveKit API key
  static const String apiSecret =
      '1234567890abcdefghijklmnopqrstuvwxyz123456'; // Your LiveKit API secret

  // Alternative credentials that might work with your server
  static const List<Map<String, String>> credentialOptions = [
    {'key': 'devkey', 'secret': '1234567890abcdefghijklmnopqrstuvwxyz123456'},
    {'key': 'devkey', 'secret': 'secret'},
    {'key': 'APIKEY', 'secret': 'APISECRET'},
    {'key': 'livekit', 'secret': 'livekit'},
    {'key': 'test', 'secret': 'test'},
  ];

  /// Generate a JWT token for LiveKit connection
  static String generateToken({
    required String roomName,
    required String participantName,
    String participantIdentity = '',
    Map<String, dynamic>? grants,
  }) {
    return _generateTokenWithCredentials(
      apiKey: apiKey,
      apiSecret: apiSecret,
      roomName: roomName,
      participantName: participantName,
      participantIdentity: participantIdentity,
      grants: grants,
    );
  }

  /// Generate token with specific credentials
  static String _generateTokenWithCredentials({
    required String apiKey,
    required String apiSecret,
    required String roomName,
    required String participantName,
    String participantIdentity = '',
    Map<String, dynamic>? grants,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = now + 3600; // Token expires in 1 hour

    final header = {'alg': 'HS256', 'typ': 'JWT'};

    final payload = {
      'iss': apiKey,
      'sub': participantIdentity.isNotEmpty
          ? participantIdentity
          : participantName,
      'iat': now,
      'exp': exp,
      'video': {
        'room': roomName,
        'roomJoin': true,
        'canPublish': true,
        'canSubscribe': true,
        'canPublishData': true,
      },
    };

    final headerEncoded = base64Url.encode(utf8.encode(jsonEncode(header)));
    final payloadEncoded = base64Url.encode(utf8.encode(jsonEncode(payload)));

    final signature = _createSignature(
      '$headerEncoded.$payloadEncoded',
      apiSecret,
    );

    final token = '$headerEncoded.$payloadEncoded.$signature';

    // Debug: Print token info (remove in production)
    print('🔑 Generated token for: $participantName');
    print('🔑 Room: $roomName');
    print('🔑 Token length: ${token.length}');

    return token;
  }

  /// Try to generate a token with different credential combinations
  static List<String> generateTokensWithAllCredentials({
    required String roomName,
    required String participantName,
    String participantIdentity = '',
  }) {
    final tokens = <String>[];

    for (final creds in credentialOptions) {
      try {
        final token = _generateTokenWithCredentials(
          apiKey: creds['key']!,
          apiSecret: creds['secret']!,
          roomName: roomName,
          participantName: participantName,
          participantIdentity: participantIdentity,
        );
        tokens.add(token);
        print('🔑 Generated token with ${creds['key']}:${creds['secret']}');
      } catch (e) {
        print(
          '❌ Failed to generate token with ${creds['key']}:${creds['secret']} - $e',
        );
      }
    }

    return tokens;
  }

  static String _createSignature(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64Url.encode(digest.bytes);
  }
}
