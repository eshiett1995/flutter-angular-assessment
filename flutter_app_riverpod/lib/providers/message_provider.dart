import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../services/storage_service.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Last viewed timestamp provider - extracted into its own provider
final lastViewedTimestampProvider = StateNotifierProvider<LastViewedTimestampNotifier, DateTime?>((ref) {
  return LastViewedTimestampNotifier();
});

class LastViewedTimestampNotifier extends StateNotifier<DateTime?> {
  LastViewedTimestampNotifier() : super(null) {
    _loadLastViewedTimestamp();
  }

  static const String _key = 'last_viewed_timestamp';

  Future<void> _loadLastViewedTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_key);
      if (timestampString != null) {
        state = DateTime.parse(timestampString);
      }
    } catch (e) {
      print('Error loading last viewed timestamp: $e');
    }
  }

  Future<void> updateTimestamp(DateTime timestamp) async {
    state = timestamp;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, timestamp.toIso8601String());
    } catch (e) {
      print('Error saving last viewed timestamp: $e');
    }
  }

  void markAsRead() {
    updateTimestamp(DateTime.now());
  }
}

// Message notifier with improved structure
class MessageNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  MessageNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref ref;
  final List<Message> _messages = [];
  final Random _random = Random();
  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  final List<String> _agentResponses = [
    "Hello! How can I assist you today?",
    "I understand your concern. Let me help you with that.",
    "That's a great question! Here's what I can tell you...",
    "I'm here to help. Can you provide more details?",
    "Thank you for reaching out. I'll look into this for you.",
    "I see what you mean. Let me check on that for you.",
    "Absolutely! I can help you with that right away.",
    "No problem at all. Let me guide you through this.",
    "I appreciate your patience. Here's the solution...",
    "That makes sense. Here's what we can do...",
  ];

  Future<void> _initialize() async {
    if (_isInitialized) {
      state = AsyncValue.data(_messages);
      return;
    }

    if (_initializationFuture != null) {
      return _initializationFuture!;
    }

    _initializationFuture = _performInitialization();
    await _initializationFuture;
  }

  Future<void> _performInitialization() async {
    try {
      state = const AsyncValue.loading();
      final storageService = ref.read(storageServiceProvider);
      final savedMessages = await storageService.loadMessages();
      
      _messages.clear();
      
      if (savedMessages.isNotEmpty) {
        _messages.addAll(savedMessages);
        print('✅ Loaded ${savedMessages.length} saved messages from storage');
      } else {
        _initializeDefaultMessage();
        await _saveMessages();
        print('✅ No saved messages found, initialized with welcome message');
      }
      
      _isInitialized = true;
      state = AsyncValue.data(_messages);
    } catch (e, stackTrace) {
      print('❌ Error initializing MessageService: $e');
      _isInitialized = true;
      if (_messages.isEmpty) {
        _initializeDefaultMessage();
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void _initializeDefaultMessage() {
    _messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Welcome to our support chat! I'm here to help you with any questions or issues you might have.",
      timestamp: DateTime.now(),
      isFromUser: false,
    ));
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  void addMessage(String text, {required bool isFromUser, String? imagePath, MessageType type = MessageType.text}) {
    final message = Message(
      id: _generateId(),
      text: text,
      timestamp: DateTime.now(),
      isFromUser: isFromUser,
      type: type,
      imagePath: imagePath,
    );

    _messages.add(message);
    state = AsyncValue.data(List.from(_messages));
    _saveMessages();
    
    // Update unread count if it's an agent message
    if (!isFromUser) {
      state = AsyncValue.data(List.from(_messages));
    }

    // Simulate agent response after user message (only for text messages)
    if (isFromUser && type == MessageType.text) {
      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        final response = _agentResponses[_random.nextInt(_agentResponses.length)];
        addMessage(response, isFromUser: false);
      });
    }
  }

  void clearMessages() {
    _messages.clear();
    final storageService = ref.read(storageServiceProvider);
    storageService.clearMessages();
    _initializeDefaultMessage();
    ref.read(lastViewedTimestampProvider.notifier).markAsRead();
    state = AsyncValue.data(List.from(_messages));
    _saveMessages();
  }

  Future<void> _saveMessages() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      await storageService.saveMessages(_messages);
      print('Saved ${_messages.length} messages to storage');
    } catch (e) {
      print('Error saving messages: $e');
    }
  }
  
  Future<void> loadMessages() async {
    if (!_isInitialized) {
      await _initialize();
    } else {
      state = AsyncValue.data(List.from(_messages));
    }
  }

  void markAsRead() {
    ref.read(lastViewedTimestampProvider.notifier).markAsRead();
    // Trigger rebuild by updating state
    state = AsyncValue.data(List.from(_messages));
  }

  List<Message> get messages => List.unmodifiable(_messages);
}

// Main message provider
final messageProvider = StateNotifierProvider<MessageNotifier, AsyncValue<List<Message>>>((ref) {
  return MessageNotifier(ref);
});

// Unread count provider - now uses the separate lastViewedTimestampProvider
final unreadCountProvider = Provider<int>((ref) {
  final messagesAsync = ref.watch(messageProvider);
  final lastViewed = ref.watch(lastViewedTimestampProvider);
  
  return messagesAsync.when(
    data: (messages) {
      if (lastViewed == null) return 0;
      return messages.where((m) => 
        !m.isFromUser && m.timestamp.isAfter(lastViewed)
      ).length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

