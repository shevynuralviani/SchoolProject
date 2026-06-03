import 'package:flutter/material.dart';

class ProfileDropdown extends StatefulWidget {
  const ProfileDropdown({super.key});

  @override
  State<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle, size: 32),

      onSelected: (value) {
        if (value == 'akun') {
          // Aksi saat klik "Akun Saya"
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AkunPage()),
          );
        } else if (value == 'logout') {
          // Aksi saat klik Logout
          // Contoh: kembali ke halaman login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login_Page()),
          );
        }
      },

      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'akun',
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("Akun Saya"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Logout"),
                ],
              ),
            ),
          ],
    );
  }
}

// -------------------------
// Contoh halaman tujuan
// -------------------------
class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Akun Saya")),
      body: const Center(child: Text("Ini halaman Akun Saya")),
    );
  }
}

class Login_Page extends StatelessWidget {
  const Login_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: const Center(child: Text("Halaman Login")),
    );
  }
}
