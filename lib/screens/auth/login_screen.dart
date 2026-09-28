import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool hidePassword = true;
  bool rememberMe = false;
  bool isLoading = false;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final String email = emailController.text.trim();

    final String password = passwordController.text;

    // ------------------------------------------------------------
    // EMAIL VALIDATION
    // ------------------------------------------------------------

    if (email.isEmpty) {
      _showMessage('Please enter your email.');
      return;
    }

    // ------------------------------------------------------------
    // PASSWORD VALIDATION
    // ------------------------------------------------------------

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    // ------------------------------------------------------------
    // START LOADING
    // ------------------------------------------------------------

    setState(() {
      isLoading = true;
    });

    // ------------------------------------------------------------
    // GET AUTH PROVIDER
    // ------------------------------------------------------------

    final AuthProvider authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // ------------------------------------------------------------
    // CHECK LOGIN
    // ------------------------------------------------------------

    final bool success = await authProvider.login(email: email, password: password);

    // Small delay for loading animation
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    // ------------------------------------------------------------
    // LOGIN SUCCESS
    // ------------------------------------------------------------

    if (success) {
      _showMessage('Login successful!');

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );

      return;
    }

    // ------------------------------------------------------------
    // LOGIN FAILED
    // ------------------------------------------------------------

    _showMessage('Invalid email or password.');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 45),

              // ==================================================
              // LOGO
              // ==================================================
              Container(
                height: 120,
                width: 120,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 65,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // APP NAME
              // ==================================================
              Text(
                AppConstants.appName,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Welcome Back!',
                style: TextStyle(color: AppColors.grey, fontSize: 18),
              ),

              const SizedBox(height: 40),

              // ==================================================
              // EMAIL
              // ==================================================
              TextField(
                controller: emailController,

                keyboardType: TextInputType.emailAddress,

                textInputAction: TextInputAction.next,

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  labelText: 'Email Address',

                  hintText: 'Enter your email',

                  labelStyle: const TextStyle(color: Colors.white70),

                  hintStyle: const TextStyle(color: Colors.white38),

                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.white70,
                  ),

                  filled: true,

                  fillColor: AppColors.surface,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PASSWORD
              // ==================================================
              TextField(
                controller: passwordController,

                obscureText: hidePassword,

                textInputAction: TextInputAction.done,

                onSubmitted: (_) {
                  if (!isLoading) {
                    _login();
                  }
                },

                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  labelText: 'Password',

                  hintText: 'Enter your password',

                  labelStyle: const TextStyle(color: Colors.white70),

                  hintStyle: const TextStyle(color: Colors.white38),

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white70,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },

                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70,
                    ),
                  ),

                  filled: true,

                  fillColor: AppColors.surface,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // REMEMBER ME
              // ==================================================
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,

                    activeColor: AppColors.primary,

                    onChanged: (value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                  ),

                  const Text(
                    'Remember Me',

                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // LOGIN BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,

                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),

                    foregroundColor: Colors.white,

                    elevation: 8,

                    shadowColor: AppColors.primary,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,

                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.login, size: 22),

                            SizedBox(width: 10),

                            Text(
                              'Login',

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 30),

              const SizedBox(height: 25),

              // ==================================================
              // DON'T HAVE AN ACCOUNT?
              // ==================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // VERSION
              // ==================================================
              const Divider(color: Colors.white12),

              const SizedBox(height: 15),

              const Text(
                'MultiVoice Assist',

                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Version 1.0.0',

                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),

              const SizedBox(height: 5),

              const Text(
                '© 2026 MultiVoice Assist',

                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
