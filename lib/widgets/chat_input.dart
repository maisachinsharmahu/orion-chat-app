import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../theme/app_theme.dart';

/// Floating chat input bar with modern styling.
class ChatInput extends StatefulWidget {
  final Function(String text, String? imagePath) onSend;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const ChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.controller,
    this.focusNode,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _hasText = false;
  bool _isListening = false;
  String? _selectedImagePath;
  bool _isInternalController = false;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeFocusNode();
  }

  void _initializeController() {
    _isInternalController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_textListener);
  }

  void _initializeFocusNode() {
    _isInternalFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_textListener);
      if (_isInternalController) {
        _controller.dispose();
      }
      _initializeController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (_isInternalFocusNode) {
        _focusNode.dispose();
      }
      _initializeFocusNode();
    }
  }

  void _textListener() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      if (mounted) setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_textListener);
    if (_isInternalController) _controller.dispose();
    if (_isInternalFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImagePath == null) return;

    widget.onSend(text, _selectedImagePath);
    _controller.clear();
    setState(() => _selectedImagePath = null);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImagePath = image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (error) => debugPrint('STT Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              // Move cursor to end
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.black,
        border: Border(top: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image Preview ───────────────────────────────
          if (_selectedImagePath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImagePath!),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: InkWell(
                      onTap: () => setState(() => _selectedImagePath = null),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Main Input Row ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Plus Button ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: AppTheme.textSecondary,
                  iconSize: 24,
                ),
              ),
              const SizedBox(width: 8),

              // ── Text Input ──────────────────────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: widget.enabled,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSend(),
                          style: AppTheme.bodyLarge,
                          cursorColor: AppTheme.primaryBrand,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            hintStyle: AppTheme.bodyMedium,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            isDense: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      _buildInternalIconButton(
                        _isListening ? Icons.mic : Icons.mic_none_rounded,
                        _toggleListening,
                        color: _isListening
                            ? Colors.redAccent
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Send Button ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: (_hasText || _selectedImagePath != null)
                      ? AppTheme.accentColor
                      : AppTheme.surfaceLight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded),
                    iconSize: 18,
                    color: (_hasText || _selectedImagePath != null)
                        ? AppTheme.black
                        : AppTheme.textSecondary,
                    onPressed:
                        ((_hasText || _selectedImagePath != null) &&
                            widget.enabled)
                        ? _handleSend
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInternalIconButton(
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color ?? AppTheme.textSecondary, size: 20),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
