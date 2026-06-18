import 'package:flutter/material.dart';

class TambahUserAdmin extends StatefulWidget {
  final List<String> daftarKelas;

  const TambahUserAdmin({super.key, required this.daftarKelas});

  @override
  State<TambahUserAdmin> createState() => _TambahUserAdminState();
}

class _TambahUserAdminState extends State<TambahUserAdmin> {
  final _namaCtrl = TextEditingController();

  final _usernameCtrl = TextEditingController();

  final _emailCtrl = TextEditingController();

  final _passwordCtrl = TextEditingController();

  /// ROLE
  String _role = "guru";

  /// KELAS
  String? _kelas;

  /// SHOW PASSWORD
  bool _obscure = true;

  @override
  void initState() {
    super.initState();

    /// AUTO PILIH KELAS PERTAMA
    if (widget.daftarKelas.isNotEmpty) {
      _kelas = widget.daftarKelas.first;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// =========================
  /// VALIDASI EMAIL
  /// =========================
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /// =========================
  /// VALIDASI USERNAME
  /// =========================
  bool _isValidUsername(String username) {
    return username.length >= 4 && !username.contains(" ");
  }

  /// =========================
  /// VALIDASI PASSWORD
  /// =========================
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// =========================
  /// SIMPAN
  /// =========================
  void _simpan() {
    final nama = _namaCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    /// VALIDASI KOSONG
    if (nama.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));

      return;
    }

    /// VALIDASI USERNAME
    if (!_isValidUsername(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Username minimal 4 karakter dan tidak boleh ada spasi",
          ),
        ),
      );

      return;
    }

    /// VALIDASI EMAIL
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email tidak valid")));

      return;
    }

    /// VALIDASI PASSWORD
    if (!_isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter")),
      );

      return;
    }

    /// VALIDASI KELAS GURU
    if (_role == "guru") {
      if (_kelas == null || _kelas!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pilih kelas guru")));

        return;
      }
    }

    /// KIRIM DATA
    Navigator.pop(context, {
      "nama": nama,
      "username": username,
      "email": email,
      "password": password,
      "role": _role,

      /// ADMIN TIDAK PUNYA KELAS
      "nama_kelas": _role == "admin" ? "" : _kelas,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      child: SizedBox(
        width: 420,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITLE
              const Center(
                child: Text(
                  "Tambah User",

                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 25),

              /// NAMA
              _field(
                label: "Nama Pengguna",
                controller: _namaCtrl,
                icon: Icons.person,
              ),

              /// USERNAME
              _field(
                label: "Username",
                controller: _usernameCtrl,
                icon: Icons.account_circle,
              ),

              /// EMAIL
              _field(label: "Email", controller: _emailCtrl, icon: Icons.email),

              /// PASSWORD
              _passwordField(),

              const SizedBox(height: 15),

              /// ROLE
              DropdownButtonFormField<String>(
                value: _role,

                decoration: InputDecoration(
                  labelText: "Role",

                  prefixIcon: const Icon(Icons.admin_panel_settings),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                items: const [
                  DropdownMenuItem(value: "admin", child: Text("Admin")),

                  DropdownMenuItem(value: "guru", child: Text("Guru")),
                ],

                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _role = value;

                    /// RESET KELAS ADMIN
                    if (_role == "admin") {
                      _kelas = null;
                    } else {
                      /// AUTO PILIH KELAS PERTAMA
                      if (widget.daftarKelas.isNotEmpty) {
                        _kelas = widget.daftarKelas.first;
                      }
                    }
                  });
                },
              ),

              /// =========================
              /// DROPDOWN KELAS
              /// =========================
              if (_role == "guru") ...[
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: widget.daftarKelas.contains(_kelas) ? _kelas : null,

                  decoration: InputDecoration(
                    labelText: "Kelas",

                    prefixIcon: const Icon(Icons.class_),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  items:
                      widget.daftarKelas.map((kelas) {
                        return DropdownMenuItem(
                          value: kelas,

                          child: Text(kelas),
                        );
                      }).toList(),

                  onChanged: (value) {
                    setState(() {
                      _kelas = value;
                    });
                  },
                ),
              ],

              const SizedBox(height: 30),

              /// BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text("Batal"),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),

                    onPressed: _simpan,

                    icon: const Icon(Icons.save),

                    label: const Text("Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// TEXT FIELD
  /// =========================
  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(icon),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  /// =========================
  /// PASSWORD FIELD
  /// =========================
  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: TextField(
        controller: _passwordCtrl,

        obscureText: _obscure,

        decoration: InputDecoration(
          labelText: "Password",

          prefixIcon: const Icon(Icons.lock),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),

            onPressed: () {
              setState(() {
                _obscure = !_obscure;
              });
            },
          ),
        ),
      ),
    );
  }
}
