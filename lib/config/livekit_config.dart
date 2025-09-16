// LiveKit Configuration
import 'token_generator.dart';

class LiveKitConfig {
  // Your LiveKit server URL
  // For LiveKit Cloud: 'wss://your-project.livekit.cloud'
  // For self-hosted: 'wss://your-server.com'
  // For local development - using your computer's IP address
  // Note: localhost doesn't work on mobile devices, need to use actual IP
  static const String serverUrl = 'ws://182.168.1.245:7880';

  // Room name for the AI session
  static const String roomName = 'ai-session';

  // Participant name
  static const String participantName = 'User';

  // Generate JWT token for authentication
  // This generates a token for local development
  static String get token => LiveKitTokenGenerator.generateToken(
    roomName: roomName,
    participantName: participantName,
    participantIdentity: 'user-${DateTime.now().millisecondsSinceEpoch}',
  );
}
