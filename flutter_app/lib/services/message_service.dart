import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import 'storage_service.dart';

class MessageService {
  // Singleton instance
  static MessageService? _instance;
  static MessageService get instance {
    _instance ??= MessageService._internal();
    return _instance!;
  }
  
  MessageService._internal();

  final _messagesController = StreamController<List<Message>>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();
  final List<Message> _messages = [];
  final Random _random = Random();
  final StorageService _storageService = StorageService();
  bool _isInitialized = false;
  Future<void>? _initializationFuture;
  DateTime? _lastViewedTimestamp;

  Stream<List<Message>> get messagesStream => _messagesController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;
  List<Message> get messages => List.unmodifiable(_messages);
  
  int get unreadCount {
    if (_lastViewedTimestamp == null) return 0;
    return _messages.where((m) => 
      !m.isFromUser && m.timestamp.isAfter(_lastViewedTimestamp!)
    ).length;
  }

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
    // If already initialized, just emit current messages
    if (_isInitialized) {
      _messagesController.add(_messages);
      return;
    }
    
    // If initialization is already in progress, wait for it
    if (_initializationFuture != null) {
      return _initializationFuture!;
    }
    
    // Start initialization
    _initializationFuture = _performInitialization();
    await _initializationFuture;
  }

  Future<void> _performInitialization() async {
    try {
      // Try to load saved messages
      final savedMessages = await _storageService.loadMessages();
      
      // Clear any existing messages first to avoid duplicates
      _messages.clear();
      
      if (savedMessages.isNotEmpty) {
        // Load saved messages
        _messages.addAll(savedMessages);
        print('✅ Loaded ${savedMessages.length} saved messages from storage');
      } else {
        // Initialize with default welcome message if no saved messages
        _initializeDefaultMessage();
        // Save the welcome message immediately
        await _saveMessages();
        print('✅ No saved messages found, initialized with welcome message');
      }
      
         _isInitialized = true;
         await _loadLastViewedTimestamp();
         _messagesController.add(_messages);
         _updateUnreadCount();
       } catch (e) {
         print('❌ Error initializing MessageService: $e');
         // Even on error, mark as initialized to prevent infinite retries
         _isInitialized = true;
         // Initialize with welcome message as fallback
         if (_messages.isEmpty) {
           _initializeDefaultMessage();
         }
         _messagesController.add(_messages);
         _updateUnreadCount();
         rethrow;
       }
     }

  void _initializeDefaultMessage() {
    _messages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "Welcome to our support chat! I'm here to help you with any questions or issues you might have.",
      timestamp: DateTime.now(),
      isFromUser: false,
    ));
    _messagesController.add(_messages);
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
    _messagesController.add(_messages);
    _updateUnreadCount();
    _saveMessages();

    // Simulate agent response after user message (only for text messages)
    if (isFromUser && type == MessageType.text) {
      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        final response = _agentResponses[_random.nextInt(_agentResponses.length)];
        addMessage(response, isFromUser: false);
      });
    }
  }
  
  void markAsRead() {
    _lastViewedTimestamp = DateTime.now();
    _updateUnreadCount();
    _saveLastViewedTimestamp();
  }
  
  void _updateUnreadCount() {
    _unreadCountController.add(unreadCount);
  }
  
  Future<void> _saveLastViewedTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_lastViewedTimestamp != null) {
        await prefs.setString('last_viewed_timestamp', _lastViewedTimestamp!.toIso8601String());
      }
    } catch (e) {
      print('Error saving last viewed timestamp: $e');
    }
  }
  
  Future<void> _loadLastViewedTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString('last_viewed_timestamp');
      if (timestampString != null) {
        _lastViewedTimestamp = DateTime.parse(timestampString);
      }
    } catch (e) {
      print('Error loading last viewed timestamp: $e');
    }
  }

  void clearMessages() {
    _messages.clear();
    _messagesController.add(_messages);
    _storageService.clearMessages();
    _initializeDefaultMessage();
    _saveMessages();
  }

  Future<void> _saveMessages() async {
    try {
      await _storageService.saveMessages(_messages);
      print('Saved ${_messages.length} messages to storage');
    } catch (e) {
      print('Error saving messages: $e');
    }
  }
  
  Future<void> loadMessages() async {
    if (!_isInitialized) {
      await _initialize();
    } else {
      // Already initialized, just emit current messages
      _messagesController.add(_messages);
      _updateUnreadCount();
    }
  }

  /// Reset the service state for testing purposes
  /// This clears messages and resets initialization state
  void resetForTesting() {
    _messages.clear();
    _isInitialized = false;
    _initializationFuture = null;
    _messagesController.add(_messages);
  }

  void dispose() {
    _messagesController.close();
    _unreadCountController.close();
  }
}

