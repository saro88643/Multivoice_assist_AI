import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/history_model.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';

import '../chat/chat_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFF050B18);
  static const Color cardColor = Color(0xFF101A2D);
  static const Color darkCardColor = Color(0xFF091225);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color blue = Color(0xFF2563EB);
  static const Color violet = Color(0xFF7C3AED);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Provider.of<HistoryProvider>(context, listen: false).loadHistory();
      Provider.of<ProfileProvider>(context, listen: false).loadProfile();
    });
  }

  // ============================================================
  // OPEN CHAT
  // ============================================================

  Future<void> _openChat() async {
    if (!mounted) return;

    setState(() {
      selectedIndex = 1;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );

    if (!mounted) return;

    await Provider.of<HistoryProvider>(context, listen: false).loadHistory();

    if (!mounted) return;

    setState(() {
      selectedIndex = 0;
    });
  }

  // ============================================================
  // OPEN HISTORY
  // ============================================================

  Future<void> _openHistory() async {
    if (!mounted) return;

    setState(() {
      selectedIndex = 2;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );

    if (!mounted) return;

    await Provider.of<HistoryProvider>(context, listen: false).loadHistory();

    if (!mounted) return;

    setState(() {
      selectedIndex = 0;
    });
  }

  // ============================================================
  // OPEN PROFILE
  // ============================================================

  Future<void> _openProfile() async {
    if (!mounted) return;

    setState(() {
      selectedIndex = 3;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (!mounted) return;

    setState(() {
      selectedIndex = 0;
    });
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage(
    ProfileProvider profileProvider, {
    double radius = 25,
  }) {
    final String? imagePath = profileProvider.profileImagePath;

    if (profileProvider.hasProfileImage &&
        imagePath != null &&
        imagePath.isNotEmpty) {
      final File file = File(imagePath);

      if (file.existsSync()) {
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [purple, blue]),
          ),
          child: CircleAvatar(radius: radius, backgroundImage: FileImage(file)),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [purple, blue]),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF1E293B),
        child: Icon(Icons.person, color: Colors.white, size: radius * 1.1),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        // MENU BUTTON
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menu'),
                  duration: Duration(milliseconds: 700),
                ),
              );
            },
          ),
        ),

        const Spacer(),

        // TITLE
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.white, Color(0xFFB794F4)],
            ).createShader(bounds);
          },
          child: const Text(
            'MultiVoice Assist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Spacer(),

        // NOTIFICATION BUTTON
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Stack(
            children: [
              Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: purple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELCOME SECTION
  // ============================================================

  Widget _buildWelcome(ProfileProvider profileProvider) {
    final String userName = profileProvider.userName.isEmpty
        ? 'User'
        : profileProvider.userName;

    return Row(
      children: [
        _buildProfileImage(profileProvider, radius: 28),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('👋 ', style: TextStyle(fontSize: 15)),
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  Flexible(
                    child: Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C1D95).withOpacity(0.35),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: purple.withOpacity(0.4)),
                    ),
                    child: const Text(
                      '👑 Premium',
                      style: TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // AI BUTTON
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(colors: [Color(0xFF4F46E5), purple]),
            boxShadow: [
              BoxShadow(
                color: violet.withOpacity(0.35),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 23),
        ),
      ],
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF082C4C), Color(0xFF17145A), Color(0xFF32105C)],
        ),
        border: Border.all(color: const Color(0xFF6D28D9).withOpacity(0.55)),
      ),
      child: Stack(
        children: [
          // GLOW
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: violet.withOpacity(0.18),
              ),
            ),
          ),

          // TEXT
          Positioned(
            left: 17,
            top: 25,
            right: 125,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'MultiVoice Assist ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'AI',
                        style: TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Speak, Type and Connect in Any\nLanguage.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          // ROBOT
          Positioned(right: 15, top: 20, child: _buildRobot()),

          // SLIDER DOTS
          Positioned(
            bottom: 13,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_dot(true), _dot(false), _dot(false)],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROBOT
  // ============================================================

  Widget _buildRobot() {
    return SizedBox(
      width: 115,
      height: 115,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // GLOW
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: purple.withOpacity(0.10),
              boxShadow: [
                BoxShadow(color: purple.withOpacity(0.35), blurRadius: 30),
              ],
            ),
          ),

          // HEAD
          Positioned(
            top: 23,
            child: Container(
              width: 78,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF101A38),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: purple, width: 2),
                boxShadow: [
                  BoxShadow(color: purple.withOpacity(0.4), blurRadius: 15),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_robotEye(), const SizedBox(width: 15), _robotEye()],
              ),
            ),
          ),

          // BODY
          Positioned(
            bottom: 5,
            child: Container(
              width: 55,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2B50),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF6366F1)),
              ),
              child: const Icon(Icons.mic, color: Color(0xFFC4B5FD), size: 22),
            ),
          ),

          // ANTENNA
          Positioned(
            top: 4,
            child: Container(
              width: 6,
              height: 22,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),

          Positioned(
            top: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFFA855F7),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _robotEye() {
    return Container(
      width: 10,
      height: 15,
      decoration: BoxDecoration(
        color: const Color(0xFF67E8F9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3EE).withOpacity(0.7),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOT
  // ============================================================

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 7 : 6,
      height: active ? 7 : 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFFA855F7) : Colors.white24,
      ),
    );
  }

  // ============================================================
  // START CHAT CARD
  // ============================================================

  Widget _buildStartChatCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 16),
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.65)),
      ),
      child: Column(
        children: [
          // TOP DECORATION
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 30, child: Divider(color: purple)),

              const SizedBox(width: 12),

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [purple, Color(0xFF6D28D9)],
                  ),
                  boxShadow: [
                    BoxShadow(color: purple.withOpacity(0.4), blurRadius: 20),
                  ],
                ),
                child: const Icon(Icons.chat, color: Colors.white, size: 28),
              ),

              const SizedBox(width: 12),

              const SizedBox(width: 30, child: Divider(color: purple)),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Start a New AI Conversation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Chat with AI in any language. Voice, text,\n'
            'image and translation are all supported\n'
            'automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 11.5,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 17),

          // START BUTTON
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(colors: [blue, violet]),
              ),
              child: ElevatedButton(
                onPressed: _openChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 17),

                    SizedBox(width: 8),

                    Text(
                      'Start Chat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Spacer(),

                    Icon(Icons.arrow_forward, size: 19),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT CHAT
  // ============================================================

  Widget _buildRecentChat(HistoryModel chat, int index) {
    final List<IconData> icons = [
      Icons.chat_bubble,
      Icons.image,
      Icons.translate,
    ];

    final List<Color> iconColors = [
      blue,
      const Color(0xFF0D9488),
      const Color(0xFFD97706),
    ];

    final Color itemColor = index.isEven ? cardColor : const Color(0xFF0C1527);

    final Color iconColor = iconColors[index % iconColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: itemColor),
      child: Row(
        children: [
          // ICON
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icons[index % icons.length],
              color: iconColor,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.question.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  chat.answer.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // DATE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatRecentDate(chat.dateTime),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 5),

              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  // IMPORTANT:
  // This accepts both String and DateTime.
  // This prevents the common type error:
  // "The argument type DateTime can't be assigned to String"
  // ============================================================

  String _formatRecentDate(dynamic value) {
    try {
      DateTime date;

      if (value is DateTime) {
        date = value;
      } else {
        date = DateTime.parse(value.toString());
      }

      final DateTime now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        final int hour = date.hour == 0
            ? 12
            : date.hour > 12
            ? date.hour - 12
            : date.hour;

        final String minute = date.minute.toString().padLeft(2, '0');

        final String period = date.hour >= 12 ? 'PM' : 'AM';

        return '$hour:$minute $period';
      }

      final int difference = now.difference(date).inDays;

      if (difference == 1) {
        return 'Yesterday';
      }

      if (difference > 1 && difference < 7) {
        return '$difference days ago';
      }

      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // RECENT CHATS SECTION
  // ============================================================

  Widget _buildRecentChats(HistoryProvider historyProvider) {
    if (historyProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: purple),
        ),
      );
    }

    if (historyProvider.historyList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white.withOpacity(0.3),
              size: 30,
            ),

            const SizedBox(height: 10),

            Text(
              'No conversations yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final recentChats = historyProvider.historyList.take(3).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1628),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ...List.generate(recentChats.length, (index) {
            return _buildRecentChat(recentChats[index], index);
          }),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: selectedIndex,
            selectedItemColor: purple,
            unselectedItemColor: Colors.white54,
            type: BottomNavigationBarType.fixed,

            onTap: (index) {
              switch (index) {
                case 0:
                  setState(() {
                    selectedIndex = 0;
                  });
                  break;

                case 1:
                  _openChat();
                  break;

                case 2:
                  _openHistory();
                  break;

                case 3:
                  _openProfile();
                  break;
              }
            },

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history),
                label: 'History',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer2<HistoryProvider, ProfileProvider>(
      builder: (context, historyProvider, profileProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,

          // ======================================================
          // BODY
          // ======================================================
          body: RefreshIndicator(
            color: purple,
            backgroundColor: cardColor,

            onRefresh: () async {
              await historyProvider.loadHistory();
            },

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(18, 12, 18, 25),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // HEADER
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // WELCOME
                  _buildWelcome(profileProvider),

                  const SizedBox(height: 22),

                  // HERO CARD
                  _buildHeroCard(),

                  const SizedBox(height: 16),

                  // START CHAT
                  _buildStartChatCard(),

                  const SizedBox(height: 25),

                  // RECENT CHAT TITLE
                  Row(
                    children: [
                      const Text(
                        'Recent Chats',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: _openHistory,
                        child: const Row(
                          children: [
                            Text(
                              'See all',
                              style: TextStyle(
                                color: lightPurple,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(width: 3),

                            Icon(
                              Icons.chevron_right,
                              color: lightPurple,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  // RECENT CHATS
                  _buildRecentChats(historyProvider),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ======================================================
          // BOTTOM NAVIGATION
          // ======================================================
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }
}
