import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedVehicle;
  String? selectedService;

  final List<String> vehicles = [
    "Toyota Prius - ABC 1234",
    "Honda Fit - CAA 4567",
    "Suzuki Alto - CAB 9876",
  ];

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

  void submitBooking() {
    // FIX: previously onPressed: () {} did nothing at all, and nothing
    // stopped a user from submitting a blank form. Validate first.
    if (selectedVehicle == null) {
      _showError("Please select a vehicle");
      return;
    }
    if (selectedService == null) {
      _showError("Please select a service type");
      return;
    }
    if (dateController.text.isEmpty) {
      _showError("Please select a preferred date");
      return;
    }
    if (timeController.text.isEmpty) {
      _showError("Please select a preferred time");
      return;
    }

    // TODO: replace with a real API call, e.g.
    // await BookingService().create(
    //   vehicle: selectedVehicle!,
    //   service: selectedService!,
    //   date: dateController.text,
    //   time: timeController.text,
    //   note: noteController.text,
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking request submitted")),
    );
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

      body: SingleChildScrollView(
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

            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1A1A2E),
              value: selectedVehicle,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration(),
              items: vehicles.map((vehicle) {
                return DropdownMenuItem(
                  value: vehicle,
                  child: Text(vehicle),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVehicle = value;
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
                onPressed: submitBooking,
                child: const Text(
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