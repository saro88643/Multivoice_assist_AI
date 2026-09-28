import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/history_model.dart';
import '../../providers/history_provider.dart';
import '../../providers/profile_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<HistoryModel> _filteredHistory = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<HistoryProvider>(context, listen: false);

      await provider.loadHistory();

      if (!mounted) return;

      _filterHistory("");
    });
  }

  // ============================================================
  // SEARCH HISTORY
  // ============================================================

  void _filterHistory(String value) {
    final provider = Provider.of<HistoryProvider>(context, listen: false);

    final searchText = value.toLowerCase().trim();

    final filtered = provider.historyList.where((chat) {
      return chat.question.toLowerCase().contains(searchText) ||
          chat.answer.toLowerCase().contains(searchText);
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredHistory = filtered;
    });
  }

  // ============================================================
  // DELETE ONE CHAT
  // ============================================================

  Future<void> _deleteChat(HistoryProvider provider, HistoryModel chat) async {
    if (chat.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Chat"),
          content: const Text("Are you sure you want to delete this chat?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await provider.deleteChat(chat.id!);

    if (!mounted) return;

    _filterHistory(_searchController.text);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Chat deleted")));
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  Future<void> _deleteAllChats(HistoryProvider provider) async {
    if (provider.historyList.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete All Chats"),
          content: const Text(
            "Are you sure you want to delete all chat history?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete All"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await provider.deleteAllChats();

    if (!mounted) return;

    setState(() {
      _filteredHistory = [];
    });

    _searchController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("All chat history deleted")));
  }

  // ============================================================
  // USER PROFILE IMAGE
  // ============================================================

  Widget _buildUserAvatar(ProfileProvider profile) {
    if (profile.hasProfileImage && profile.profileImagePath != null) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: Colors.blue,
        backgroundImage: FileImage(File(profile.profileImagePath!)),
      );
    }

    return const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.blue,
      child: Icon(Icons.person, color: Colors.white, size: 22),
    );
  }

  // ============================================================
  // USER HEADER
  // ============================================================

  Widget _buildUserHeader(ProfileProvider profile) {
    return Row(
      children: [
        _buildUserAvatar(profile),

        const SizedBox(width: 10),

        Text(
          profile.userName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AI HEADER
  // ============================================================

  Widget _buildAIHeader() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.green,
          child: Icon(Icons.smart_toy, color: Colors.white, size: 22),
        ),

        SizedBox(width: 10),

        Text(
          "AI",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer2<HistoryProvider, ProfileProvider>(
      builder: (context, historyProvider, profileProvider, child) {
        // ------------------------------------------------------
        // Keep filtered list synchronized
        // ------------------------------------------------------

        if (_searchController.text.isEmpty &&
            _filteredHistory.length != historyProvider.historyList.length) {
          _filteredHistory = List<HistoryModel>.from(
            historyProvider.historyList,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Chat History"),
            centerTitle: true,

            actions: [
              IconButton(
                tooltip: "Delete All",
                icon: const Icon(Icons.delete_forever),
                onPressed: () {
                  _deleteAllChats(historyProvider);
                },
              ),
            ],
          ),

          body: Column(
            children: [
              // ==================================================
              // SEARCH
              // ==================================================
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,

                  decoration: InputDecoration(
                    hintText: "Search History...",

                    prefixIcon: const Icon(Icons.search),

                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();

                              _filterHistory("");
                            },
                          )
                        : null,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onChanged: _filterHistory,
                ),
              ),

              // ==================================================
              // LOADING
              // ==================================================
              if (historyProvider.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              // ==================================================
              // HISTORY
              // ==================================================
              else
                Expanded(
                  child: _filteredHistory.isEmpty
                      ? const Center(
                          child: Text(
                            "No Chat History",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await historyProvider.loadHistory();

                            if (!mounted) return;

                            _filterHistory(_searchController.text);
                          },

                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),

                            padding: const EdgeInsets.only(bottom: 20),

                            itemCount: _filteredHistory.length,

                            itemBuilder: (context, index) {
                              final chat = _filteredHistory[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.all(15),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      // ==================================
                                      // USER
                                      // ==================================
                                      _buildUserHeader(profileProvider),

                                      const SizedBox(height: 10),

                                      Text(
                                        chat.question,
                                        style: const TextStyle(fontSize: 16),
                                      ),

                                      const SizedBox(height: 15),

                                      // ==================================
                                      // AI
                                      // ==================================
                                      _buildAIHeader(),

                                      const SizedBox(height: 10),

                                      Text(
                                        chat.answer,
                                        style: const TextStyle(fontSize: 16),
                                      ),

                                      const SizedBox(height: 15),

                                      // ==================================
                                      // DATE + DELETE
                                      // ==================================
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              chat.dateTime,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),

                                          IconButton(
                                            tooltip: "Delete",

                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),

                                            onPressed: () {
                                              _deleteChat(
                                                historyProvider,
                                                chat,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}
