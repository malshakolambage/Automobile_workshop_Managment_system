import 'package:flutter/material.dart';
import 'package:customer_app/services/api_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController = ScrollController();

  List<dynamic> messages = [];
  int? userId;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await ApiService.getUserId();
    if (id == null) {
      setState(() => _loading = false);
      return;
    }

    final data = await ApiService.getChatMessages(id);
    if (!mounted) return;
    setState(() {
      userId = id;
      messages = data;
      _loading = false;
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || userId == null || _sending) return;

    setState(() => _sending = true);
    messageController.clear();

    final result = await ApiService.sendChatMessage(userId!, text);

    if (!mounted) return;
    setState(() => _sending = false);

    if (result['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
      return;
    }

    setState(() {
      messages.add({
        "message": text,
        "sender": "customer",
      });
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071120),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Workshop Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),

      body: Column(
        children: [

          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),

            child: const Row(
              children: [

                CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.car_repair),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "AutoNex Workshop",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "Online",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(
                        child: Text(
                          "No messages yet. Say hello!",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),

              itemCount: messages.length,

              itemBuilder: (context, index) {
                final message = messages[index];
                final isCustomer = message["sender"] == "customer";

                return Align(
                  alignment: isCustomer
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),

                    constraints: const BoxConstraints(
                      maxWidth: 280,
                    ),

                    decoration: BoxDecoration(
                      color: isCustomer
                          ? Colors.blueAccent
                          : Colors.white.withOpacity(0.08),

                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: Text(
                      message["message"] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: messageController,

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration: InputDecoration(
                      hintText: "Type message...",
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),

                      filled: true,
                      fillColor:
                          Colors.white.withOpacity(0.08),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: _sending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
