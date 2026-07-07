import 'package:flutter/material.dart';
import 'package:customer_app/widgets/dashboard_card.dart';
import 'screens/welcome_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/home_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,

  theme: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF071120),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3DDCFF),
      brightness: Brightness.dark,
    ),
  ),

  initialRoute: "/",

  routes: {
    "/": (context) => WelcomePage(),
    "/login": (context) => LoginPage(),
    "/register": (context) => RegisterPage(),
    "/home": (context) => const HomePage(username: "Guest"),
  },
);
  }
}
