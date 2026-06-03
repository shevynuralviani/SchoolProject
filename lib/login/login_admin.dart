import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool _isLoading = false;

  /// =========================
  /// LOGIN
  /// =========================
  Future<void> _login() async {
    final username = _usernameController.text.trim();

    final password = _passwordController.text.trim();

    /// VALIDASI INPUT
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan password wajib diisi")),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      /// =========================
      /// CARI USER BERDASARKAN USERNAME
      /// =========================
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      /// USERNAME TIDAK ADA
      if (query.docs.isEmpty) {
        throw 'USERNAME_NOT_FOUND';
      }

      /// AMBIL DATA USER
      final userDoc = query.docs.first;

      final userData = userDoc.data();

      final email = userData['email']?.toString() ?? "";

      final role = userData['role']?.toString() ?? "";

      final isActive = userData['isActive'] ?? false;

      /// VALIDASI EMAIL
      if (email.isEmpty) {
        throw 'EMAIL_NOT_FOUND';
      }

      /// VALIDASI ROLE
      if (role != 'admin') {
        throw 'NOT_ADMIN';
      }

      /// VALIDASI STATUS
      if (isActive != true) {
        throw 'ACCOUNT_DISABLED';
      }

      /// =========================
      /// LOGIN FIREBASE AUTH
      /// =========================
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// CEK LOGIN BERHASIL
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw 'LOGIN_FAILED';
      }

      /// =========================
      /// MASUK DASHBOARD
      /// =========================
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/dashboard_admin');
    }
    /// ERROR FIREBASE AUTH
    on FirebaseAuthException catch (e) {
      String message = "Login gagal";

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          message = "Password salah";
          break;

        case 'user-not-found':
          message = "Akun tidak ditemukan";
          break;

        case 'user-disabled':
          message = "Akun dinonaktifkan";
          break;

        case 'invalid-email':
          message = "Format email tidak valid";
          break;

        case 'too-many-requests':
          message = "Terlalu banyak percobaan login";
          break;

        default:
          message = "Login gagal (${e.code})";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    /// ERROR CUSTOM
    catch (e) {
      String message = "Terjadi kesalahan";

      if (e == 'USERNAME_NOT_FOUND') {
        message = "Username tidak ditemukan";
      } else if (e == 'EMAIL_NOT_FOUND') {
        message = "Email belum terdaftar";
      } else if (e == 'NOT_ADMIN') {
        message = "Akun ini bukan admin";
      } else if (e == 'ACCOUNT_DISABLED') {
        message = "Akun dinonaktifkan";
      } else if (e == 'LOGIN_FAILED') {
        message = "Login gagal";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    /// STOP LOADING
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          /// =========================
          /// SISI KIRI
          /// =========================
          Expanded(
            flex: 1,

            child: Container(
              color: const Color(0xFFF17B0D),

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Container(
                      width: 180,
                      height: 180,

                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,

                        color: Colors.white,

                        image: DecorationImage(
                          image: AssetImage('images/logo_madrasah.jpeg'),

                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Welcome back to",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 22,

                        letterSpacing: 1,
                      ),
                    ),

                    const Text(
                      "SIMI RQ",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 36,

                        fontWeight: FontWeight.bold,

                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// =========================
          /// SISI KANAN
          /// =========================
          Expanded(
            flex: 1,

            child: Center(
              child: Container(
                width: 340,

                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),

                      blurRadius: 10,

                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Text(
                      "Login Admin",

                      style: TextStyle(
                        fontSize: 28,

                        fontWeight: FontWeight.bold,

                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// USERNAME
                    TextField(
                      controller: _usernameController,

                      decoration: InputDecoration(
                        labelText: "Username",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// PASSWORD
                    TextField(
                      controller: _passwordController,

                      obscureText: _obscurePassword,

                      decoration: InputDecoration(
                        labelText: "Password",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),

                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON LOGIN
                    SizedBox(
                      width: double.infinity,

                      height: 48,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        onPressed: _isLoading ? null : _login,

                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Masuk Sebagai Admin",

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 18,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },

                      child: const Text(
                        "Kembali ke login guru",

                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
