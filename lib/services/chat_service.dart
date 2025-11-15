import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/chat_message.dart';

class ChatService with ChangeNotifier {
  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => [..._messages];

  Future<void> loadHistoryFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chat_history');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _messages = decoded.map((e) => ChatMessage.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistoryToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_history', data);
  }

  void sendUserMessage(String content) {
    final msg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      content: content,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    _saveHistoryToStorage();
    notifyListeners();
    _autoReply();
  }

  void sendBakeryMessage(String content) {
    final msg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: MessageSender.bakery,
      content: content,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    _saveHistoryToStorage();
    notifyListeners();
  }

  void clearHistory() {
    _messages = [];
    _saveHistoryToStorage();
    notifyListeners();
  }

  void _autoReply() async {
    await Future.delayed(Duration(seconds: 1));
    sendBakeryMessage('Recebido! Em breve entraremos em contato.');
  }
}
