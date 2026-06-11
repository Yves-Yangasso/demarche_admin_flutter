import 'package:flutter/material.dart';
import '../../services/chat_service.dart';

class ChatBotView extends StatefulWidget {
  const ChatBotView({super.key});

  @override
  State<ChatBotView> createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Bonjour. Je suis votre assistant numérique. Comment puis-je vous aider dans vos démarches administratives ?", "isUser": false}
  ];
  bool _isLoading = false;

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _isLoading = true;
      _controller.clear();
    });

    try {
      final response = await _chatService.sendMessage(text);
      setState(() {
        _messages.add({"text": response['reponse'], "isUser": false});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "Une erreur est survenue lors de la communication avec le serveur.", "isUser": false});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Assistant TerreAdmin', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(text: msg['text'], isUser: msg['isUser']);
              },
            ),
          ),
          if (_isLoading) 
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 16, top: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Saisissez votre demande...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(24),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
                  bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(12),
                ),
                border: !isUser ? Border.all(color: const Color(0xFFE2E8F0)) : null,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
