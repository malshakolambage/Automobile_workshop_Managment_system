import 'package:flutter/material.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const progress = 0.6;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Vehicle Tracking",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Vehicle Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1E3A5F),
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Toyota Prius",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "ABC-1234",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Repair Progress",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation(Colors.lightBlueAccent),
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "60% Completed",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 30),

            _infoCard(
              Icons.store,
              "Workshop",
              "AutoNex Workshop",
            ),

            _infoCard(
              Icons.build,
              "Current Status",
              "Engine Inspection",
            ),

            _infoCard(
              Icons.calendar_today,
              "Booking Date",
              "08 Jul 2026",
            ),

            _infoCard(
              Icons.schedule,
              "Estimated Completion",
              "09 Jul 2026 - 4:00 PM",
            ),

            const SizedBox(height: 30),

            const Text(
              "Repair Timeline",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _timelineTile(
              Icons.check_circle,
              Colors.green,
              "Booking Confirmed",
              "08 Jul 2026 • 9:00 AM",
            ),

            _timelineTile(
              Icons.check_circle,
              Colors.green,
              "Vehicle Received",
              "08 Jul 2026 • 10:00 AM",
            ),

            _timelineTile(
              Icons.build_circle,
              Colors.orange,
              "Repair In Progress",
              "Currently Working",
            ),

            _timelineTile(
              Icons.radio_button_unchecked,
              Colors.white38,
              "Quality Inspection",
              "Pending",
            ),

            _timelineTile(
              Icons.radio_button_unchecked,
              Colors.white38,
              "Ready for Pickup",
              "Pending",
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoCard(
      IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  static Widget _timelineTile(
      IconData icon,
      Color color,
      String title,
      String subtitle,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white60,
        ),
      ),
    );
  }
}