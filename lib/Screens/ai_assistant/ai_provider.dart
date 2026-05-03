import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:image_picker/image_picker.dart';

// ── Message Model ─────────────────────────────────────────────────
class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final File? imageFile;
  final List<String>? suggestions;
  final DateTime timestamp;

  AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.imageFile,
    this.suggestions,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ── AI State ──────────────────────────────────────────────────────
class AiState {
  final List<AiMessage> messages;
  final bool isConnected;
  final bool isTyping;
  final File? attachedImage;
  final String? error;

  const AiState({
    this.messages = const [],
    this.isConnected = false,
    this.isTyping = false,
    this.attachedImage,
    this.error,
  });

  AiState copyWith({
    List<AiMessage>? messages,
    bool? isConnected,
    bool? isTyping,
    File? attachedImage,
    String? error,
  }) {
    return AiState(
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
      attachedImage: attachedImage ?? this.attachedImage,
      error: error ?? this.error,
    );
  }
}

// ── AI Notifier ───────────────────────────────────────────────────
class AiNotifier extends StateNotifier<AiState> {
  io.Socket? _socket;
  final _picker = ImagePicker();

  AiNotifier() : super(const AiState());

  void connect() {
    try {
      _socket = io.io(
        'https://your-ai-backend.com',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setTimeout(5000)
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        state = state.copyWith(isConnected: true);
      });

      _socket!.onDisconnect((_) {
        state = state.copyWith(isConnected: false);
      });

      // Listen for AI responses
      _socket!.on('ai_response', (data) {
        final message = AiMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: data['text'] as String? ?? '',
          isUser: false,
          suggestions: data['suggestions'] != null
              ? List<String>.from(data['suggestions'])
              : null,
        );
        state = state.copyWith(
          messages: [...state.messages, message],
          isTyping: false,
        );
      });

      // Typing indicator
      _socket!.on('ai_typing', (_) {
        state = state.copyWith(isTyping: true);
      });

      _socket!.on('connect_error', (error) {
        // Fallback: simulate connection for demo
        state = state.copyWith(isConnected: true);
      });
    } catch (e) {
      // Demo mode — simulate connected
      state = state.copyWith(isConnected: true);
    }
  }

  void sendMessage(String text) {
    final userMsg = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      imageFile: state.attachedImage,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      attachedImage: null,
      isTyping: true,
    );

    if (_socket?.connected == true) {
      _socket!.emit('user_message', {
        'text': text,
        'hasImage': state.attachedImage != null,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      // Demo: simulate AI response
      _simulateAiResponse(text);
    }
  }

  Future<void> _simulateAiResponse(String userText) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final responses = _getSmartResponse(userText);

    final aiMsg = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responses.$1,
      isUser: false,
      suggestions: responses.$2,
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
    );
  }

  (String, List<String>?) _getSmartResponse(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('cinematic')) {
      return (
        'Great choice! I\'ll apply a cinematic grade — boosting contrast, adding cool shadows, and warming the highlights. This style is inspired by blockbuster color grading.',
        ['Apply it now', 'Try a darker look', 'Show me the difference'],
      );
    }
    if (lower.contains('vintage') || lower.contains('retro')) {
      return (
        'Vintage it is! I\'ll desaturate slightly, add warm tones, and apply a subtle film grain overlay for that authentic analog feel.',
        ['Apply vintage', 'Try sepia instead', 'More faded look'],
      );
    }
    if (lower.contains('enhance') || lower.contains('auto')) {
      return (
        'Analyzing your photo... I\'ve detected it\'s slightly underexposed with muted colors. I recommend increasing brightness by +0.3, boosting saturation by +0.4, and adding a touch of clarity.',
        ['Apply suggestions', 'Adjust manually', 'Try a different style'],
      );
    }
    if (lower.contains('black') ||
        lower.contains('white') ||
        lower.contains('mono')) {
      return (
        'For a striking black & white, I\'ll convert to mono and boost contrast to emphasize textures and shapes. Want me to also add a slight vignette?',
        ['Convert to B&W', 'Add vignette too', 'Try high contrast'],
      );
    }
    return (
      'I understand! Let me analyze your photo and suggest the best enhancements. What mood are you going for — cinematic, natural, vibrant, or moody?',
      ['Cinematic', 'Natural', 'Vibrant', 'Moody'],
    );
  }

  Future<void> attachImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      state = state.copyWith(attachedImage: File(picked.path));
    }
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, AiState>(
  (ref) => AiNotifier(),
);
