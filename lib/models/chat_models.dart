enum MessageSender {
  user,
  ai
}

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    String? id,
    this.isLoading = false,
  }) : 
    this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    this.timestamp = timestamp ?? DateTime.now();

  // Create a loading message placeholder while AI is generating a response
  factory ChatMessage.loading() {
    return ChatMessage(
      text: 'Thinking...',
      sender: MessageSender.ai,
      isLoading: true,
    );
  }
  
  // Copy with method for updating messages
  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Predefined responses and prompts for the AI
class AIResponseGenerator {
  // Sample questions to suggest to the user
  static List<String> getSampleQuestions() {
    return [
      "How much did I spend this month?",
      "What's my biggest expense category?",
      "How am I doing on my savings goals?",
      "Compare my income vs expenses",
      "What financial advice can you give me?",
      "How can I improve my budget?",
    ];
  }
  
  // Generate greeting message
  static String getGreeting() {
    final hour = DateTime.now().hour;
    String greeting = "Hello";
    
    if (hour < 12) {
      greeting = "Good morning";
    } else if (hour < 17) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good evening";
    }
    
    return "$greeting! I'm your FinnSathi AI assistant. I can help answer questions about your finances, analyze your spending patterns, and offer personalized advice. What would you like to know today?";
  }
}
