class ChatbotRuleModel {
  final int id;
  final int storeId;
  final String triggerKeyword;
  final String responseText;

  ChatbotRuleModel({
    required this.id,
    required this.storeId,
    required this.triggerKeyword,
    required this.responseText,
  });

  factory ChatbotRuleModel.fromJson(Map<String, dynamic> json) {
    return ChatbotRuleModel(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      triggerKeyword: json['trigger_keyword'] ?? '',
      responseText: json['response_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'trigger_keyword': triggerKeyword,
      'response_text': responseText,
    };
  }
}
