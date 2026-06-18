import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_user.dart';
import 'edit_user.dart';

class ManajemenUserAdmin extends StatefulWidget {
  const ManajemenUserAdmin({super.key});

  @override
  State<ManajemenUserAdmin> createState() => _ManajemenUserAdminState();
}

class _ManajemenUserAdminState extends State<ManajemenUserAdmin> {
  String _searchText = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// =========================
  /// TAMBAH USER
  /// =========================
  Future<void> _tambahUser() async {
    /// AMBIL DATA KELAS
    final kelasSnapshot =
        await _firestore.collection('daftar_kelas').orderBy('nama_kelas').get();

    final daftarKelas =
        kelasSnapshot.docs.map((e) => e['nama_kelas'].toString()).toList();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TambahUserAdmin(daftarKelas: daftarKelas),
    );

    if (result == null) return;

    try {
      /// =========================
      /// VALIDASI
      /// =========================

      final nama = result["nama"]?.toString().trim() ?? "";

      final username = result["username"]?.toString().trim() ?? "";

      final email = result["email"]?.toString().trim() ?? "";

      final password = result["password"]?.toString().trim() ?? "";

      final role = result["role"]?.toString() ?? "guru";

      final kelas = result["kelas"]?.toString() ?? "";

      if (nama.isEmpty ||
          username.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi")));

        return;
      }

      /// GURU WAJIB PUNYA KELAS
      if (role == "guru" && kelas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guru wajib memiliki kelas")),
        );

        return;
      }

      /// =========================
      /// CEK USERNAME
      /// =========================
      final usernameCheck =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (usernameCheck.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username sudah digunakan")),
        );

        return;
      }

      /// =========================
      /// CREATE AUTH
      /// =========================
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      /// =========================
      /// SIMPAN USER
      /// =========================
      await _firestore.collection('users').doc(uid).set({
        "nama": nama,

        "username": username,

        "email": email,

        /// admin / guru
        "role": role,

        /// contoh:
        /// 1A
        /// 2B
        /// dst
        "nama_kelas": role == "admin" ? "" : kelas,

        "wali_kelas": role == "admin" ? "" : nama,

        "isActive": true,

        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User berhasil dibuat")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// =========================
  /// HAPUS USER
  /// =========================
  Future<void> _hapusUser(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Hapus User"),

          content: const Text("Yakin ingin menghapus user ini?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('users').doc(uid).delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User berhasil dihapus")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            /// =========================
            /// SEARCH + BUTTON
            /// =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                SizedBox(
                  width: 450,

                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Nama / Username...",

                      prefixIcon: const Icon(Icons.search),

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),

                    onChanged: (v) {
                      setState(() {
                        _searchText = v;
                      });
                    },
                  ),
                ),

                IconButton(
                  iconSize: 40,

                  icon: const CircleAvatar(
                    backgroundColor: Colors.green,

                    child: Icon(Icons.add, color: Colors.white),
                  ),

                  onPressed: _tambahUser,
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// =========================
            /// HEADER
            /// =========================
            Container(
              color: const Color(0xFFFFD700),

              padding: const EdgeInsets.symmetric(vertical: 10),

              child: const Row(
                children: [
                  _HeaderCell("No"),

                  _HeaderCell("Nama"),

                  _HeaderCell("Username"),

                  _HeaderCell("Email"),

                  _HeaderCell("Role"),

                  _HeaderCell("Kelas"),

                  _HeaderCell("Status"),

                  _HeaderCell("Aksi"),
                ],
              ),
            ),

            /// =========================
            /// DATA
            /// =========================
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      _firestore
                          .collection('users')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Belum ada data user"));
                    }

                    final docs = snapshot.data!.docs;

                    /// FILTER SEARCH
                    final filteredDocs =
                        docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final nama =
                              (data['nama'] ?? "").toString().toLowerCase();

                          final username =
                              (data['username'] ?? "").toString().toLowerCase();

                          return nama.contains(_searchText.toLowerCase()) ||
                              username.contains(_searchText.toLowerCase());
                        }).toList();

                    return ListView.builder(
                      itemCount: filteredDocs.length,

                      itemBuilder: (context, i) {
                        final doc = filteredDocs[i];

                        final data = doc.data() as Map<String, dynamic>;

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),

                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),

                          child: Row(
                            children: [
                              _DataCell("${i + 1}"),

                              _DataCell(data["nama"] ?? "-"),

                              _DataCell(data["username"] ?? "-"),

                              _DataCell(data["email"] ?? "-"),

                              _DataCell(data["role"] ?? "-"),

                              _DataCell(
                                data["nama_kelas"] == ""
                                    ? "-"
                                    : data["nama_kelas"],
                              ),

                              _DataCell(
                                data["isActive"] == true ? "Aktif" : "Nonaktif",
                              ),

                              _ActionCell(
                                onEdit: () {
                                  showDialog(
                                    context: context,

                                    builder:
                                        (_) => EditUserDialog(
                                          docId: doc.id,
                                          data: data,
                                        ),
                                  );
                                },

                                onDelete: () {
                                  _hapusUser(doc.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================
/// HEADER
/// =========================
class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,

        textAlign: TextAlign.center,

        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// =========================
/// DATA CELL
/// =========================
class _DataCell extends StatelessWidget {
  final dynamic text;

  const _DataCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text(text.toString(), textAlign: TextAlign.center));
  }
}

/// =========================
/// ACTION CELL
/// =========================
class _ActionCell extends StatelessWidget {
  final VoidCallback onEdit;

  final VoidCallback onDelete;

  const _ActionCell({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),

            onPressed: onEdit,
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),

            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
