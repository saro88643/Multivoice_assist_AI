import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  // Voice settings
  bool _autoSpeak = true;
  bool _speechRecognition = true;

  double _speechRate = 0.5;
  double _speechPitch = 1.0;

  String _selectedVoice = "Default Voice";

  final List<String> _voices = [
    "Default Voice",
    "English Voice",
    "Indian English Voice",
  ];

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice settings saved successfully")),
    );
  }

  void _testVoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Voice test will use your selected voice settings."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Voice Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const Text(
                "Voice & Speech",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Manage how MultiVoice Assist listens and speaks.",
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),

              const SizedBox(height: 25),

              // SPEECH RECOGNITION
              _buildSettingCard(
                icon: Icons.mic,
                title: "Speech Recognition",
                subtitle: "Use your microphone for voice input",
                trailing: Switch(
                  value: _speechRecognition,
                  onChanged: (value) {
                    setState(() {
                      _speechRecognition = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 15),

              // AUTO SPEAK
              _buildSettingCard(
                icon: Icons.volume_up,
                title: "Auto Speak",
                subtitle: "Automatically speak AI responses",
                trailing: Switch(
                  value: _autoSpeak,
                  onChanged: (value) {
                    setState(() {
                      _autoSpeak = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 25),

              // VOICE
              const Text(
                "Voice",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedVoice,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                    ),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: _voices.map((voice) {
                      return DropdownMenuItem<String>(
                        value: voice,
                        child: Text(voice),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedVoice = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // SPEECH RATE
              const Text(
                "Speech Speed",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "${_speechRate.toStringAsFixed(1)}x",
                style: const TextStyle(color: Colors.white60, fontSize: 15),
              ),

              Slider(
                value: _speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                activeColor: AppColors.primary,
                inactiveColor: Colors.white24,
                label: "${_speechRate.toStringAsFixed(1)}x",
                onChanged: (value) {
                  setState(() {
                    _speechRate = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // SPEECH PITCH
              const Text(
                "Voice Pitch",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                _speechPitch.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white60, fontSize: 15),
              ),

              Slider(
                value: _speechPitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                activeColor: AppColors.primary,
                inactiveColor: Colors.white24,
                label: _speechPitch.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _speechPitch = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // TEST VOICE
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _testVoice,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    "Test Voice",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // SAVE
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save Settings",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),

          trailing,
        ],
      ),
    );
  }
}
