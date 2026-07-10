# AutoNex Backend (Node.js + Express + MySQL)

This is the shared backend for:
- **AutoNex customer app** (Flutter, `customer_app`)
- **AutoNex workshop admin panel** (the `.html` files: dashboard, customers, vehicles, appointments, billing)

Both talk to the same MySQL database through this one REST API. Since you're running
everything on a laptop over wifi (no cloud server yet), the API will be reachable at
your laptop's **local network IP**, e.g. `http://192.168.1.42:3000`.

---

## 1. One-time setup

```bash
cd workshop-backend
npm install
cp .env.example .env
```

Edit `.env` and set your real MySQL password/user:

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=autonex
JWT_SECRET=some_long_random_string
```

Create the database and tables:

```bash
mysql -u root -p < schema.sql
```

Create your admin login (used by dashboard.html / login.html):

```bash
node seedAdmin.js "admin@autonex.lk" "admin123" "Workshop Admin"
```

Start the server:

```bash
npm start
```

You should see:
```
AutoNex backend running on http://0.0.0.0:3000
```

Test it in a browser: `http://localhost:3000/api/health` → `{"status":"ok", ...}`

---

## 2. Find your laptop's LAN IP (so the phone can reach it over wifi)

- **Windows:** `ipconfig` → look for "IPv4 Address" (something like `192.168.1.42`)
- **Mac/Linux:** `ifconfig | grep inet` or `ip addr`

Make sure the phone running the Flutter app and the laptop are on the **same wifi
network**, and that your firewall allows inbound connections on port 3000.

Your API base URL is then: `http://<that-ip>:3000/api`

---

## 3. API summary

All endpoints are prefixed with `/api`. Except `/auth/*`, every route requires:
```
Authorization: Bearer <token>
```
(token is returned from `/auth/login` or `/auth/register`)

| Area          | Method & Path                          | Who          | Used by |
|---------------|-----------------------------------------|--------------|---------|
| Auth          | POST `/auth/register`                   | public       | Flutter register_page.dart |
| Auth          | POST `/auth/login`                      | public       | Flutter login_page.dart, admin login.html |
| Customers     | GET/POST/PUT/DELETE `/customers`        | admin        | customers.html |
| Vehicles      | GET/POST `/vehicles`                    | admin+customer | vehicles.html, profile_page.dart |
| Vehicles      | PUT `/vehicles/:id/service`             | admin        | vehicles.html service modal |
| Appointments  | GET/POST `/appointments`                | admin+customer | appointments.html, booking_page.dart, history_page.dart |
| Appointments  | PUT `/appointments/:id/status`          | admin        | appointments.html approve/reject |
| Appointments  | PUT `/appointments/:id/progress`        | admin        | appointments.html progress dropdown |
| Feedback      | GET/POST `/feedback`                    | admin+customer | feedback_page.dart |
| Notifications | GET `/notifications`                    | customer     | notification_page.dart |
| Notifications | PUT `/notifications/:id/read`           | customer     | notification_page.dart |
| Chat          | GET/POST `/chat/:userId`                | admin+customer | chat_workshop_page.dart |
| Invoices      | GET/POST `/invoices`                    | admin+customer | billing.html |
| Workshop      | GET/PUT `/workshop/profile`             | admin        | dashboard.html profile modal |
| Workshop      | GET `/workshop/stats`                   | admin        | dashboard.html stat cards |

---

## 4. Connecting the Flutter customer app

Add the http package in `customer_app/pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.2.0   # to persist the login token on the phone
```

