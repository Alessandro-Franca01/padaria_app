import 'package:intl/intl.dart';

enum MessageSender {
  user,
  bakery
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  String get formattedTime => DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: MessageSender.values[json['sender'] ?? 0],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.index,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
