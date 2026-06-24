import 'package:flutter/material.dart';

class TambahDataGuruAdminDialog extends StatefulWidget {
  final Map<String, dynamic>? dataAwal;

  const TambahDataGuruAdminDialog({super.key, this.dataAwal});

  @override
  State<TambahDataGuruAdminDialog> createState() =>
      _TambahDataGuruAdminDialogState();
}

class _TambahDataGuruAdminDialogState extends State<TambahDataGuruAdminDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();

  bool get isEdit => widget.dataAwal != null;

  @override
  void initState() {
    super.initState();

    // Jika mode EDIT, isi field dengan data lama
    if (widget.dataAwal != null) {
      _namaController.text = widget.dataAwal!["nama_guru"] ?? "";
      _nipController.text = widget.dataAwal!["nip"] ?? "";
      _jabatanController.text = widget.dataAwal!["jabatan"] ?? "";
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= JUDUL =================
                Text(
                  isEdit ? "Edit Data Guru" : "Tambah Data Guru",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= NAMA =================
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Guru",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama guru wajib diisi";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                /// ================= NIP =================
                TextFormField(
                  controller: _nipController,
                  decoration: const InputDecoration(
                    labelText: "NIP",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "NIP wajib diisi";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                /// ================= JABATAN =================
                TextFormField(
                  controller: _jabatanController,
                  decoration: const InputDecoration(
                    labelText: "Jabatan",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Jabatan wajib diisi";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                /// ================= BUTTON =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            "nama_guru": _namaController.text,
                            "nip": _nipController.text,
                            "jabatan": _jabatanController.text,
                          });
                        }
                      },
                      child: Text(
                        isEdit ? "Simpan" : "Simpan",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
