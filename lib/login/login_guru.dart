import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();

    final password = _passwordController.text.trim();

    /// =========================
    /// VALIDASI INPUT
    /// =========================
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

      /// USERNAME TIDAK DITEMUKAN
      if (query.docs.isEmpty) {
        throw 'USERNAME_NOT_FOUND';
      }

      /// =========================
      /// AMBIL DATA USER
      /// =========================
      final userData = query.docs.first.data();

      final email = userData['email']?.toString() ?? "";

      final role = userData['role']?.toString() ?? "";

      final isActive = userData['isActive'] ?? false;

      final namaKelas = userData['nama_kelas']?.toString() ?? "";

      /// =========================
      /// VALIDASI EMAIL
      /// =========================
      if (email.isEmpty) {
        throw 'EMAIL_NOT_FOUND';
      }

      /// =========================
      /// VALIDASI STATUS AKUN
      /// =========================
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

      /// =========================
      /// CEK LOGIN BERHASIL
      /// =========================
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw 'LOGIN_FAILED';
      }

      if (!mounted) return;

      /// =========================
      /// PINDAH HALAMAN BERDASARKAN ROLE
      /// =========================
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/dashboard_admin');
      } else if (role == 'guru') {
        if (namaKelas.isEmpty) {
          throw 'KELAS_NOT_ASSIGNED';
        }

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {'nama_kelas': namaKelas},
        );
      }
    }
    /// =========================
    /// ERROR FIREBASE AUTH
    /// =========================
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

        case 'invalid-email':
          message = "Format email tidak valid";
          break;

        case 'user-disabled':
          message = "Akun dinonaktifkan";
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
    /// =========================
    /// ERROR CUSTOM
    /// =========================
    catch (e) {
      print("LOGIN ERROR: $e");

      String message = "Terjadi kesalahan";

      if (e == 'USERNAME_NOT_FOUND') {
        message = "Username tidak ditemukan";
      } else if (e == 'EMAIL_NOT_FOUND') {
        message = "Email belum terdaftar";
      } else if (e == 'ACCOUNT_DISABLED') {
        message = "Akun dinonaktifkan";
      } else if (e == 'INVALID_ROLE') {
        message = "Role akun tidak valid";
      } else if (e == 'LOGIN_FAILED') {
        message = "Login gagal";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    /// =========================
    /// STOP LOADING
    /// =========================
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 700;

    Widget leftSection = Container(
      color: Colors.green.shade400,
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isMobile ? 120 : 180,
              height: isMobile ? 120 : 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('images/logo_madrasah.jpeg'),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: isMobile ? 15 : 20),

            Text(
              "Welcome back to",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 18 : 22,
              ),
            ),

            Text(
              "SIMI RQ",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );

    Widget rightSection = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
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
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 30),

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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Masuk",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                ),
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/adminlogin');
                },
                child: const Text(
                  "Masuk sebagai admin? Klik disini",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child:
                isMobile
                    ? Column(
                      children: [
                        Expanded(flex: 4, child: leftSection),
                        Expanded(flex: 6, child: rightSection),
                      ],
                    )
                    : Row(
                      children: [
                        Expanded(child: leftSection),
                        Expanded(child: rightSection),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
