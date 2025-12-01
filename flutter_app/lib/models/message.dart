import 'package:intl/intl.dart';

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromUser;
  final MessageType type;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromUser,
    this.type = MessageType.text,
  });

  String get formattedTime {
    return DateFormat('HH:mm').format(timestamp);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
      'type': type.toString(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFromUser: json['isFromUser'] as bool,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}

enum MessageType {
  text,
  emoji,
  image,
}

