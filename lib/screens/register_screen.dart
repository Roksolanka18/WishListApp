import 'package:flutter/material.dart';
import '../app_strings.dart';
import '../auth_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepository();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authRepo.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
          Navigator.pushReplacementNamed(context, '/home');
        
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
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  "Email",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
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

                const Text(
                  "Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
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
                const SizedBox(height: 20),

                const Text(
                  "Confirm Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirm your password",
                    hintStyle: const TextStyle(color: Color(0xFF9A4D73)),
                    filled: true,
                    fillColor: const Color(0xFFF7EAF0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return AppStrings.errorPasswordsNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF72585),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      "Already have an account? Sign In",
                      style: TextStyle(
                        color: Color(0xFF9A4D73),
                        fontSize: 15,
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
