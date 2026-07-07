import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "Booking Confirmed",
        "message":
            "Your booking for Toyota Prius has been confirmed.",
        "time": "10 mins ago",
        "icon": Icons.check_circle,
        "color": Colors.green,
      },
      {
        "title": "Vehicle Under Repair",
        "message":
            "Your vehicle is currently being repaired.",
        "time": "1 hour ago",
        "icon": Icons.build_circle,
        "color": Colors.orange,
      },
      {
        "title": "Service Completed",
        "message":
            "Your vehicle service has been completed successfully.",
        "time": "Yesterday",
        "icon": Icons.car_repair,
        "color": Colors.blue,
      },
      {
        "title": "Leave Feedback",
        "message":
            "Tell us about your service experience.",
        "time": "Yesterday",
        "icon": Icons.star,
        "color": Colors.amber,
      },
      {
        "title": "Booking Cancelled",
        "message":
            "Your booking request has been cancelled.",
        "time": "2 days ago",
        "icon": Icons.cancel,
        "color": Colors.redAccent,
      },
    ];

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

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.06),
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
                  backgroundColor:
                      (notification["color"] as Color).withOpacity(.15),
                  child: Icon(
                    notification["icon"] as IconData,
                    color: notification["color"] as Color,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification["title"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        notification["message"] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        notification["time"] as String,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}