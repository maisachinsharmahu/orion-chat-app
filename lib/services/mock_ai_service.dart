import 'dart:math';

/// Simulates an AI backend by returning mock responses after a delay.
class MockAiService {
  static final _random = Random();

  /// Pool of mock AI responses to simulate variety.
  static const _responses = [
    "That's a great question! Let me think about it...\n\nBased on my analysis, I'd suggest breaking the problem into smaller parts and tackling each one systematically.",
    "Here's what I found:\n\n1. The approach you described is solid.\n2. Consider adding error handling for edge cases.\n3. Testing early will save you time later.",
    "Interesting! I've seen similar patterns before. The key insight is to focus on the user experience first and optimize performance afterward.",
    "Great point! Here are a few things to consider:\n\n• Start with a clear data model\n• Use reactive state management\n• Keep your widget tree shallow",
    "I'd recommend starting with a minimal viable solution and iterating from there. Premature optimization often leads to unnecessary complexity.",
    "That's a common challenge in mobile development. The best practice is to separate your UI logic from your business logic using a clean architecture pattern.",
    "Absolutely! Flutter makes this straightforward. You can use a combination of Provider for state management and custom widgets for reusable UI components.",
    "Here's a quick summary:\n\n**Pros:** Faster development, hot reload, single codebase.\n**Cons:** Larger app size, platform-specific features need plugins.\n\nOverall, it's a strong choice for most projects.",
  ];

  /// Returns a mock AI reply after a simulated delay of 1–2 seconds.
  Future<String> getResponse(String userMessage) async {
    final delay = Duration(milliseconds: 1000 + _random.nextInt(1000));
    await Future.delayed(delay);
    return _responses[_random.nextInt(_responses.length)];
  }
}
