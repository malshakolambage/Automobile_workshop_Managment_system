import 'package:flutter/material.dart';
import 'package:customer_app/services/api_service.dart';
import 'feedback_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final data = await ApiService.getAppointments();
    if (!mounted) return;
    setState(() {
      history = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Service History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : history.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          "No bookings yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];

                      final status = (item["status"] ?? "Pending") as String;

                      final statusColor = status == "Completed"
                          ? Colors.greenAccent
                          : status == "Cancelled" || status == "Rejected"
                              ? Colors.redAccent
                              : status == "Approved"
                                  ? Colors.lightBlueAccent
                                  : Colors.amber;

                      final vehicleLabel = item["model"] != null
                          ? "${item["model"]}"
                          : "Vehicle";
                      final plate = item["plate_number"] ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.06),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(.12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFF23314F),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicleLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        plate,
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            _infoRow(Icons.build, "Service", item["service_type"] ?? "-"),
                            const SizedBox(height: 10),
                            _infoRow(Icons.info_outline, "Progress", item["progress"] ?? "-"),
                            const SizedBox(height: 10),
                            _infoRow(Icons.calendar_today, "Date", _formatDate(item["appointment_date"])),
                            const SizedBox(height: 10),
                            _infoRow(Icons.access_time, "Time", item["appointment_time"] ?? "-"),
                            if (status == "Completed") ...[
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const FeedbackPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.star_outline),
                                  label: const Text("Leave Feedback"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.amber,
                                    side: const BorderSide(color: Colors.amber),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              )
                            ]
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  static String _formatDate(dynamic raw) {
    if (raw == null) return "-";
    // Backend returns a DATE which comes through as an ISO string like
    // "2026-07-15T00:00:00.000Z"
    final s = raw.toString();
    final datePart = s.split("T").first;
    final parts = datePart.split("-");
    if (parts.length == 3) {
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    }
    return datePart;
  }

  static Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 18),
        const SizedBox(width: 10),
        Text(
          "$title : ",
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }
}
