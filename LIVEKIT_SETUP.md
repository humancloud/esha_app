# LiveKit Integration Setup

This document explains how to set up LiveKit integration for your Esha AI app.

## Prerequisites

1. **LiveKit Server**: You need a LiveKit server running. You can either:
   - Use [LiveKit Cloud](https://cloud.livekit.io/) (recommended for development)
   - Self-host LiveKit server

2. **API Keys**: Get your API key and secret from your LiveKit dashboard

## Setup Steps

### 1. Configure LiveKit Connection

Edit `lib/config/livekit_config.dart` and update the following values:

```dart
class LiveKitConfig {
  // Replace with your actual LiveKit server URL
  static const String serverUrl = 'wss://your-project.livekit.cloud';
  
  // Replace with a valid JWT token (see token generation below)
  static const String token = 'your-jwt-token';
  
  // Room name for the AI session
  static const String roomName = 'ai-session';
  
  // Participant name
  static const String participantName = 'User';
}
```

### 2. Generate JWT Token

You need to generate a JWT token for authentication. Here are examples for different platforms:

#### Node.js Backend Example

```javascript
const { AccessToken } = require('livekit-server-sdk');

const token = AccessToken.create(
  'your-api-key',     // Your LiveKit API key
  'your-api-secret',  // Your LiveKit API secret
  {
    room: 'ai-session',
    identity: 'user-123',
    name: 'User',
    canPublish: true,
    canSubscribe: true,
    canPublishData: true,
  }
);

const jwt = token.toJwt();
console.log('JWT Token:', jwt);
```

#### Python Backend Example

```python
from livekit import api

token = api.AccessToken.create(
    api_key="your-api-key",
    api_secret="your-api-secret",
    room="ai-session",
    identity="user-123",
    name="User",
    grants=api.RoomGrants(
        can_publish=True,
        can_subscribe=True,
        can_publish_data=True,
    ),
)

jwt = token.to_jwt()
print(f"JWT Token: {jwt}")
```

### 3. Update Configuration

Replace the placeholder values in `lib/config/livekit_config.dart` with your actual:
- Server URL
- Generated JWT token

### 4. Test the Connection

Run your Flutter app and navigate to the AI screen. You should see:
- "Connecting..." initially
- "Online • Ready to chat" when connected
- Working microphone controls

## Features Implemented

✅ **Real-time Audio**: Microphone input/output through LiveKit
✅ **Connection Status**: Visual indicators for connection state
✅ **Microphone Controls**: Toggle microphone on/off
✅ **Recording State**: Visual feedback for recording status
✅ **Error Handling**: Proper error messages for connection issues

## Next Steps

1. **AI Integration**: Connect the audio stream to your AI service
2. **Real-time Processing**: Process audio in real-time for AI responses
3. **Video Support**: Add camera functionality if needed
4. **Multiple Participants**: Support for multiple users in the same room

## Troubleshooting

### Common Issues

1. **Connection Failed**: Check your server URL and token
2. **Microphone Not Working**: Ensure permissions are granted
3. **Token Expired**: Generate a new JWT token
4. **Network Issues**: Check firewall settings for WebRTC

### Debug Mode

Enable debug logging by adding this to your `main.dart`:

```dart
import 'package:livekit_client/livekit_client.dart';

void main() {
  LiveKit.setLogLevel(LogLevel.debug);
  runApp(MyApp());
}
```

## Resources

- [LiveKit Flutter Documentation](https://docs.livekit.io/home/quickstarts/flutter/)
- [LiveKit Cloud Dashboard](https://cloud.livekit.io/)
- [JWT Token Generation Guide](https://docs.livekit.io/home/quickstarts/flutter/#generating-tokens)
- [LiveKit Server SDK](https://docs.livekit.io/home/server-sdk/)
