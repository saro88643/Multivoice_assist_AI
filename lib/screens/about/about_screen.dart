import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "About",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // APP ICON
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 65,
                ),
              ),

              const SizedBox(height: 25),

              // APP NAME
              const Text(
                "MultiVoice Assist",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Your Multilingual AI Voice Assistant",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),

              const SizedBox(height: 10),

              const Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),

              const SizedBox(height: 30),

              // DESCRIPTION
              _buildSection(
                title: "About the App",
                icon: Icons.info_outline,
                child: const Text(
                  "MultiVoice Assist is a multilingual AI chatbot "
                  "application that allows users to communicate with "
                  "AI using text and voice. The application is designed "
                  "to understand different languages and provide "
                  "responses in the user's language.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // FEATURES
              _buildSection(
                title: "Features",
                icon: Icons.star_outline,
                child: Column(
                  children: [
                    _buildFeature(icon: Icons.chat, text: "AI Chat"),
                    _buildFeature(icon: Icons.mic, text: "Voice Input"),
                    _buildFeature(
                      icon: Icons.volume_up,
                      text: "AI Voice Response",
                    ),
                    _buildFeature(
                      icon: Icons.language,
                      text: "Multilingual Communication",
                    ),
                    _buildFeature(icon: Icons.history, text: "Chat History"),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // TECHNOLOGY
              _buildSection(
                title: "Technology",
                icon: Icons.code,
                child: Column(
                  children: [
                    _buildTechnology("Flutter", "Mobile application framework"),
                    _buildTechnology(
                      "Dart",
                      "Application programming language",
                    ),
                    _buildTechnology(
                      "AI API",
                      "AI-powered conversation service",
                    ),
                    _buildTechnology("SQLite", "Local chat history storage"),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // PROJECT
              _buildSection(
                title: "Project",
                icon: Icons.folder_outlined,
                child: const Text(
                  "MultiVoice Assist is developed as an AI-based "
                  "multilingual chatbot project with voice interaction, "
                  "chat history and user profile management.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Made with Flutter ❤️",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),

              const SizedBox(height: 8),

              const Text(
                "© 2026 MultiVoice Assist",
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // SECTION
  // =========================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          child,
        ],
      ),
    );
  }

  // =========================
  // FEATURE
  // =========================

  Widget _buildFeature({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TECHNOLOGY
  // =========================

  Widget _buildTechnology(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
