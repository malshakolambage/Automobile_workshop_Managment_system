import 'package:flutter/material.dart';
import 'package:customer_app/services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.getNotifications();
    if (!mounted) return;
    setState(() {
      notifications = data;
      _loading = false;
    });
  }

  Future<void> _markRead(int index) async {
    final n = notifications[index];
    if (n["is_read"] == 1) return;

    setState(() => notifications[index]["is_read"] = 1);
    await ApiService.markNotificationRead(n["id"] as int);
  }

  IconData _iconFor(String type) {
    switch (type) {
      case "success":
        return Icons.check_circle;
      case "warning":
        return Icons.build_circle;
      case "danger":
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case "success":
        return Colors.green;
      case "warning":
        return Colors.orange;
      case "danger":
        return Colors.redAccent;
      default:
        return Colors.blue;
    }
  }

  String _timeAgo(dynamic raw) {
    if (raw == null) return "";
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return "";
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
    if (diff.inHours < 24) return "${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago";
    if (diff.inDays == 1) return "Yesterday";
    return "${diff.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          "No notifications yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final type = (n["type"] ?? "info") as String;
                      final isRead = n["is_read"] == 1;

                      return InkWell(
                        onTap: () => _markRead(index),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isRead ? .04 : .08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(.08),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: _colorFor(type).withOpacity(.15),
                                child: Icon(
                                  _iconFor(type),
                                  color: _colorFor(type),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n["title"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n["message"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _timeAgo(n["created_at"]),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
