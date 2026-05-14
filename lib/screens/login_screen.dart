import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'product_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final nimController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    fadeAnimation = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    nimController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (nimController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackbar('NIM dan password wajib diisi', true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await authService.login(
        nimController.text,
        passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProductScreen()),
        );
      } else if (mounted) {
        showSnackbar('NIM atau password salah', true);
      }
    } catch (_) {
      if (mounted) showSnackbar('Server tidak merespon', true);
    }

    if (mounted) setState(() => isLoading = false);
  }

  void showSnackbar(String message, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFE53935) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static const backgroundColor = Color(0xFF09090F);
  static const cardColor = Color(0xFF141420);
  static const inputColor = Color(0xFF1B1B2B);
  static const primaryColor = Color(0xFF5B5CFF);
  static const secondaryText = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          buildGlow(top: -100, right: -80, color: Colors.blue, size: 250),
          buildGlow(bottom: -100, left: -60, color: Colors.purple, size: 220),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 10),
                              const Text('Login untuk melanjutkan aplikasi', style: TextStyle(color: secondaryText, fontSize: 14)),
                              const SizedBox(height: 36),
                              buildInput(controller: nimController, hint: 'Masukkan NIM', icon: Icons.person_outline, keyboard: TextInputType.number),
                              const SizedBox(height: 20),
                              buildInput(
                                controller: passwordController,
                                hint: 'Masukkan Password',
                                icon: Icons.lock_outline,
                                obscure: obscurePassword,
                                suffix: IconButton(
                                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                  icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: primaryColor),
                                ),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          ),
        ],
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      cursorColor: primaryColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: suffix,
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }

  Widget buildGlow({double? top, double? bottom, double? left, double? right, required Color color, required double size}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withOpacity(0.35), color.withOpacity(0)]),
        ),
      ),
    );
  }
}
