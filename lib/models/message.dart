/// Represents who sent the message.
enum MessageSender { user, ai }

/// A single chat message in the conversation.
class Message {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isLiked;
  final bool isUnliked;
  final String modelName;
  final String? imageUrl;

  const Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isLiked = false,
    this.isUnliked = false,
    this.modelName = 'Gemini Pro',
    this.imageUrl,
  });

  bool get isUser => sender == MessageSender.user;

  Message copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isLiked,
    bool? isUnliked,
    String? modelName,
    String? imageUrl,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isUnliked: isUnliked ?? this.isUnliked,
      modelName: modelName ?? this.modelName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // JSON Serialization

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isLiked: json['isLiked'] as bool? ?? false,
      isUnliked: json['isUnliked'] as bool? ?? false,
      modelName: json['modelName'] as String? ?? 'Gemini Pro',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isLiked': isLiked,
      'isUnliked': isUnliked,
      'modelName': modelName,
      'imageUrl': imageUrl,
    };
  }
}
