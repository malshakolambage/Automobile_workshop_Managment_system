import 'package:flutter/material.dart';
import 'package:customer_app/services/api_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int? selectedVehicleId;
  int? selectedAppointmentId;

  int rating = 0;

  final TextEditingController feedbackController = TextEditingController();

  List<dynamic> vehicles = [];
  List<dynamic> completedAppointments = [];
  List<dynamic> previousReviews = [];

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      ApiService.getVehicles(),
      ApiService.getAppointments(),
      ApiService.getFeedbackList(),
    ]);

    if (!mounted) return;
    setState(() {
      vehicles = results[0];
      completedAppointments =
          results[1].where((a) => a["status"] == "Completed").toList();
      previousReviews = results[2];
      _loading = false;
    });
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    if (selectedVehicleId == null) {
      _showError("Please select a vehicle");
      return;
    }
    if (selectedAppointmentId == null) {
      _showError("Please select the completed service");
      return;
    }
    if (rating == 0) {
      _showError("Please give a star rating");
      return;
    }

    setState(() => _submitting = true);

    final result = await ApiService.submitFeedback(
      vehicleId: selectedVehicleId,
      appointmentId: selectedAppointmentId,
      rating: rating,
      comment: feedbackController.text.trim().isEmpty
          ? null
          : feedbackController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['error'] != null) {
      _showError(result['error']);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted, thank you!")),
    );

    setState(() {
      selectedVehicleId = null;
      selectedAppointmentId = null;
      rating = 0;
      feedbackController.clear();
    });

    _load();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          "Feedback & Ratings",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Rate Your Experience",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Vehicle",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              dropdownColor: const Color(0xFF1A1A2E),
              decoration: _inputDecoration(),
              value: selectedVehicleId,
              style: const TextStyle(color: Colors.white),
              items: vehicles.map<DropdownMenuItem<int>>((v) {
                return DropdownMenuItem<int>(
                  value: v['id'] as int,
                  child: Text("${v['model']} - ${v['plate_number']}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVehicleId = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Completed Service",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            completedAppointments.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.06),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      "No completed services yet to review.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF1A1A2E),
                    decoration: _inputDecoration(),
                    value: selectedAppointmentId,
                    style: const TextStyle(color: Colors.white),
                    items: completedAppointments.map<DropdownMenuItem<int>>((a) {
                      final label =
                          "${a['service_type']} • ${_formatDate(a['appointment_date'])}";
                      return DropdownMenuItem<int>(
                        value: a['id'] as int,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedAppointmentId = value;
                      });
                    },
                  ),

            const SizedBox(height: 20),

            const Text(
              "Your Feedback",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: feedbackController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                hint: "Write your experience here...",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submitting ? null : submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Submit Feedback",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              "Previous Reviews",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 15),

            if (previousReviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "You haven't left any reviews yet.",
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ...previousReviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _reviewCard(r),
                  )),
          ],
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

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _reviewCard(dynamic r) {
    final rating = (r["rating"] ?? 0) as int;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if ((r["comment"] ?? "").toString().isNotEmpty)
            Text(
              r["comment"].toString(),
              style: const TextStyle(color: Colors.white70),
            ),
          const SizedBox(height: 10),
          Text(
            _formatDate(r["created_at"]),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
