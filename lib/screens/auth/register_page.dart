import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:customer_app/screens/main_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        // 🔥 PREMIUM NAVY GRADIENT
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

                        // 🔥 ICON
                        Container(
                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),

                          child: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // TITLE
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Join AutoNex Workshop System",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 30),

                        //  USERNAME
                        _buildField(
                          controller: usernameController,
                          hint: "Username",
                          icon: Icons.person,
                        ),

                        const SizedBox(height: 16),

                        //  EMAIL
                        _buildField(
                          controller: emailController,
                          hint: "Email",
                          icon: Icons.email,
                        ),

                        const SizedBox(height: 16),

                        //  PASSWORD
                        _buildField(
                          controller: passwordController,
                          hint: "Password",
                          icon: Icons.lock,
                          obscure: true,
                        ),

                        const SizedBox(height: 16),

                        // 🔥 CONFIRM PASSWORD
                        _buildField(
                          controller: confirmPasswordController,
                          hint: "Confirm Password",
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),

                        const SizedBox(height: 30),

                        //  REGISTER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            onPressed: () {
                              if (usernameController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty &&
                                  confirmPasswordController.text.isNotEmpty) {

                                if (passwordController.text ==
                                    confirmPasswordController.text) {

                                  // FIX: previously this called
                                  // Navigator.pushReplacementNamed(context, "/home"),
                                  // which always showed username "Guest" because
                                  // that named route is hardcoded in main.dart.
                                  // Pushing MainScreen directly lets us pass the
                                  // real username the user just typed in.
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainScreen(
                                        username: usernameController.text,
                                      ),
                                    ),
                                  );

                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Passwords do not match"),
                                    ),
                                  );
                                }

                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Please fill all fields"),
                                  ),
                                );
                              }
                            },

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

                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        //BACK TO LOGIN
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.white70,
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

  //  FIELD WIDGET
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),

        prefixIcon: Icon(icon, color: Colors.white70),

        filled: true,
        fillColor: Colors.white.withOpacity(0.05),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}