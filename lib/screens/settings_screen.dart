import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_ctrl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            final appCtrl = Provider.of<AppCtrl>(context, listen: false);
            appCtrl.navigateToWelcome();
          },
        ),
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a2a3a), Color(0xFF2a4a6a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 80),
            buildUserProfile(context),
            const SizedBox(height: 30),
            buildSettingsSection('Voice & Audio', [
              buildSettingsItem(Icons.mic, 'Voice Settings'),
              buildSettingsItem(
                Icons.volume_up,
                'Auto-play responses',
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeThumbColor: const Color(0xFF4a6741),
                ),
              ),
            ]),
            buildSettingsSection('Personalization', [
              buildSettingsItem(Icons.palette, 'Theme'),
              buildSettingsItem(Icons.psychology, 'Friend Personality'),
            ]),
            buildSettingsSection('Account', [
              buildSettingsItem(Icons.lock, 'Privacy'),
              buildSettingsItem(Icons.info, 'About'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildUserProfile(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF2c3e50), Color(0xFF4a6741)],
            ),
          ),
          child: const Center(
            child: Text(
              'J',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'John Doe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'john@example.com',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget buildSettingsSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 15),
          ...items,
        ],
      ),
    );
  }

  Widget buildSettingsItem(IconData icon, String title, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
        onTap: () {},
      ),
    );
  }
}
