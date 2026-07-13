import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/chat_service.dart';
import '../services/api_client.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().fetchMessages();
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    try {
      await context.read<ChatService>().sendMessage(text);
      Future.delayed(Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : 'Não foi possível enviar a mensagem.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final timeColor = isUser
        ? colorScheme.onPrimary.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: textColor),
            ),
            SizedBox(height: 4),
            Text(
              message.formattedTime,
              style: TextStyle(fontSize: 10, color: timeColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat com a Padaria'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<ChatService>().fetchMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chat, child) {
                final msgs = chat.messages;
                return RefreshIndicator(
                  onRefresh: () => chat.fetchMessages(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(msgs[index]);
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: Offset(0, -2)),
              ],
            ),
            padding: EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton.filled(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
