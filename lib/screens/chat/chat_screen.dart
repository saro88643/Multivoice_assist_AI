import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/speech_provider.dart';
import '../../services/audio_tts_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // STATE
  // ============================================================

  bool _isSending = false;

  String? _playingMessage;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFF0B1220);

  static const Color inputColor = Color(0xFF182235);

  static const Color userColor = Color(0xFF5B4BE7);

  static const Color aiColor = Color(0xFF182235);

  static const Color primaryColor = Color(0xFF7C5CFF);

  static const Color robotColor = Color(0xFF4CAF50);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    if (_isSending) {
      return;
    }

    final ChatProvider chatProvider = context.read<ChatProvider>();

    final HistoryProvider historyProvider = context.read<HistoryProvider>();

    final SpeechProvider speechProvider = context.read<SpeechProvider>();

    final AudioTtsService tts = context.read<AudioTtsService>();

    // Stop currently playing voice
    await tts.stop();

    // Stop microphone if active
    if (speechProvider.isListening) {
      await speechProvider.stopListening();
    }

    setState(() {
      _isSending = true;
      _playingMessage = null;
    });

    // Clear input
    _messageController.clear();

    // Clear speech text
    speechProvider.clearText();

    // Hide keyboard
    FocusScope.of(context).unfocus();

    try {
      debugPrint('CHAT SCREEN: Sending message');
      debugPrint('CHAT SCREEN TEXT: $text');

      // ========================================================
      // SEND TO CHAT PROVIDER
      // ========================================================

      await chatProvider.sendMessage(text, historyProvider: historyProvider);

      debugPrint('CHAT SCREEN: Message request completed');

      debugPrint(
        'CHAT SCREEN: Total messages = '
        '${chatProvider.messages.length}',
      );

      // ========================================================
      // FORCE UI UPDATE
      // ========================================================

      if (mounted) {
        setState(() {});
      }

      // Scroll after AI response
      _scrollToBottom();
    } catch (e, stackTrace) {
      debugPrint('CHAT SCREEN ERROR: $e');

      debugPrint('CHAT SCREEN STACK: $stackTrace');

      if (mounted) {
        _showMessage('Unable to get AI response. Please try again.');
      }
    } finally {
      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      _scrollToBottom();
    }
  }

  // ============================================================
  // MICROPHONE
  // ============================================================

  Future<void> _toggleMicrophone(SpeechProvider provider) async {
    try {
      // --------------------------------------------------------
      // STOP LISTENING
      // --------------------------------------------------------

      if (provider.isListening) {
        await provider.stopListening();

        final String text = provider.recognizedText.trim();

        if (text.isNotEmpty && mounted) {
          setState(() {
            _messageController.text = text;

            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: text.length),
            );
          });
        }

        return;
      }

      // --------------------------------------------------------
      // START LISTENING
      // --------------------------------------------------------

      _messageController.clear();

      provider.clearText();

      await provider.startListening();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('MICROPHONE ERROR: $e');

      _showMessage('Microphone error. Please check microphone permission.');
    }
  }

  // ============================================================
  // CLEAN AI TEXT
  // ============================================================

  String _cleanText(String text) {
    String result = text.trim();

    // Remove markdown headings
    result = result.replaceAll(RegExp(r'(?m)^\s*#{1,6}\s*'), '');

    // Remove bold markdown
    result = result.replaceAll('**', '');

    // Remove markdown bullet symbols
    result = result.replaceAll(RegExp(r'(?m)^\s*[-•+]\s*'), '');

    // Remove numbered list prefixes
    result = result.replaceAll(RegExp(r'(?m)^\s*\d+[.)]\s*'), '');

    // Remove code blocks
    result = result.replaceAll('```', '');

    // Remove inline code
    result = result.replaceAll('`', '');

    // Remove excessive spaces
    result = result.replaceAll(RegExp(r'[ \t]+'), ' ');

    // Remove excessive empty lines
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
  }

  // ============================================================
  // START TTS
  // ============================================================

  Future<void> _startSpeaking(String text, AudioTtsService tts) async {
    final String cleanText = _cleanText(text);

    if (cleanText.isEmpty) {
      return;
    }

    try {
      await tts.stop();

      if (!mounted) return;

      setState(() {
        _playingMessage = cleanText;
      });

      await tts.speak(cleanText);
    } catch (e) {
      debugPrint('SPEAKER ERROR: $e');

      if (!mounted) return;

      setState(() {
        _playingMessage = null;
      });

      _showMessage('Unable to play voice. Check OPENAI_API_KEY.');
    }
  }

  // ============================================================
  // STOP TTS
  // ============================================================

  Future<void> _stopSpeech(AudioTtsService tts) async {
    await tts.stop();

    if (!mounted) return;

    setState(() {
      _playingMessage = null;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'MultiVoice Assist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _profileAvatar(provider),
              );
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        children: [
          // ----------------------------------------------------
          // CHAT AREA
          // ----------------------------------------------------
          Expanded(
            child: Consumer2<ChatProvider, AudioTtsService>(
              builder: (context, chat, tts, child) {
                return _buildChat(chat, tts);
              },
            ),
          ),

          // ----------------------------------------------------
          // INPUT AREA
          // ----------------------------------------------------
          Consumer<SpeechProvider>(
            builder: (context, speech, child) {
              return _buildInputArea(speech);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE AVATAR
  // ============================================================

  Widget _profileAvatar(ProfileProvider provider) {
    final String? path = provider.profileImagePath;

    if (path != null && path.isNotEmpty) {
      final File file = File(path);

      if (file.existsSync()) {
        return CircleAvatar(radius: 21, backgroundImage: FileImage(file));
      }
    }

    return const CircleAvatar(
      radius: 21,
      backgroundColor: Color(0xFF29364D),
      child: Icon(Icons.person, color: Colors.white),
    );
  }

  // ============================================================
  // BUILD CHAT
  // ============================================================

  Widget _buildChat(ChatProvider chat, AudioTtsService tts) {
    final messages = chat.messages;

    debugPrint('BUILD CHAT: ${messages.length} messages');

    // ----------------------------------------------------------
    // EMPTY CHAT
    // ----------------------------------------------------------

    if (messages.isEmpty) {
      return _emptyChat();
    }

    // ----------------------------------------------------------
    // MESSAGE LIST
    // ----------------------------------------------------------

    return ListView.builder(
      controller: _scrollController,

      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),

      itemCount: messages.length,

      itemBuilder: (context, index) {
        final message = messages[index];

        final String messageText = message.text.trim();

        if (messageText.isEmpty) {
          return const SizedBox.shrink();
        }

        // ------------------------------------------------------
        // USER MESSAGE
        // ------------------------------------------------------

        if (message.isUser) {
          return _userBubble(messageText);
        }

        // ------------------------------------------------------
        // AI MESSAGE
        // ------------------------------------------------------

        return _aiBubble(messageText, tts);
      },
    );
  }

  // ============================================================
  // EMPTY CHAT
  // ============================================================

  Widget _emptyChat() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: const BoxDecoration(
                color: robotColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Welcome to MultiVoice Assist',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Ask anything in your preferred language.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // USER BUBBLE
  // ============================================================

  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,

      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),

        margin: const EdgeInsets.only(bottom: 14, left: 50),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),

        decoration: const BoxDecoration(
          color: userColor,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(5),
          ),
        ),

        child: Text(
          text,
          softWrap: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AI BUBBLE
  // ============================================================

  Widget _aiBubble(String text, AudioTtsService tts) {
    final String cleanText = _cleanText(text);

    if (cleanText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ----------------------------------------------------
          // ROBOT ICON
          // ----------------------------------------------------
          Container(
            height: 42,
            width: 42,

            margin: const EdgeInsets.only(right: 10),

            decoration: const BoxDecoration(
              color: robotColor,
              shape: BoxShape.circle,
            ),

            child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
          ),

          // ----------------------------------------------------
          // AI MESSAGE
          // ----------------------------------------------------
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 15, 12, 8),

              decoration: BoxDecoration(
                color: aiColor,

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: const Color(0xFF2B3950)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ------------------------------------------------
                  // AI TEXT
                  // ------------------------------------------------
                  Text(
                    cleanText,
                    softWrap: true,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ------------------------------------------------
                  // SPEAKER
                  // ------------------------------------------------
                  _speakerControls(cleanText, tts),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SPEAKER CONTROLS
  // ============================================================

  Widget _speakerControls(String text, AudioTtsService tts) {
    return AnimatedBuilder(
      animation: tts,

      builder: (context, child) {
        final bool same = _playingMessage == text;

        // --------------------------------------------------------
        // NORMAL SPEAKER
        // --------------------------------------------------------

        if (!same) {
          return IconButton(
            padding: EdgeInsets.zero,

            icon: const Icon(
              Icons.volume_up_outlined,
              color: primaryColor,
              size: 29,
            ),

            onPressed: () {
              _startSpeaking(text, tts);
            },
          );
        }

        // --------------------------------------------------------
        // LOADING
        // --------------------------------------------------------

        if (tts.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(6),
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            ),
          );
        }

        // --------------------------------------------------------
        // PAUSED
        // --------------------------------------------------------

        if (tts.isPaused) {
          return Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              IconButton(
                padding: EdgeInsets.zero,

                icon: const Icon(
                  Icons.play_circle_fill,
                  color: primaryColor,
                  size: 31,
                ),

                onPressed: () async {
                  try {
                    await tts.resume();
                  } catch (e) {
                    debugPrint('RESUME ERROR: $e');
                  }
                },
              ),

              IconButton(
                padding: EdgeInsets.zero,

                icon: const Icon(
                  Icons.stop_circle,
                  color: Colors.redAccent,
                  size: 31,
                ),

                onPressed: () {
                  _stopSpeech(tts);
                },
              ),
            ],
          );
        }

        // --------------------------------------------------------
        // SPEAKING
        // --------------------------------------------------------

        if (tts.isSpeaking) {
          return Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              IconButton(
                padding: EdgeInsets.zero,

                icon: const Icon(
                  Icons.pause_circle_filled,
                  color: primaryColor,
                  size: 31,
                ),

                onPressed: () async {
                  try {
                    await tts.pause();
                  } catch (e) {
                    debugPrint('PAUSE ERROR: $e');
                  }
                },
              ),

              IconButton(
                padding: EdgeInsets.zero,

                icon: const Icon(
                  Icons.stop_circle,
                  color: Colors.redAccent,
                  size: 31,
                ),

                onPressed: () {
                  _stopSpeech(tts);
                },
              ),
            ],
          );
        }

        // --------------------------------------------------------
        // PLAY AGAIN
        // --------------------------------------------------------

        return IconButton(
          padding: EdgeInsets.zero,

          icon: const Icon(
            Icons.volume_up_outlined,
            color: primaryColor,
            size: 29,
          ),

          onPressed: () {
            _startSpeaking(text, tts);
          },
        );
      },
    );
  }

  // ============================================================
  // INPUT AREA
  // ============================================================

  Widget _buildInputArea(SpeechProvider speech) {
    final bool hasText = _messageController.text.trim().isNotEmpty;

    final bool listening = speech.isListening;

    return SafeArea(
      top: false,

      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),

        decoration: const BoxDecoration(
          color: inputColor,

          border: Border(top: BorderSide(color: Color(0xFF29374E))),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            // ----------------------------------------------------
            // TEXT FIELD
            // ----------------------------------------------------
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,

                  borderRadius: BorderRadius.circular(25),

                  border: Border.all(
                    color: listening ? Colors.redAccent : primaryColor,
                  ),
                ),

                child: TextField(
                  controller: _messageController,

                  minLines: 1,

                  maxLines: 5,

                  keyboardType: TextInputType.multiline,

                  textInputAction: TextInputAction.newline,

                  style: const TextStyle(color: Colors.white, fontSize: 16),

                  decoration: InputDecoration(
                    hintText: listening
                        ? 'Listening...'
                        : 'Type your message...',

                    hintStyle: const TextStyle(color: Colors.white38),

                    border: InputBorder.none,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),

            const SizedBox(width: 6),

            // ----------------------------------------------------
            // MICROPHONE
            // ----------------------------------------------------
            IconButton(
              icon: Icon(
                listening ? Icons.stop_circle : Icons.mic,

                color: listening ? Colors.redAccent : primaryColor,

                size: 31,
              ),

              onPressed: _isSending
                  ? null
                  : () {
                      _toggleMicrophone(speech);
                    },
            ),

            // ----------------------------------------------------
            // SEND BUTTON
            // ----------------------------------------------------
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      height: 25,
                      width: 25,

                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: primaryColor,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,

                      color: hasText ? primaryColor : Colors.white24,

                      size: 31,
                    ),

              onPressed: (!hasText || _isSending) ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
