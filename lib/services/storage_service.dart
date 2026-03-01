import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';

class StorageService {
  static const String _keySessions = 'chat_sessions_data';

  StorageService();

  /// Get all saved sessions, sorted by date (newest first).
  Future<List<ChatSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keySessions);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      final list = jsonList.map((e) => ChatSession.fromJson(e)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Save or update a session.
  Future<void> saveSession(ChatSession session) async {
    final prefs = await SharedPreferences.getInstance();
    // Re-read current list to merge
    final all = await getAllSessions();
    final index = all.indexWhere((s) => s.id == session.id);

    if (index >= 0) {
      all[index] = session;
    } else {
      all.add(session);
    }

    // Sort
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Save back
    final String data = jsonEncode(all.map((s) => s.toJson()).toList());
    await prefs.setString(_keySessions, data);
  }

  /// Delete a session by ID.
  Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllSessions();
    all.removeWhere((s) => s.id == id);

    final String data = jsonEncode(all.map((s) => s.toJson()).toList());
    await prefs.setString(_keySessions, data);
  }
}
