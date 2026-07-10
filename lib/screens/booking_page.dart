import 'package:flutter/material.dart';
import 'package:customer_app/services/api_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int? selectedVehicleId;
  String? selectedService;

  List<dynamic> vehicles = [];
  bool _loadingVehicles = true;
  bool _submitting = false;

  final List<String> services = [
    "Full Service",
    "Oil Change",
    "Brake Service",
    "Engine Repair",
    "Battery Replacement",
    "AC Repair",
    "Wheel Alignment",
    "Tyre Replacement",
  ];

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime? _pickedDate;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final data = await ApiService.getVehicles();
    if (!mounted) return;
    setState(() {
      vehicles = data;
      _loadingVehicles = false;
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      _pickedDate = picked;
      dateController.text =
          "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      timeController.text = picked.format(context);
    }
  }

  Future<void> submitBooking() async {
    if (selectedVehicleId == null) {
      _showError(vehicles.isEmpty
          ? "Add a vehicle in your Profile first"
          : "Please select a vehicle");
      return;
    }
    if (selectedService == null) {
      _showError("Please select a service type");
      return;
    }
    if (_pickedDate == null) {
      _showError("Please select a preferred date");
      return;
    }
    if (timeController.text.isEmpty) {
      _showError("Please select a preferred time");
      return;
    }

    setState(() => _submitting = true);

    // Backend wants an ISO date (YYYY-MM-DD)
    final iso =
        "${_pickedDate!.year.toString().padLeft(4, '0')}-${_pickedDate!.month.toString().padLeft(2, '0')}-${_pickedDate!.day.toString().padLeft(2, '0')}";

    final result = await ApiService.createAppointment(
      vehicleId: selectedVehicleId!,
      serviceType: selectedService!,
      appointmentDate: iso,
      appointmentTime: timeController.text,
      notes: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['error'] != null) {
      _showError(result['error']);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking request submitted")),
    );

    setState(() {
      selectedVehicleId = null;
      selectedService = null;
      dateController.clear();
      timeController.clear();
      noteController.clear();
      _pickedDate = null;
    });
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
          "Book Service",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: _loadingVehicles
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Vehicle",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (vehicles.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "No vehicles on your account yet. Add one from the Profile tab first.",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              DropdownButtonFormField<int>(
                dropdownColor: const Color(0xFF1A1A2E),
                value: selectedVehicleId,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration(),
                items: vehicles.map<DropdownMenuItem<int>>((v) {
                  final label = "${v['model']} - ${v['plate_number']}";
                  return DropdownMenuItem<int>(
                    value: v['id'] as int,
                    child: Text(label),
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
              "Service Type",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1A1A2E),
              value: selectedService,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration(),
              items: services.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedService = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Preferred Date",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: dateController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration(
                suffix: Icons.calendar_today,
              ),
              onTap: selectDate,
            ),

            const SizedBox(height: 20),

            const Text(
              "Preferred Time",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: timeController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration(
                suffix: Icons.access_time,
              ),
              onTap: selectTime,
            ),

            const SizedBox(height: 20),

            const Text(
              "Special Request",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: noteController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration(
                hint: "Describe the issue or any special request...",
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _submitting ? null : submitBooking,
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
                        "Submit Booking Request",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    String? hint,
    IconData? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      suffixIcon: suffix == null
          ? null
          : Icon(suffix, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
