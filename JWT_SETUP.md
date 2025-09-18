

## How to Setup LiveKit JWT Authentication

The TokenService has been updated to use JWT token generation instead of the sandbox URL approach. Here's how to set it up:

### 1. Get your LiveKit credentials:
- Sign up at https://cloud.livekit.io
- Create a new project
- Go to your project settings to get your API Key and API Secret

### 2. Update your .env file:
Replace the placeholder values in your .env file with your actual LiveKit credentials:

```
LIVEKIT_URL=wss://your-project-name.livekit.cloud
LIVEKIT_API_KEY=your_actual_api_key_here
LIVEKIT_API_SECRET=your_actual_api_secret_here
```

### 3. The TokenService will now:
- Generate JWT tokens locally using your API credentials
- Provide the proper server URL from your environment
- Handle token expiration (default 1 hour)
- Include proper permissions for room joining, publishing, and subscribing

### Usage remains the same:
```dart
final tokenService = TokenService();
final connectionDetails = await tokenService.fetchConnectionDetails(
  roomName: 'your-room-name',
  participantName: 'participant-name',
);
```

This approach is more secure and production-ready compared to the sandbox URL method.

