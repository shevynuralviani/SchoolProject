import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AkunAdminPage extends StatefulWidget {
  const AkunAdminPage({super.key});

  @override
  State<AkunAdminPage> createState() => _AkunAdminPageState();
}

class _AkunAdminPageState extends State<AkunAdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String docId = "";

  String nama = "";
  String email = "";
  String username = "";
  String role = "";

  bool isLoading = true;

  final namaController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ambilDataUser();
  }

  // ==============================
  // Ambil data user dari Firestore
  // ==============================
  Future<void> ambilDataUser() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          docId = doc.id;

          nama = data['nama'] ?? '';
          email = data['email'] ?? '';
          username = data['username'] ?? '';
          role = data['role'] ?? '';

          namaController.text = nama;
          usernameController.text = username;

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==============================
  // Update data user
  // ==============================
  Future<void> updateUser() async {
    try {
      await _firestore.collection('users').doc(docId).update({
        "nama": namaController.text,
        "username": usernameController.text,
      });

      Navigator.pop(context);

      ambilDataUser();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error update: $e");
    }
  }

  // ==============================
  // Popup form edit
  // ==============================
  void bukaEditProfil() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profil"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),

            ElevatedButton(onPressed: updateUser, child: const Text("Simpan")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(email, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  _infoRow("Username", username),
                  _infoRow("Role", role),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: bukaEditProfil,
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profil"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),

          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
