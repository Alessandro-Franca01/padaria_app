import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import 'api_client.dart';

class ChatService with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => [..._messages];
  bool get isLoading => _isLoading;

  Future<void> fetchMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.get('/chat-messages') as List;
      _messages = data.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      // mantém o histórico já carregado em caso de falha
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    final data = await ApiClient.post('/chat-messages', body: {'content': content});
    _messages.add(ChatMessage.fromJson(data));
    notifyListeners();
  }
}
