import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final repo = AuthRepository();

  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      final res = await repo.login(
        email: email.text,
        password: password.text,
      );

      debugPrint(res.toString());
    } catch (e) {
      debugPrint('error: $e');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Prorab+')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : login,
              child: Text(loading ? 'Loading...' : 'Login'),
            )
          ],
        ),
      ),
    );
  }
}