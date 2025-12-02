import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const String _messagesKey = 'saved_messages';

  Future<void> saveMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appDir = await getApplicationDocumentsDirectory();
      
      // Convert absolute paths to relative paths before saving
      final messagesToSave = messages.map((m) {
        if (m.type == MessageType.image && m.imagePath != null && path.isAbsolute(m.imagePath!)) {
          // Convert absolute path to relative path
          final relativePath = path.relative(m.imagePath!, from: appDir.path);
          return Message(
            id: m.id,
            text: m.text,
            timestamp: m.timestamp,
            isFromUser: m.isFromUser,
            type: m.type,
            imagePath: relativePath,
          );
        }
        return m;
      }).toList();
      
      final messagesJson = messagesToSave.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(messagesJson);
      await prefs.setString(_messagesKey, jsonString);
      
      final imageCount = messages.where((m) => m.type == MessageType.image).length;
      print('💾 Saved ${messages.length} messages to SharedPreferences (${imageCount} with images)');
      
      // Debug: Print image paths being saved
      for (var msg in messagesToSave.where((m) => m.type == MessageType.image && m.imagePath != null)) {
        print('   Image path saved (relative): ${msg.imagePath}');
      }
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
      
      // Get current app documents directory to reconstruct image paths
      final appDir = await getApplicationDocumentsDirectory();
      
      final messages = await Future.wait(decoded.map((json) async {
        final message = Message.fromJson(json);
        // Verify image file exists if message has an image
        if (message.type == MessageType.image && message.imagePath != null) {
          String? validImagePath;
          final savedPath = message.imagePath!;
          
          // Check if it's already an absolute path (for backward compatibility)
          if (path.isAbsolute(savedPath)) {
            if (File(savedPath).existsSync()) {
              validImagePath = savedPath;
              print('✅ Image file found at absolute path: $savedPath');
            } else {
              // Try to extract filename and reconstruct
              final fileName = path.basename(savedPath);
              final reconstructedPath = path.join(appDir.path, 'messages_images', fileName);
              if (File(reconstructedPath).existsSync()) {
                validImagePath = reconstructedPath;
                print('✅ Image file found at reconstructed path: $reconstructedPath');
              }
            }
          } else {
            // It's a relative path, reconstruct it
            final reconstructedPath = path.join(appDir.path, savedPath);
            if (File(reconstructedPath).existsSync()) {
              validImagePath = reconstructedPath;
              print('✅ Image file found at relative path: $reconstructedPath');
            }
          }
          
          if (validImagePath != null) {
            // Return message with valid image path
            return Message(
              id: message.id,
              text: message.text,
              timestamp: message.timestamp,
              isFromUser: message.isFromUser,
              type: MessageType.image,
              imagePath: validImagePath,
            );
          } else {
            print('⚠️ Image file not found: ${message.imagePath}');
            print('   App dir: ${appDir.path}');
            // Return message without image path if file doesn't exist
            return Message(
              id: message.id,
              text: message.text,
              timestamp: message.timestamp,
              isFromUser: message.isFromUser,
              type: MessageType.text, // Fallback to text if image is missing
            );
          }
        }
        return message;
      }));
      
      final imageCount = messages.where((m) => m.type == MessageType.image).length;
      print('📥 Successfully loaded ${messages.length} messages from SharedPreferences (${imageCount} with images)');
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

