import 'message.dart';

class ChatSession {
  final String id;
  String title;
  final List<Message> messages;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });


  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
