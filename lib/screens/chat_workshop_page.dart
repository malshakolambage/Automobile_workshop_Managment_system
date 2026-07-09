import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController =
      TextEditingController();

  // FIX: needed so we can auto-scroll to the newest message.
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      "message":
          "Hello! Your vehicle has been received for inspection.",
      "isCustomer": false,
    },
    {
      "message":
          "Thank you. Please let me know the estimated completion time.",
      "isCustomer": true,
    },
    {
      "message":
          "The service should be completed before 4:30 PM.",
      "isCustomer": false,
    },
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "message": messageController.text,
        "isCustomer": true,
      });
    });

    messageController.clear();

    // FIX: previously the list never scrolled after sending, so a new
    // message could land below the visible area. Wait a frame so the
    // ListView has laid out the new item, then scroll to the bottom.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071120),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Workshop Chat"),
      ),

      body: Column(
        children: [

          // Workshop Info Card
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

          // Messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),

              itemCount: messages.length,

              itemBuilder: (context, index) {
                final message = messages[index];

                return Align(
                  alignment: message["isCustomer"]
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
                      color: message["isCustomer"]
                          ? Colors.blueAccent
                          : Colors.white.withOpacity(0.08),

                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: Text(
                      message["message"],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input
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
                    icon: const Icon(
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