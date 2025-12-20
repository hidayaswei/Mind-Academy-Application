import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/AppScaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/app_text_field.dart';
import '../controllers/state.dart';
import 'signup_page.dart';
import 'admin_home_page.dart';
import 'student_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext rootContext) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final user = await _authController.login(email, password);

    if (user == null) {
      ScaffoldMessenger.of(rootContext).showSnackBar(
        const SnackBar(content: Text('Incorrect email or password')),
      );
      return;
    }

    isLoggedIn.value = true;

    if (user.role == 'admin') {
      Navigator.pushReplacement(
        rootContext,
        MaterialPageRoute(builder: (_) => AdminHomePage(admin: user)),
      );
    } else {
      Navigator.pushReplacement(
        rootContext,
        MaterialPageRoute(builder: (_) => StudentHomePage(student: user)),
      );
    }
  }

  Future<void> _showResetPasswordDialog(BuildContext rootContext) async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final bool? shouldReset = await showDialog<bool>(
      context: rootContext,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_reset_rounded,
                    size: 40,
                    color: Color(0xFF667eea),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your email and new password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter new password';
                      }
                      if (value.length < 6) {
                        return 'At least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(rootContext, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(rootContext, true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (shouldReset == true) {
      final email = emailController.text.trim();
      final newPassword = newPasswordController.text;

      try {
        final ok = await _authController.resetPassword(email, newPassword);

        if (!ok) {
          ScaffoldMessenger.of(rootContext).showSnackBar(
            const SnackBar(
              content: Text('No account found with this email'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        ScaffoldMessenger.of(rootContext).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully. You can login now.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(
            content: Text('Error while resetting password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Builder(
        builder: (rootContext) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(rootContext),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Sign in to continue your journey',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 30),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showResetPasswordDialog(rootContext),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Color(0xFF667eea),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            text: 'SIGN IN',
                            onPressed: () => _handleLogin(rootContext),
                          ),
                          const SizedBox(height: 20),
                          _buildSignupLink(rootContext),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignupLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFF667eea),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
