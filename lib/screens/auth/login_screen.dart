import 'package:flutter/material.dart';
import '../../data/auth_service.dart';
import '../dashboard.dart'; // Ensure this import exists

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Toggle between Login (true) and Signup (false)
  bool isLogin = true;
  bool isLoading = false;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Color Palette (Hardcoded for simplicity, usually in theme.dart)
  final Color plantGreen = const Color(0xFF2D6A4F);
  final Color lightGreen = const Color(0xFFD8F3DC);

  void _handleSubmit() async {
    setState(() => isLoading = true);

    String? error;
    if (isLogin) {
      error = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      error = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    setState(() => isLoading = false);

    if (error == null) {
      if (mounted) {
        // Navigate to Dashboard on success
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const Dashboard()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleGoogleLogin() async {
    setState(() => isLoading = true);
    String? error = await _authService.signInWithGoogle();
    setState(() => isLoading = false);

    if (error == null && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Dashboard()));
    } else {
      // THIS WAS MISSING
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In Error: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive design
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // 1. Background Organic Shape (Minimalist Decoration)
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 2. Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Catchy Header Animation
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Icon(Icons.eco, size: 80, color: plantGreen),
                          const SizedBox(height: 16),
                          Text(
                            "PlantIT",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: plantGreen,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "Grow with confidence",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // 3. Form Fields with AnimatedSwitcher for smooth toggle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: Column(
                        key: ValueKey<bool>(isLogin), // Crucial for animation
                        children: [
                          _buildTextField(
                            _emailController,
                            "Email Address",
                            Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            _passwordController,
                            "Password",
                            Icons.lock_outline,
                            isObscure: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. Action Button
                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(color: plantGreen),
                          )
                        : FilledButton(
                            onPressed: _handleSubmit,
                            style: FilledButton.styleFrom(
                              backgroundColor: plantGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isLogin ? "Login" : "Create Account",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                    const SizedBox(height: 16),

                    // 5. Toggle Login/Signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin
                              ? "New to PlantIT? "
                              : "Already have an account? ",
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => isLogin = !isLogin);
                          },
                          child: Text(
                            isLogin ? "Sign Up" : "Login",
                            style: TextStyle(
                              color: plantGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 20),

                    // 6. Google Sign In
                    OutlinedButton.icon(
                      onPressed: _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.g_mobiledata,
                        size: 30,
                        color: Colors.black87,
                      ),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for cleaner code
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
    );
  }
}
