import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/message.dart';
import '../providers/message_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/ui_provider.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Delay provider modifications until after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load messages when screen initializes
      ref.read(messageProvider.notifier).loadMessages();
      // Mark messages as read when screen is viewed
      ref.read(messageProvider.notifier).markAsRead();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(messageProvider.notifier).addMessage(text, isFromUser: true);
      _textController.clear();
      _scrollToBottom();
      // Use StateProvider instead of setState
      ref.read(emojiPickerVisibleProvider.notifier).state = false;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(image.path);
        final fileName = 'image_$timestamp$extension';
        final imagesDir = Directory(path.join(appDir.path, 'messages_images'));
        
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        
        final newPath = path.join(imagesDir.path, fileName);
        final copiedFile = await File(image.path).copy(newPath);
        
        if (await copiedFile.exists()) {
          ref.read(messageProvider.notifier).addMessage(
            '📷 Image',
            isFromUser: true,
            imagePath: copiedFile.absolute.path,
            type: MessageType.image,
          );
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = path.extension(image.path);
        final fileName = 'photo_$timestamp$extension';
        final imagesDir = Directory(path.join(appDir.path, 'messages_images'));
        
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        
        final newPath = path.join(imagesDir.path, fileName);
        final copiedFile = await File(image.path).copy(newPath);
        
        if (await copiedFile.exists()) {
          ref.read(messageProvider.notifier).addMessage(
            '📷 Photo',
            isFromUser: true,
            imagePath: copiedFile.absolute.path,
            type: MessageType.image,
          );
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _textController.text += emoji.emoji;
  }

  void _toggleEmojiPicker() {
    // Use StateProvider instead of setState
    final current = ref.read(emojiPickerVisibleProvider);
    ref.read(emojiPickerVisibleProvider.notifier).state = !current;
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messageProvider);
    final showEmojiPicker = ref.watch(emojiPickerVisibleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Auto-scroll when messages change
    ref.listen(messageProvider, (previous, next) {
      next.whenData((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Messages'),
                  content: const Text('Are you sure you want to clear all messages?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(messageProvider.notifier).clearMessages();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start a conversation!'),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _MessageBubble(message: messages[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading messages: $error'),
              ),
            ),
          ),
          _buildInputArea(),
          if (showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _onEmojiSelected(emoji);
                },
                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showEmojiPicker = ref.watch(emojiPickerVisibleProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              onPressed: _toggleEmojiPicker,
            ),
            IconButton(
              icon: Icon(
                Icons.image_outlined,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Photo Library'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImage();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Camera'),
                          onTap: () {
                            Navigator.of(context).pop();
                            _takePhoto();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  Widget _buildImageWidget(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(imagePath),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return Container(
            width: 200,
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[300],
              child: const Icon(Icons.support_agent, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.blue
                    : (isDark ? Colors.grey[700] : Colors.grey[200]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image && message.imagePath != null)
                    _buildImageWidget(message.imagePath!),
                  if (message.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: message.type == MessageType.image ? 8 : 0),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                          fontSize: message.type == MessageType.emoji ? 32 : 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    message.formattedTime,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : (isDark ? Colors.grey[300] : Colors.black54),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
