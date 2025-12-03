import 'package:flutter/material.dart';
import '../app_strings.dart';
import '../auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepository();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authRepo.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/images/arrow.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: AppStrings.emailHint,
                    hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
                    filled: true,
                    fillColor: const Color(0xFFF7EAF0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return AppStrings.errorEmptyField;
                    }

                    if (!email.contains('@')) {
                      return AppStrings.errorInvalidEmail;
                    }

                    final parts = email.split('@');
                    if (parts.length != 2) {
                      return AppStrings.errorInvalidEmail;
                    }

                    final local = parts[0]; // до @
                    final domain = parts[1]; // після @

                    if (local.isEmpty) {
                      return AppStrings.errorInvalidEmail;
                    }

                    if (domain.isEmpty) {
                      return AppStrings.errorInvalidEmail;
                    }

                    if (!domain.contains('.')) {
                      return AppStrings.errorInvalidEmail;
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: AppStrings.passwordHint,
                    hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
                    filled: true,
                    fillColor: const Color(0xFFF7EAF0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                        return AppStrings.errorEmptyField;
                    }

                    if (value.length < 8) {
                      return AppStrings.errorInvalidPasswordLen;
                    }

                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return AppStrings.errorInvalidPasswordUp;
                    }

                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return AppStrings.errorInvalidPasswordLow;
                    }

                    return null;
                  }
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Color(0xFF9A4D73),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF72585),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            AppStrings.loginButton,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
                const Spacer(),

                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(
                          color: Color(0xFF9A4D73),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
