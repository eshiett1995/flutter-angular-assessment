import 'dart:async';
import 'dart:math';
import '../models/message.dart';
import 'storage_service.dart';

class MessageService {
  final _messagesController = StreamController<List<Message>>.broadcast();
  final List<Message> _messages = [];
  final Random _random = Random();
  final StorageService _storageService = StorageService();
  bool _isInitialized = false;

  Stream<List<Message>> get messagesStream => _messagesController.stream;
  List<Message> get messages => List.unmodifiable(_messages);

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

  MessageService() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    // Try to load saved messages
    final savedMessages = await _storageService.loadMessages();
    if (savedMessages.isNotEmpty) {
      _messages.addAll(savedMessages);
      _messagesController.add(_messages);
    } else {
      // Initialize with default welcome message if no saved messages
      _initializeDefaultMessage();
    }
    _isInitialized = true;
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

  void addMessage(String text, {required bool isFromUser}) {
    final message = Message(
      id: _generateId(),
      text: text,
      timestamp: DateTime.now(),
      isFromUser: isFromUser,
    );

    _messages.add(message);
    _messagesController.add(_messages);
    _saveMessages();

    // Simulate agent response after user message
    if (isFromUser) {
      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        final response = _agentResponses[_random.nextInt(_agentResponses.length)];
        addMessage(response, isFromUser: false);
      });
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
    await _storageService.saveMessages(_messages);
  }
  
  Future<void> loadMessages() async {
    await _initialize();
  }

  void dispose() {
    _messagesController.close();
  }
}

