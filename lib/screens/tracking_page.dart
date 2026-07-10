import 'package:flutter/material.dart';
import 'package:customer_app/services/api_service.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  // FIX: previously everything on this page (vehicle, progress %, timeline)
  // was hardcoded. Now it's built from whichever of the customer's
  // appointments is still active (Approved and not yet Ready/Completed).
  Map<String, dynamic>? activeAppointment;
  bool _loading = true;

  // Rough ordering of the progress stages the workshop uses, so we can
  // turn a free-text `progress` value into a percentage + highlighted
  // timeline. Adjust this list if the workshop team uses different wording.
  static const List<String> _stages = [
    "Awaiting Approval",
    "Booking Confirmed",
    "Vehicle Received",
    "1st Checking",
    "In Progress",
    "Quality Inspection",
    "Ready for Pickup",
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final appointments = await ApiService.getAppointments();

    final active = appointments.cast<Map<String, dynamic>>().firstWhere(
          (a) => a["status"] == "Approved" && a["progress"] != "Ready for Pickup",
          orElse: () => {},
        );

    if (!mounted) return;
    setState(() {
      activeAppointment = active.isEmpty ? null : active;
      _loading = false;
    });
  }

  int _stageIndex(String? progress) {
    if (progress == null) return 0;
    final idx = _stages.indexWhere(
      (s) => s.toLowerCase() == progress.toLowerCase(),
    );
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (activeAppointment == null) {
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
        body: const Center(
          child: Text(
            "No active repair to track right now.",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final appt = activeAppointment!;
    final stageIdx = _stageIndex(appt["progress"] as String?);
    final progress = stageIdx / (_stages.length - 1);

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

      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(.08),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF1E3A5F),
                      child: Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt["model"] ?? "Vehicle",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          appt["plate_number"] ?? "",
                          style: const TextStyle(color: Colors.white70),
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

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${(progress * 100).round()}% Completed",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 30),

              _infoCard(Icons.build, "Service", appt["service_type"] ?? "-"),
              _infoCard(Icons.info_outline, "Current Status", appt["progress"] ?? "-"),
              _infoCard(Icons.calendar_today, "Booking Date", _formatDate(appt["appointment_date"])),
              _infoCard(Icons.access_time, "Preferred Time", appt["appointment_time"] ?? "-"),

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

              for (int i = 0; i < _stages.length; i++)
                _timelineTile(
                  i < stageIdx
                      ? Icons.check_circle
                      : i == stageIdx
                          ? Icons.build_circle
                          : Icons.radio_button_unchecked,
                  i < stageIdx
                      ? Colors.green
                      : i == stageIdx
                          ? Colors.orange
                          : Colors.white38,
                  _stages[i],
                  i < stageIdx
                      ? "Done"
                      : i == stageIdx
                          ? "In progress"
                          : "Pending",
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(dynamic raw) {
    if (raw == null) return "-";
    final s = raw.toString();
    final datePart = s.split("T").first;
    final parts = datePart.split("-");
    if (parts.length == 3) {
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    }
    return datePart;
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
