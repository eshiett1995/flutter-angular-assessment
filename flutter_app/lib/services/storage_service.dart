import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const String _messagesKey = 'saved_messages';

  Future<void> saveMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(messagesJson);
      await prefs.setString(_messagesKey, jsonString);
      print('💾 Saved ${messages.length} messages to SharedPreferences');
    } catch (e) {
      print('❌ Error saving messages: $e');
      rethrow;
    }
  }

  Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson == null || messagesJson.isEmpty) {
        print('📭 No saved messages found in SharedPreferences');
        return [];
      }

      final List<dynamic> decoded = jsonDecode(messagesJson);
      final messages = decoded.map((json) => Message.fromJson(json)).toList();
      print('📥 Successfully loaded ${messages.length} messages from SharedPreferences');
      return messages;
    } catch (e) {
      print('❌ Error loading messages: $e');
      return [];
    }
  }

  Future<void> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }
}

