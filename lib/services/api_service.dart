import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
 
  static const String baseUrl = "http://192.168.1.236:3000/api";

  // ---------------- token / session helpers ----------------

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('name', data['user']['name'] ?? '');
    await prefs.setString('email', data['user']['email'] ?? '');
    await prefs.setString('phone', data['user']['phone'] ?? '');
    await prefs.setInt('userId', data['user']['id'] ?? 0);
  }

  /// Updates just the cached profile fields in local storage (used after
  /// a successful profile edit, so the rest of the app — e.g. the Home
  /// welcome banner — shows the latest name without needing to log out).
  static Future<void> _cacheProfile(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user['name'] != null) await prefs.setString('name', user['name']);
    if (user['email'] != null) await prefs.setString('email', user['email']);
    if (user['phone'] != null) await prefs.setString('phone', user['phone'] ?? '');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ---------------- generic helpers ----------------


  static Future<dynamic> _get(String path) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl$path"),
        headers: await _headers(),
      );
      return _decode(res);
    } catch (e) {
      return {"error": "Could not reach server. Check your connection / API address."};
    }
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl$path"),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _decode(res);
    } catch (e) {
      return {"error": "Could not reach server. Check your connection / API address."};
    }
  }

  static Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl$path"),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return _decode(res);
    } catch (e) {
      return {"error": "Could not reach server. Check your connection / API address."};
    }
  }

  static dynamic _decode(http.Response res) {
    if (res.body.isEmpty) return {};
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return {"error": "Unexpected server response"};
    }
  }

  // ---------------- auth ----------------

  /// POST /api/auth/login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final data = await _post("/auth/login", {"email": email, "password": password});
    if (data is Map<String, dynamic> && data['token'] != null) {
      await _saveSession(data);
    }
    return data is Map<String, dynamic> ? data : {"error": "Login failed"};
  }

  /// POST /api/auth/register
  static Future<Map<String, dynamic>> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  }) async {
    final data = await _post("/auth/register", {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
    });
    if (data is Map<String, dynamic> && data['token'] != null) {
      await _saveSession(data);
    }
    return data is Map<String, dynamic> ? data : {"error": "Registration failed"};
  }

  // ---------------- profile (logged-in user's own account) ----------------

  /// GET /api/me -> the logged-in user's own profile from the server
  static Future<Map<String, dynamic>> getMe() async {
    final data = await _get("/me");
    if (data is Map<String, dynamic> && data['error'] == null) {
      await _cacheProfile(data);
    }
    return data is Map<String, dynamic> ? data : {"error": "Failed to fetch profile"};
  }

  /// PUT /api/me -> update name / email / phone for the logged-in user
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    final data = await _put("/me", {
      "name": name,
      "email": email,
      "phone": phone,
    });
    if (data is Map<String, dynamic> && data['error'] == null && data['user'] != null) {
      await _cacheProfile(data['user']);
    }
    return data is Map<String, dynamic> ? data : {"error": "Failed to update profile"};
  }

  // ---------------- profile photo (stored on-device only, not on the server) ----------------

  /// Saves the local file path of the picked profile photo. This is never
  /// sent to the backend — the server's `users.profile_image` column is not
  /// touched, the photo just lives on this device.
  static Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }

  static Future<void> clearProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
  }

  // ---------------- vehicles ----------------

  /// GET /api/vehicles -> the logged-in customer's own vehicles
  static Future<List<dynamic>> getVehicles() async {
    final data = await _get("/vehicles");
    return data is List ? data : [];
  }

  /// POST /api/vehicles
  static Future<Map<String, dynamic>> addVehicle({
    required String model,
    required String plateNumber,
  }) async {
    final data = await _post("/vehicles", {
      "model": model,
      "plate_number": plateNumber,
    });
    return data is Map<String, dynamic> ? data : {"error": "Failed to add vehicle"};
  }

  // ---------------- appointments / bookings ----------------

  /// GET /api/appointments -> the logged-in customer's bookings
  static Future<List<dynamic>> getAppointments() async {
    final data = await _get("/appointments");
    return data is List ? data : [];
  }

  /// POST /api/appointments
  static Future<Map<String, dynamic>> createAppointment({
    required int vehicleId,
    required String serviceType,
    required String appointmentDate, // e.g. "2026-07-15"
    String? appointmentTime,
    String? notes,
  }) async {
    final data = await _post("/appointments", {
      "vehicle_id": vehicleId,
      "service_type": serviceType,
      "appointment_date": appointmentDate,
      "appointment_time": appointmentTime,
      "notes": notes,
    });
    return data is Map<String, dynamic> ? data : {"error": "Failed to create booking"};
  }

  // ---------------- feedback ----------------

  /// GET /api/feedback -> the logged-in customer's own feedback history
  static Future<List<dynamic>> getFeedbackList() async {
    final data = await _get("/feedback");
    return data is List ? data : [];
  }

  /// POST /api/feedback
  static Future<Map<String, dynamic>> submitFeedback({
    int? vehicleId,
    int? appointmentId,
    required int rating,
    String? comment,
  }) async {
    final data = await _post("/feedback", {
      "vehicle_id": vehicleId,
      "appointment_id": appointmentId,
      "rating": rating,
      "comment": comment,
    });
    return data is Map<String, dynamic> ? data : {"error": "Failed to submit feedback"};
  }

  // ---------------- notifications ----------------

  /// GET /api/notifications
  static Future<List<dynamic>> getNotifications() async {
    final data = await _get("/notifications");
    return data is List ? data : [];
  }

  /// PUT /api/notifications/:id/read
  static Future<bool> markNotificationRead(int id) async {
    final data = await _put("/notifications/$id/read", {});
    return data is Map<String, dynamic> && data['error'] == null;
  }

  // ---------------- chat ----------------

  /// GET /api/chat/:userId -> full conversation for the logged-in customer
  static Future<List<dynamic>> getChatMessages(int userId) async {
    final data = await _get("/chat/$userId");
    return data is List ? data : [];
  }

  /// POST /api/chat/:userId
  static Future<Map<String, dynamic>> sendChatMessage(
    int userId,
    String message,
  ) async {
    final data = await _post("/chat/$userId", {"message": message});
    return data is Map<String, dynamic> ? data : {"error": "Failed to send message"};
  }
}