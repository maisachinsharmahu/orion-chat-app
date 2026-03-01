import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import '../models/chat_session.dart';
import '../models/message.dart';
import '../services/mock_ai_service.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';

/// Manages the chat state — current messages, typing indicator, and persistent history.
class ChatProvider extends ChangeNotifier {
  final MockAiService _aiService;
  final StorageService _storageService;
  final _uuid = const Uuid();

  ChatProvider({MockAiService? aiService, StorageService? storageService})
    : _aiService = aiService ?? MockAiService(),
      _storageService = storageService ?? StorageService() {
    _loadHistory();
    _startNewSession();
  }

  // ── State ───────────────────────────────────────────────

  String _currentSessionId = "";
  String _currentTitle = "New Chat";
  String _currentModel = "Gemini Pro";

  final List<Message> _messages = [];
  List<ChatSession> _sessions = [];
  bool _isAiTyping = false;
  String? _errorMessage;

  // ── Getters ─────────────────────────────────────────────

  List<Message> get messages => List.unmodifiable(_messages);
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  bool get isAiTyping => _isAiTyping;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  String get currentSessionId => _currentSessionId;
  String get currentTitle => _currentTitle;
  String get currentModel => _currentModel;

  ChatSession get currentSession => ChatSession(
    id: _currentSessionId,
    title: _currentTitle,
    messages: List.from(_messages),
    createdAt: DateTime.now(), // Use current time or fetch original
  );

  List<String> get availableModels => [
    'Gemini Pro',
    'Gemini Ultra',
    'Claude 3',
    'GPT-4',
  ];

  // ── Actions ─────────────────────────────────────────────

  /// Exports current chat to PDF.
  Future<void> exportCurrentChat() async {
    if (_messages.isEmpty) return;
    await PdfService.exportChatToPdf(currentSession);
  }

  /// Loads all saved sessions from Storage.
  Future<void> _loadHistory() async {
    _sessions = await _storageService.getAllSessions();
    notifyListeners();
  }

  /// Sets the current AI model.
  void setModel(String model) {
    _currentModel = model;
    notifyListeners();
  }

  /// Starts a fresh conversation.
  void startNewChat() {
    _startNewSession();
    notifyListeners();
  }

  /// Internal helper to reset state for a new chat.
  void _startNewSession() {
    _currentSessionId = _uuid.v4();
    _currentTitle = "New Chat";
    _messages.clear();
    _errorMessage = null;
    _isAiTyping = false;
  }

  /// Switches to an existing chat session.
  void loadSession(String sessionId) {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      _currentSessionId = session.id;
      _currentTitle = session.title;
      _messages.clear();
      _messages.addAll(session.messages);
      _errorMessage = null;
      _isAiTyping = false;
      notifyListeners();
    } catch (e) {
      // Session might have been deleted
      startNewChat();
    }
  }

  /// Renames the CURRENT active session.
  Future<void> renameCurrentSession(String newTitle) async {
    if (_currentSessionId.isEmpty) return;

    _currentTitle = newTitle;
    await _saveCurrentSession();
    notifyListeners();
  }

  /// Renames a specific session by ID.
  Future<void> renameSession(String sessionId, String newTitle) async {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      session.title = newTitle;
      await _storageService.saveSession(session);

      // If it's the current one, update local state too
      if (_currentSessionId == sessionId) {
        _currentTitle = newTitle;
      }

      await _loadHistory();
      notifyListeners();
    } catch (e) {
      debugPrint("Error renaming session: $e");
    }
  }

  /// Deletes a specific session.
  Future<void> deleteSession(String sessionId) async {
    await _storageService.deleteSession(sessionId);

    // Refresh history first
    await _loadHistory();

    // If we deleted the current session, start a new one
    if (_currentSessionId == sessionId) {
      _startNewSession();
    }
    notifyListeners();
  }

  /// Clears history completely.
  Future<void> clearAllHistory() async {
    // Note: iterating over a copy to avoid modification issues
    for (var session in List.from(_sessions)) {
      await _storageService.deleteSession(session.id);
    }
    startNewChat();
    await _loadHistory();
  }

  /// Sends a user message and triggers a mock AI reply.
  Future<void> sendMessage(String text, {String? imageUrl}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && imageUrl == null) return;

    _errorMessage = null;

    // 1. Add User Message
    final userMessage = Message(
      id: _uuid.v4(),
      text: trimmed,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
    );
    _messages.add(userMessage);
    notifyListeners();

    // 2. Auto-generate title if it's the first message
    if (_messages.length == 1 && _currentTitle == "New Chat") {
      _currentTitle = _generateTitleFromMessage(
        trimmed.isNotEmpty ? trimmed : "Image Message",
      );
    }

    // 3. Save state immediately
    await _saveCurrentSession();

    // 4. AI Thinking
    _isAiTyping = true;
    notifyListeners();

    try {
      final replyText = await _aiService.getResponse(
        trimmed.isNotEmpty ? trimmed : "Analyze this image.",
      );

      final aiMessage = Message(
        id: _uuid.v4(),
        text: replyText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        modelName: _currentModel,
      );

      _messages.add(aiMessage);

      // Save again with AI reply and update timestamp to bump to top
      await _saveCurrentSession();
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isAiTyping = false;
      notifyListeners();
    }
  }

  /// Clears the CURRENT conversation content.
  void clearCurrentChat() {
    _messages.clear();
    _isAiTyping = false;
    _errorMessage = null;
    _saveCurrentSession();
    notifyListeners();
  }

  // ── Message Actions ─────────────────────────────────────

  void toggleLike(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = _messages[index];
      final newLiked = !msg.isLiked;
      _messages[index] = msg.copyWith(
        isLiked: newLiked,
        isUnliked: newLiked ? false : msg.isUnliked, // Clear dislike if liking
      );
      _saveCurrentSession();
      notifyListeners();
    }
  }

  void toggleUnlike(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = _messages[index];
      final newUnliked = !msg.isUnliked;
      _messages[index] = msg.copyWith(
        isUnliked: newUnliked,
        isLiked: newUnliked ? false : msg.isLiked, // Clear like if unliking
      );
      _saveCurrentSession();
      notifyListeners();
    }
  }

  Future<void> copyMessage(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // ── Helpers ─────────────────────────────────────────────

  Future<void> _saveCurrentSession() async {
    if (_currentSessionId.isEmpty) return;

    final session = ChatSession(
      id: _currentSessionId,
      title: _currentTitle,
      messages: List.from(_messages), // Create a copy
      createdAt: DateTime.now(), // Updating timestamp makes it jump to top
    );

    await _storageService.saveSession(session);
    await _loadHistory(); // Refresh sidebar list
  }

  String _generateTitleFromMessage(String message) {
    // Take first 30 chars or 5 words
    if (message.length > 30) {
      return "${message.substring(0, 30)}...";
    }
    return message;
  }
}
