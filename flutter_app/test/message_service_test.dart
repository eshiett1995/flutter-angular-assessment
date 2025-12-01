import 'package:flutter_test/flutter_test.dart';
import 'package:messaging_app/models/message.dart';
import 'package:messaging_app/services/message_service.dart';
import 'package:messaging_app/services/storage_service.dart';

void main() {
  group('MessageService', () {
    late MessageService messageService;

    setUp(() {
      messageService = MessageService();
    });

    tearDown(() {
      messageService.dispose();
    });

    test('should initialize with welcome message when no saved messages', () async {
      await messageService.loadMessages();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final messages = messageService.messages;
      expect(messages.length, greaterThan(0));
      expect(messages.first.isFromUser, isFalse);
      expect(messages.first.text, contains('Welcome'));
    });

    test('should add user message', () async {
      await messageService.loadMessages();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final initialCount = messageService.messages.length;
      messageService.addMessage('Test message', isFromUser: true);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final messages = messageService.messages;
      expect(messages.length, greaterThan(initialCount));
      expect(messages.last.text, 'Test message');
      expect(messages.last.isFromUser, isTrue);
    });

    test('should generate agent response after user message', () async {
      await messageService.loadMessages();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final initialCount = messageService.messages.length;
      messageService.addMessage('Hello', isFromUser: true);
      
      // Wait for agent response (1.5 seconds delay)
      await Future.delayed(const Duration(seconds: 2));
      
      final messages = messageService.messages;
      expect(messages.length, greaterThan(initialCount + 1));
      // Last message should be from agent
      expect(messages.last.isFromUser, isFalse);
    });

    test('should clear all messages', () async {
      await messageService.loadMessages();
      await Future.delayed(const Duration(milliseconds: 100));
      
      messageService.addMessage('Test', isFromUser: true);
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(messageService.messages.length, greaterThan(1));
      
      messageService.clearMessages();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should have welcome message after clear
      final messages = messageService.messages;
      expect(messages.length, 1);
      expect(messages.first.isFromUser, isFalse);
    });

    test('should emit messages through stream', () async {
      await messageService.loadMessages();
      await Future.delayed(const Duration(milliseconds: 100));
      
      var messageCount = 0;
      messageService.messagesStream.listen((messages) {
        messageCount = messages.length;
      });
      
      await Future.delayed(const Duration(milliseconds: 100));
      expect(messageCount, greaterThan(0));
      
      messageService.addMessage('Stream test', isFromUser: true);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(messageCount, greaterThan(1));
    });

    test('should generate unique message IDs', () {
      messageService.addMessage('Message 1', isFromUser: true);
      messageService.addMessage('Message 2', isFromUser: true);
      
      final messages = messageService.messages;
      if (messages.length >= 2) {
        expect(messages[messages.length - 2].id, isNot(equals(messages.last.id)));
      }
    });
  });

  group('StorageService', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
    });

    test('should save and load messages', () async {
      final testMessages = [
        Message(
          id: '1',
          text: 'Test message',
          timestamp: DateTime.now(),
          isFromUser: true,
        ),
        Message(
          id: '2',
          text: 'Response',
          timestamp: DateTime.now(),
          isFromUser: false,
        ),
      ];

      await storageService.saveMessages(testMessages);
      final loadedMessages = await storageService.loadMessages();

      expect(loadedMessages.length, testMessages.length);
      expect(loadedMessages[0].text, 'Test message');
      expect(loadedMessages[0].isFromUser, isTrue);
      expect(loadedMessages[1].text, 'Response');
      expect(loadedMessages[1].isFromUser, isFalse);
    });

    test('should return empty list when no messages saved', () async {
      await storageService.clearMessages();
      final messages = await storageService.loadMessages();
      expect(messages, isEmpty);
    });

    test('should clear saved messages', () async {
      final testMessages = [
        Message(
          id: '1',
          text: 'Test',
          timestamp: DateTime.now(),
          isFromUser: true,
        ),
      ];

      await storageService.saveMessages(testMessages);
      expect(await storageService.loadMessages(), isNotEmpty);

      await storageService.clearMessages();
      expect(await storageService.loadMessages(), isEmpty);
    });
  });
}

