
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAudioAnimation(),
                  const SizedBox(height: 30),
                  const Text(
                    'Listening...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap and hold to speak',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4a6741), Color(0xFF2c3e50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'E',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esha',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online • Ready to chat',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioAnimation() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing Rings
          _buildPulseRing(0),
          _buildPulseRing(0.5),
          _buildPulseRing(1.0),

          // Audio Waves
          Container(
             width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final heights = [20.0, 35.0, 50.0, 35.0, 20.0];
                final delays = [0.0, 0.2, 0.4, 0.6, 0.8];
                
                return AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    final double animationValue = (_waveController.value + delays[index]) % 1.0;
                    final double scale = 0.5 + 0.5 * (0.5 - (animationValue - 0.5).abs()) * 2;

                    return Container(
                      width: 4,
                      height: heights[index] * scale,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double animationValue = (_pulseController.value + delay) % 1.0;
        final double scale = 0.8 + (animationValue * 0.4);
        final double opacity = 1.0 - animationValue;

        return Transform.scale(
          scale: scale,
          child: Container(
             width: 200,
             height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           SizedBox(width: 60),
          // Mute Button
          Material(
            color: Colors.white.withOpacity(0.2),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              icon: const Icon(Icons.mic_off, color: Colors.white),
              onPressed: () {},
              iconSize: 28,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(width: 20),
          // Record Button
          Material(
             color: const Color(0xFF4a6741),
             shape: const CircleBorder(),
             clipBehavior: Clip.antiAlias,
             elevation: 8.0,
             child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {},
              iconSize: 36,
              padding: const EdgeInsets.all(24),
            ),
          ),
           const SizedBox(width: 20),
          // Placeholder for symmetry from HTML
          IconButton(
            icon: const Icon(Icons.schema, color: Colors.transparent),
            onPressed: () {},
            iconSize: 28,
            padding: const EdgeInsets.all(16),
          ),
        ],
      ),
    );
  }
}
