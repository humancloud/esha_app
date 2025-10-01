import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_ctrl.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _buttonController;

  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Initialize animations
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: -10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _navigateToAgent(BuildContext context) {
    final appCtrl = Provider.of<AppCtrl>(context, listen: false);
    appCtrl.navigateToAgent();
    appCtrl.connect(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2c3e50), Color(0xFF4a6741)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60), // Space for settings icon
                      // Animated Avatar Section
                      _buildAnimatedAvatar(),
                      const SizedBox(height: 30),

                      // Welcome Text Section
                      _buildWelcomeText(),
                      const SizedBox(height: 40),

                      // Feature Items
                      _buildFeatureItems(),
                      const SizedBox(height: 40),

                      // Let's Talk Button
                      _buildLetsTalkButton(),
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),
              ),
              // Settings icon in top right corner
              Positioned(
                top: 20,
                right: 20,
                child: Consumer<AppCtrl>(
                  builder: (context, appCtrl, child) {
                    return IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        appCtrl.navigateToSettings();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Image(
                    image: AssetImage('assets/icon.png'),
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Welcome to Esha!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black38,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Your AI friend is ready to chat with you. Ask me anything, share your thoughts, or just have a friendly conversation.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItems() {
    return Column(
      children: [
        _buildFeatureItem('🧠', 'Smart responses'),
        const SizedBox(height: 12),
        _buildFeatureItem('💭', 'Always here for you'),
      ],
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetsTalkButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Consumer<AppCtrl>(
          builder: (context, appCtrl, child) {
            return GestureDetector(
              onTap: () => _navigateToAgent(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2c3e50), Color(0xFF4a6741)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2c3e50).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Let's Talk!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Transform.translate(
                      offset: Offset(
                        (0.5 -
                                (0.5 - (_buttonController.value - 0.5).abs()) *
                                    2) *
                            3,
                        0,
                      ),
                      child: const Text(
                        '🚀',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
