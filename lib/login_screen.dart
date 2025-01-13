import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Email dan kata sandi harus diisi!');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        String userName = snapshot.child('username').value.toString();
        _showSnackbar('Login berhasil! Selamat datang, $userName');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showSnackbar('Data pengguna tidak ditemukan.');
      }
    } catch (e) {
      _showSnackbar('Email atau Sandi Salah');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0070F0),
              Color(0xFF00408A),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Image.asset(
                  'assets/tes.png',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0070F0),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(
                          color: Color(0xFF686868),
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1F1F1F),
                          ),
                          prefixIcon: const Icon(Icons.email, color: Color(0xFF0070F0)),
                          filled: true,
                          fillColor: const Color(0xFFE8F2FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(
                          color: Color(0xFF686868),
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          labelStyle: const TextStyle(
                            color: Color(0xFF1F1F1F),
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF0070F0)),
                          filled: true,
                          fillColor: const Color(0xFFE8F2FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF0070F0),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 215,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0070F0),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Belum punya akun? Daftar sekarang',
                          style: TextStyle(
                            color: Color(0xFF0070F0),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
