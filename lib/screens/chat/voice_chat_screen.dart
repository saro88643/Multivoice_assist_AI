import 'package:flutter/material.dart';

import '../../services/grok_service.dart';
import '../../services/speech_service.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  // ============================================================
  // SERVICES
  // ============================================================

  final SpeechService _speechService = SpeechService();
  final GrokService _grokService = GrokService();

  // ============================================================
  // STATE
  // ============================================================

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isLoading = false;

  String _spokenText = '';
  String _aiResponse = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // ============================================================
  // INITIALIZE SPEECH
  // ============================================================

  Future<void> _initializeSpeech() async {
    try {
      final bool enabled = await _speechService.initialize();

      if (!mounted) return;

      setState(() {
        _speechEnabled = enabled;
      });

      if (!enabled) {
        _showMessage(
          'Speech recognition is not available. '
          'Please check microphone permission.',
        );
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');

      if (!mounted) return;

      setState(() {
        _speechEnabled = false;
      });

      _showMessage('Speech initialization failed.');
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // ============================================================
  // START LISTENING
  // ============================================================

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      _showMessage('Speech recognition is not available.');
      return;
    }

    if (_isListening || _isLoading) {
      return;
    }

    // Clear previous speech
    if (mounted) {
      setState(() {
        _spokenText = '';
        _aiResponse = '';
        _isListening = true;
      });
    }

    try {
      await _speechService.startListening((String text) {
        debugPrint('Recognized Text: $text');

        if (!mounted) return;

        setState(() {
          _spokenText = text;
        });
      });
    } catch (e) {
      debugPrint('Start listening error: $e');

      if (!mounted) return;

      setState(() {
        _isListening = false;
      });

      _showMessage(
        'Unable to start microphone. '
        'Please check microphone permission.',
      );
    }
  }

  // ============================================================
  // STOP LISTENING
  // ============================================================

  Future<void> _stopListening() async {
    if (!_isListening) {
      return;
    }

    try {
      await _speechService.stopListening();
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    final String text = _spokenText.trim();

    debugPrint('Final Spoken Text: $text');

    // No speech
    if (text.isEmpty) {
      _showMessage('No speech detected.');
      return;
    }

    // Send recognized text to AI
    await _sendToAI(text);
  }

  // ============================================================
  // SEND TO AI
  // ============================================================

  Future<void> _sendToAI(String text) async {
    final String message = text.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    debugPrint('Sending to Groq AI: $message');

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    try {
      final String reply = await _grokService.sendMessage(message);

      if (!mounted) return;

      setState(() {
        _aiResponse = reply.trim();
      });

      debugPrint('AI Response: $reply');
    } catch (e) {
      debugPrint('Grok API error: $e');

      if (!mounted) return;

      setState(() {
        _aiResponse = '';
      });

      _showMessage(
        'Unable to get AI response. Please check your API key and internet connection.',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard({
    required String title,
    required String text,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 26),

                const SizedBox(width: 10),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 25),

            Text(
              text.isEmpty ? 'No text available.' : text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MICROPHONE BUTTON
  // ============================================================

  Widget _buildMicrophoneButton() {
    final bool active = _isListening;

    return GestureDetector(
      onLongPressStart: (_) {
        _startListening();
      },

      onLongPressEnd: (_) {
        _stopListening();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: 90,
        height: 90,

        decoration: BoxDecoration(
          color: active ? Colors.red : Colors.blue,
          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: (active ? Colors.red : Colors.blue).withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 5,
            ),
          ],
        ),

        child: Icon(
          active ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Chat'), centerTitle: true),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // ==================================================
              // CONTENT
              // ==================================================
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // USER SPEECH
                      _buildCard(
                        title: 'You Said',
                        text: _spokenText,
                        icon: Icons.mic,
                      ),

                      // AI RESPONSE
                      _buildCard(
                        title: 'AI Reply',
                        text: _aiResponse,
                        icon: Icons.smart_toy,
                      ),

                      // LOADING
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),

                              SizedBox(height: 10),

                              Text(
                                'AI is thinking...',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // MICROPHONE
              // ==================================================
              _buildMicrophoneButton(),

              const SizedBox(height: 15),

              // ==================================================
              // STATUS
              // ==================================================
              Text(
                _isListening
                    ? 'Listening... Release to send'
                    : _isLoading
                    ? 'Getting AI response...'
                    : 'Press and hold the microphone to speak',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isListening
                      ? Colors.red
                      : _isLoading
                      ? Colors.blue
                      : Colors.black54,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }
}
