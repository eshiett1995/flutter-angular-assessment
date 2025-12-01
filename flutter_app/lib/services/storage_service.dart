import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const String _messagesKey = 'saved_messages';

  Future<void> saveMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await prefs.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      // Handle error silently or log it
      print('Error saving messages: $e');
    }
  }

  Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson == null || messagesJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(messagesJson);
      return decoded.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Error loading messages: $e');
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

