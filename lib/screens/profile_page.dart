import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/screens/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<dynamic> vehicles = [];
  String? _profileImagePath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Pull the latest name/email/phone straight from the server so the
    // form always reflects what's actually saved there.
    final me = await ApiService.getMe();

    if (me['error'] == null) {
      nameController.text = me['name'] ?? '';
      emailController.text = me['email'] ?? '';
      phoneController.text = me['phone'] ?? '';
    } else {
      // Fall back to whatever we last cached locally if the server is unreachable.
      nameController.text = await ApiService.getUserName() ?? '';
      emailController.text = await ApiService.getUserEmail() ?? '';
      phoneController.text = await ApiService.getUserPhone() ?? '';
    }

    final vehicleData = await ApiService.getVehicles();
    final imagePath = await ApiService.getProfileImagePath();

    if (!mounted) return;
    setState(() {
      vehicles = vehicleData;
      _profileImagePath = imagePath;
      _loading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      _showError("Please enter your full name");
      return;
    }
    if (email.isEmpty) {
      _showError("Please enter your email");
      return;
    }

    setState(() => _saving = true);

    final res = await ApiService.updateProfile(
      name: name,
      email: email,
      phone: phone.isEmpty ? null : phone,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (res['error'] != null) {
      _showError(res['error']);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }


  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (picked == null) return;

    await ApiService.saveProfileImagePath(picked.path);

    if (!mounted) return;
    setState(() => _profileImagePath = picked.path);
  }

  Future<void> _addVehicle() async {
    final modelController = TextEditingController();
    final plateController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Add Vehicle", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: modelController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Model (e.g. Toyota Prius)",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: plateController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Plate Number",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result != true) return;
    if (modelController.text.trim().isEmpty || plateController.text.trim().isEmpty) {
      _showError("Model and plate number are required");
      return;
    }

    final res = await ApiService.addVehicle(
      model: modelController.text.trim(),
      plateNumber: plateController.text.trim(),
    );

    if (!mounted) return;

    if (res['error'] != null) {
      _showError(res['error']);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vehicle added")),
    );
    _load();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF1E2D47),
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      child: _profileImagePath == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Personal Information",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 15),

            _buildTextField(
              controller: nameController,
              label: "Full Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 15),

            _buildTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            _buildTextField(
              controller: phoneController,
              label: "Mobile Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Vehicles",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "${vehicles.length}/3",
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.95,
              children: [
                for (int i = 0; i < vehicles.length; i++)
                  _vehicleCard(
                    color: _vehicleColors[i % _vehicleColors.length],
                    icon: Icons.directions_car,
                    title: vehicles[i]["model"] ?? "Vehicle",
                    plate: vehicles[i]["plate_number"] ?? "",
                  ),
                if (vehicles.length < 3) _addVehicleCard(_addVehicle),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static const _vehicleColors = [
    Color(0xFFFFB74D),
    Colors.greenAccent,
    Colors.lightBlueAccent,
  ];

  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static Widget _vehicleCard({
    required Color color,
    required IconData icon,
    required String title,
    required String plate,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.35),
            color.withOpacity(.15),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 38,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              plate,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _addVehicleCard(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withOpacity(.05),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              "Add Vehicle",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Maximum 3",
              style: TextStyle(
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}