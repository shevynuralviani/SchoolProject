import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserDialog extends StatefulWidget {
  final String docId;

  final Map<String, dynamic> data;

  const EditUserDialog({super.key, required this.docId, required this.data});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _namaCtrl;

  late TextEditingController _usernameCtrl;

  String _role = "guru";

  String? _kelas;

  bool _isActive = true;

  List<String> daftarKelas = [];

  bool loadingKelas = true;

  @override
  void initState() {
    super.initState();

    _namaCtrl = TextEditingController(text: widget.data["nama"] ?? "");

    _usernameCtrl = TextEditingController(text: widget.data["username"] ?? "");

    _role = widget.data["role"] ?? "guru";

    _kelas = widget.data["kelas"];

    _isActive = widget.data["isActive"] ?? true;

    loadKelas();
  }

  /// =========================
  /// LOAD KELAS
  /// =========================
  Future<void> loadKelas() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('daftar_kelas')
              .orderBy('nama_kelas')
              .get();

      daftarKelas =
          snapshot.docs.map((e) => e['nama_kelas'].toString()).toList();

      /// CEGAH ERROR DROPDOWN
      if (!daftarKelas.contains(_kelas)) {
        if (daftarKelas.isNotEmpty) {
          _kelas = daftarKelas.first;
        }
      }

      setState(() {
        loadingKelas = false;
      });
    } catch (e) {
      setState(() {
        loadingKelas = false;
      });
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();

    _usernameCtrl.dispose();

    super.dispose();
  }

  /// =========================
  /// VALIDASI USERNAME
  /// =========================
  bool isValidUsername(String username) {
    return username.length >= 4 && !username.contains(" ");
  }

  /// =========================
  /// UPDATE USER
  /// =========================
  Future<void> updateUser() async {
    final nama = _namaCtrl.text.trim();

    final username = _usernameCtrl.text.trim();

    /// VALIDASI
    if (nama.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan username wajib diisi")),
      );

      return;
    }

    /// VALIDASI USERNAME
    if (!isValidUsername(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Username minimal 4 karakter dan tidak boleh ada spasi",
          ),
        ),
      );

      return;
    }

    /// VALIDASI KELAS
    if (_role == "guru") {
      if (_kelas == null || _kelas!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guru wajib memiliki kelas")),
        );

        return;
      }
    }

    try {
      /// CEK USERNAME DUPLIKAT
      final usernameCheck =
          await FirebaseFirestore.instance
              .collection("users")
              .where("username", isEqualTo: username)
              .get();

      bool usernameDipakai = usernameCheck.docs.any(
        (doc) => doc.id != widget.docId,
      );

      if (usernameDipakai) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username sudah digunakan")),
        );

        return;
      }

      /// UPDATE FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.docId)
          .update({
            "nama": nama,

            "username": username,

            "role": _role,

            /// ADMIN TIDAK PUNYA KELAS
            "kelas": _role == "admin" ? "" : _kelas,

            "isActive": _isActive,

            "updatedAt": FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User berhasil diupdate")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// =========================
  /// LABEL
  /// =========================
  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),

        child: Text(
          text,

          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// TEXT FIELD
  /// =========================
  Widget _textField(TextEditingController controller) {
    return TextField(
      controller: controller,

      style: const TextStyle(fontSize: 16),

      decoration: InputDecoration(
        filled: true,

        fillColor: const Color(0xFFF2F2F2),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),

          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      title: const Text(
        "Edit User",

        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      content: SizedBox(
        width: 380,

        child:
            loadingKelas
                ? const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                )
                : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      /// NAMA
                      _label("Nama"),

                      _textField(_namaCtrl),

                      const SizedBox(height: 16),

                      /// USERNAME
                      _label("Username"),

                      _textField(_usernameCtrl),

                      const SizedBox(height: 16),

                      /// ROLE
                      _label("Role"),

                      DropdownButtonFormField<String>(
                        value: _role,

                        decoration: InputDecoration(
                          filled: true,

                          fillColor: const Color(0xFFF2F2F2),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),

                            borderSide: const BorderSide(color: Colors.grey),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),

                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: "admin",
                            child: Text("Admin"),
                          ),

                          DropdownMenuItem(value: "guru", child: Text("Guru")),
                        ],

                        onChanged: (v) {
                          if (v == null) return;

                          setState(() {
                            _role = v;

                            /// RESET KELAS ADMIN
                            if (_role == "admin") {
                              _kelas = null;
                            } else {
                              if (daftarKelas.isNotEmpty) {
                                _kelas = daftarKelas.first;
                              }
                            }
                          });
                        },
                      ),

                      /// =========================
                      /// KELAS
                      /// =========================
                      if (_role == "guru") ...[
                        const SizedBox(height: 16),

                        _label("Kelas"),

                        DropdownButtonFormField<String>(
                          value: daftarKelas.contains(_kelas) ? _kelas : null,

                          decoration: InputDecoration(
                            filled: true,

                            fillColor: const Color(0xFFF2F2F2),

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(color: Colors.grey),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),

                          items:
                              daftarKelas.map((kelas) {
                                return DropdownMenuItem(
                                  value: kelas,

                                  child: Text(kelas),
                                );
                              }).toList(),

                          onChanged: (v) {
                            setState(() {
                              _kelas = v;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      /// =========================
                      /// STATUS USER
                      /// =========================
                      SwitchListTile(
                        value: _isActive,

                        title: const Text("User Aktif"),

                        subtitle: Text(
                          _isActive ? "Akun dapat login" : "Akun dinonaktifkan",
                        ),

                        onChanged: (v) {
                          setState(() {
                            _isActive = v;
                          });
                        },
                      ),
                    ],
                  ),
                ),
      ),

      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },

          child: const Text("Batal"),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          onPressed: updateUser,

          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