Create `lib/services/api_service.dart`:
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 👉 Replace with your laptop's LAN IP while developing locally
  static const String baseUrl = "http://192.168.1.42:3000/api";

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _token();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('name', data['user']['name']);
    }
    return data;
  }

  static Future<List<dynamic>> getAppointments() async {
    final res = await http.get(Uri.parse("$baseUrl/appointments"), headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createBooking({
    required int vehicleId,
    required String serviceType,
    required String date,
    String? time,
    String? notes,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/appointments"),
      headers: await _headers(),
      body: jsonEncode({
        "vehicle_id": vehicleId,
        "service_type": serviceType,
        "appointment_date": date,
        "appointment_time": time,
        "notes": notes,
      }),
    );
    return jsonDecode(res.body);
  }

  // Add similar methods for vehicles, notifications, feedback, chat, etc.
  // following the same pattern (GET/POST + await _headers()).
}
```

**In `login_page.dart`**, replace the local "if fields not empty" check inside the
Login button's `onPressed` with:

```dart
onPressed: () async {
  final result = await ApiService.login(
    usernameController.text, // use an email field, not username, to match the API
    passwordController.text,
  );

  if (result['token'] != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(username: result['user']['name']),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['error'] ?? 'Login failed')),
    );
  }
},
```

Do the same pattern for `booking_page.dart` (call `ApiService.createBooking(...)` in
the Submit button), `history_page.dart` and `notification_page.dart` (replace the
hardcoded lists with `FutureBuilder` calling `ApiService.getAppointments()` /
a new `getNotifications()` method), and `feedback_page.dart` (POST to `/feedback`).

---

## 5. Connecting the HTML admin panel (replacing localStorage)

Right now `customers.html`, `vehicles.html`, `appointments.html`, `dashboard.html`
and `billing.html` all read/write `localStorage`. Swap those calls for `fetch()`
calls to this API. Add this near the top of each HTML file's `<script>`:

```js
const API_BASE = "http://localhost:3000/api"; // same machine as the server
// If opening these HTML files from a different device, use the LAN IP instead.

function authHeaders() {
  const token = localStorage.getItem('authToken');
  return { "Content-Type": "application/json", "Authorization": "Bearer " + token };
}
```

Example — replacing `loadCustomers()` in `customers.html`:

```js
async function loadCustomers() {
  const res = await fetch(`${API_BASE}/customers`, { headers: authHeaders() });
  const customers = await res.json();
  renderTable(customers);
}
```

And `saveCustomer()`:

```js
async function saveCustomer() {
  const name = document.getElementById('custName').value;
  const mobile = document.getElementById('custMobile').value;
  const email = document.getElementById('custEmail').value;
  const vehicle = document.getElementById('custVehicle').value;

  if (!name || !mobile || !vehicle) {
    alert("Please fill in the required fields!");
    return;
  }

  await fetch(`${API_BASE}/customers`, {
    method: "POST",
    headers: authHeaders(),
    body: JSON.stringify({ name, mobile, email, vehicle }),
  });

  loadCustomers();
  closeModal();
}
```

Apply the same `fetch()` swap to `vehicles.html` (`/vehicles`, `/vehicles/:id/service`),
`appointments.html` (`/appointments`, `/appointments/:id/status`, `/appointments/:id/progress`),
`dashboard.html` (`/workshop/stats`, `/workshop/profile`), and `billing.html` (`/invoices`).

**`login.html`** should POST to `/auth/login` and store the returned token:
```js
async function doLogin() {
  const res = await fetch(`${API_BASE}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: emailInput.value, password: passwordInput.value }),
  });
  const data = await res.json();
  if (res.ok) {
    localStorage.setItem('authToken', data.token);
    window.location.href = 'dashboard.html';
  } else {
    alert(data.error);
  }
}
```

---

## 6. Notes

- All list-fetching endpoints check `req.user.role` — admin sees everything,
  customers only see their own records. This means the same `/appointments`
  endpoint powers both `appointments.html` (all bookings) and
  `history_page.dart` (just that customer's bookings).
- Passwords are hashed with bcrypt; never stored in plain text.
- `cors()` is currently wide open (`app.use(cors())`) since this is a closed
  local-wifi setup — restrict `origin` before deploying publicly.
- When you do move to a real server later, the only things that change are:
  the `baseUrl`/`API_BASE` values (swap the LAN IP for your domain), and
  the `.env` DB credentials.
