import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tourism_kg_alisa/services/auth_service.dart';

import '../app_navigation.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    final String nickname = _nicknameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (nickname.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _showToast("Пожалуйста, заполните все поля (имя, телефон, email, пароль)");
      return;
    }

    if (password.length < 6) {
      _showToast("Пароль должен содержать не менее 6 символов");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('user_persons').doc(uid).set({
        'uid': uid,
        'nickname': nickname,
        'user_contact_number': phone,
        'email': email,
      });

      _showToast("Регистрация успешно завершена!");

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppNavigation.home,
          (route) => false,
        );
      }
    } catch (e) {
      _showToast("Ошибка регистрации: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppNavigation.home,
          (route) => false,
        );
      }
    } catch (e) {
      _showToast("Ошибка входа через Google: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFD),
      appBar: AppBar(
        title: const Text("Регистрация"),
        backgroundColor: const Color(0xFFDEEFFD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Создать аккаунт",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                hintText: "Ваше имя / Никнейм",
                prefixIcon: Icon(Icons.person, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "Номер телефона (+996...)",
                prefixIcon: Icon(Icons.phone, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Пароль (минимум 6 символов)",
                prefixIcon: Icon(Icons.lock, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading) ...[
              ElevatedButton.icon(
                onPressed: _registerUser,
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "Зарегистрироваться",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loginWithGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                label: const Text(
                  "Войти через Google",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
