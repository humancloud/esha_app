import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livekit_client/livekit_client.dart' as sdk;
import 'package:livekit_components/livekit_components.dart' as components;
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../exts.dart';
import '../services/token_service.dart';

enum AppScreenState { login, welcome, agent, settings }

enum AgentScreenState { visualizer, transcription }

enum ConnectionState { disconnected, connecting, connected }

class AppCtrl extends ChangeNotifier {
  static const uuid = Uuid();
  static final _logger = Logger('AppCtrl');

  // States
  AppScreenState appScreenState = AppScreenState.welcome;
  ConnectionState connectionState = ConnectionState.disconnected;
  AgentScreenState agentScreenState = AgentScreenState.visualizer;

  //Test
  bool isUserCameEnabled = false;
  bool isScreenshareEnabled = false;

  final messageCtrl = TextEditingController();
  final messageFocusNode = FocusNode();

  late final sdk.Room room = sdk.Room(
    roomOptions: const sdk.RoomOptions(enableVisualizer: true),
  );
  late final roomContext = components.RoomContext(room: room);

  final tokenService = TokenService();

  bool isSendButtonEnabled = false;

  // Error message for showing toasts
  String? _errorMessage;

  // Timer for checking agent connection
  Timer? _agentConnectionTimer;

  // Getter for error message
  String? get errorMessage => _errorMessage;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Show error message
  void _showError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  AppCtrl() {
    final format = DateFormat('HH:mm:ss');
    // configure logs for debugging
    Logger.root.level = Level.FINE;
    Logger.root.onRecord.listen((record) {
      debugPrint('${format.format(record.time)}: ${record.message}');
    });

    messageCtrl.addListener(() {
      final newValue = messageCtrl.text.isNotEmpty;
      if (newValue != isSendButtonEnabled) {
        isSendButtonEnabled = newValue;
        notifyListeners();
      }
    });

    // Add room error listener to handle runtime connection errors
    room.addListener(_onRoomUpdate);

    // Add participant event listeners
    room.addListener(() {
      // This will be called on any room state change
      notifyListeners();
    });
  }

  void _onRoomUpdate() {
    // Check if room is disconnected due to an error
    if (room.connectionState == sdk.ConnectionState.disconnected &&
        connectionState == ConnectionState.connected) {
      _logger.warning(
          'Room disconnected unexpectedly, navigating to welcome screen');
      connectionState = ConnectionState.disconnected;
      appScreenState = AppScreenState.welcome;
      _showError('Connection lost. Returning to welcome screen.');
      _cancelAgentTimer();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    room.removeListener(_onRoomUpdate);
    _cancelAgentTimer();
    super.dispose();
  }

  void sendMessage() async {
    isSendButtonEnabled = false;

    final text = messageCtrl.text;
    messageCtrl.clear();
    notifyListeners();

    final lp = room.localParticipant;
    if (lp == null) return;

    final nowUtc = DateTime.now().toUtc();
    final segment = sdk.TranscriptionSegment(
      id: uuid.v4(),
      text: text,
      firstReceivedTime: nowUtc,
      lastReceivedTime: nowUtc,
      isFinal: true,
      language: 'en',
    );
    roomContext.insertTranscription(
      components.TranscriptionForParticipant(segment, lp),
    );

    await lp.sendText(text, options: sdk.SendTextOptions(topic: 'lk.chat'));
  }

  void toggleUserCamera(components.MediaDeviceContext? deviceCtx) {
    isUserCameEnabled = !isUserCameEnabled;
    isUserCameEnabled ? deviceCtx?.enableCamera() : deviceCtx?.disableCamera();
    notifyListeners();
  }

  void toggleScreenShare() {
    isScreenshareEnabled = !isScreenshareEnabled;
    notifyListeners();
  }

  void toggleAgentScreenMode() {
    agentScreenState = agentScreenState == AgentScreenState.visualizer
        ? AgentScreenState.transcription
        : AgentScreenState.visualizer;
    notifyListeners();
  }

  void navigateToSettings() {
    appScreenState = AppScreenState.settings;
    notifyListeners();
  }

  void navigateToWelcome() {
    appScreenState = AppScreenState.welcome;
    notifyListeners();
  }

  void navigateToAgent() {
    appScreenState = AppScreenState.agent;
    notifyListeners();
  }

  void navigateToLogin() {
    appScreenState = AppScreenState.login;
    notifyListeners();
  }

  void connect(BuildContext context) async {
    _logger.info("Connect....");
    connectionState = ConnectionState.connecting;
    notifyListeners();

    try {
      // Generate random room and participant names
      // In a real app, you'd likely use meaningful names
      final roomName =
          'my-room'; // Use fixed room name for now to match the API response
      final participantName =
          'user-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';

      // Get connection details from token service
      final connectionDetails = await tokenService.fetchConnectionDetails(
        roomName: roomName,
        participantName: participantName,
        context: context,
      );

      _logger.info(
        "Fetched Connection Details: $connectionDetails, connecting to room...",
      );

      await room.connect(
        connectionDetails.serverUrl,
        connectionDetails.participantToken,
      );

      _logger.info("Connected to room");

      await room.localParticipant?.setMicrophoneEnabled(true);

      _logger.info("Microphone enabled");

      connectionState = ConnectionState.connected;
      appScreenState = AppScreenState.agent;

      // Start the 20-second timer to check for AGENT participant
      _startAgentConnectionTimer();

      notifyListeners();
    } catch (error) {
      _logger.severe('Connection error: $error');

      connectionState = ConnectionState.disconnected;
      appScreenState = AppScreenState.welcome;
      _showError('Connection failed. Please try again.');
      notifyListeners();
    }
  }

  void disconnect() {
    room.disconnect();
    _cancelAgentTimer();

    // Update states
    connectionState = ConnectionState.disconnected;
    appScreenState = AppScreenState.welcome;
    agentScreenState = AgentScreenState.visualizer;

    notifyListeners();
  }

  // Start a 60-second timer to check for agent connection
  void _startAgentConnectionTimer() {
    _cancelAgentTimer(); // Cancel any existing timer
    _logger.info("Starting 60-second timer to check for AGENT participant...");

    _agentConnectionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Log current participants for debugging
      _logger.info("Current participants: ${room.remoteParticipants.length}");
      for (final participant in room.remoteParticipants.values) {
        _logger.info(
            "Participant: ${participant.identity}, isAgent: ${participant.isAgent}, kind: ${participant.kind}");
      }

      // Check if there's an agent participant
      final hasAgent = room.remoteParticipants.values.any(
        (participant) => participant.isAgent,
      );

      if (hasAgent) {
        _logger.info("AGENT participant found, cancelling timer");
        _cancelAgentTimer();
        return;
      }

      // If 60 seconds have elapsed and no agent found, disconnect
      if (timer.tick >= 12) {
        // 12 * 5 seconds = 60 seconds
        _logger.warning(
          "No AGENT participant found after 60 seconds, disconnecting...",
        );
        _cancelAgentTimer();
        disconnect();
      } else {
        _logger.info("Still waiting for agent... (${timer.tick * 5}s elapsed)");
      }
    });
  }

  // Cancel the agent connection timer
  void _cancelAgentTimer() {
    _agentConnectionTimer?.cancel();
    _agentConnectionTimer = null;
  }
}
