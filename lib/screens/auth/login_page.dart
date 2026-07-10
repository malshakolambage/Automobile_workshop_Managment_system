import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:customer_app/screens/main_screen.dart';
import 'package:customer_app/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071120),
              Color(0xFF0B1E36),
              Color(0xFF102944),
            ],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),

                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15,
                    sigmaY: 15,
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),

                      color: Colors.white.withOpacity(0.08),

                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),

                          child: const Icon(
                            Icons.car_repair,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Login to continue",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: usernameController,
                          keyboardType: TextInputType.emailAddress,

                          style: const TextStyle(
                            color: Colors.white,
                          ),

                          decoration: InputDecoration(
                            hintText: "Email",

                            hintStyle: const TextStyle(
                              color: Colors.white54,
                            ),

                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.white70,
                            ),

                            filled: true,
                            fillColor:
                                Colors.white.withOpacity(0.05),

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(18),

                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: passwordController,
                          obscureText: true,

                          style: const TextStyle(
                            color: Colors.white,
                          ),

                          decoration: InputDecoration(
                            hintText: "Password",

                            hintStyle: const TextStyle(
                              color: Colors.white54,
                            ),

                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white70,
                            ),

                            filled: true,
                            fillColor:
                                Colors.white.withOpacity(0.05),

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(18),

                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,

                              backgroundColor:
                                  Colors.white.withOpacity(0.12),

                              foregroundColor: Colors.white,

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),

                              side: BorderSide(
                                color:
                                    Colors.white.withOpacity(0.15),
                              ),
                            ),

                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (usernameController
                                            .text.isEmpty ||
                                        passwordController
                                            .text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Colors.red.shade400,
                                          content: const Text(
                                            "Enter email and password",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _isLoading = true);

                                    final result =
                                        await ApiService.login(
                                      usernameController.text.trim(),
                                      passwordController.text,
                                    );

                                    if (!mounted) return;
                                    setState(() => _isLoading = false);

                                    if (result['token'] != null) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MainScreen(
                                            username:
                                                result['user']['name'] ??
                                                    usernameController
                                                        .text,
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Colors.red.shade400,
                                          content: Text(
                                            result['error'] ??
                                                'Login failed',
                                          ),
                                        ),
                                      );
                                    }
                                  },

                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/register",
                              );
                            },

                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color:
                                    Colors.white.withOpacity(0.15),
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                            ),

                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
