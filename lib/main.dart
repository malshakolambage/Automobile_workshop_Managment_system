import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/main_screen.dart';

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
        "/": (context) => const WelcomePage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        // NOTE: MainScreen requires a username, so this route only works
        // if you navigate with arguments (see login/register pages, which
        // now push MainScreen directly instead of using this route).
        "/home": (context) => const MainScreen(username: "Guest"),
      },
    );
  }
}