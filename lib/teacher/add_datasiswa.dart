import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahDataSiswaPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const TambahDataSiswaPage({super.key, this.docId, this.data});

  @override
  State<TambahDataSiswaPage> createState() => _TambahDataSiswaPageState();
}

class _TambahDataSiswaPageState extends State<TambahDataSiswaPage> {
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _nisCtrl = TextEditingController(); // tambahan
  final TextEditingController _nisnCtrl = TextEditingController();
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _telpCtrl = TextEditingController();
  final TextEditingController _tempatLahirCtrl = TextEditingController();
  final TextEditingController _tanggalLahirCtrl = TextEditingController();

  String? _jenisKelamin;
  String? _kelas;
  String? _waliKelas;

  /// ================= SIMPAN KE FIRESTORE =================
  Future<void> simpanData() async {
    await FirebaseFirestore.instance.collection('siswa').add({
      "nama": _namaCtrl.text,
      "nis": _nisCtrl.text,
      "nisn": _nisnCtrl.text,
      "jenis_kelamin": _jenisKelamin,
      "tempat_lahir": _tempatLahirCtrl.text,
      "tanggal_lahir": _tanggalLahirCtrl.text,
      "nama_kelas": _kelas,
      "wali_kelas": _waliKelas,
      "alamat": _alamatCtrl.text,
      "telp": _telpCtrl.text,
      "created_at": FieldValue.serverTimestamp(),
      "role": "guru", // penanda uploader
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Tambah Data Siswa",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),

                /// ================= FORM =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// KIRI
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            "Nama Siswa",
                            _namaCtrl,
                            hint: "Masukkan Nama Siswa",
                          ),
                          _buildTextField(
                            "NIS",
                            _nisCtrl,
                            hint: "Masukkan NIS",
                          ),
                          _buildTextField(
                            "NISN",
                            _nisnCtrl,
                            hint: "Masukkan NISN",
                          ),
                          _buildTextField("Tempat Lahir", _tempatLahirCtrl),
                          _buildTextField("Tanggal Lahir", _tanggalLahirCtrl),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    /// KANAN
                    Expanded(
                      child: Column(
                        children: [
                          _buildDropdown(
                            "Jenis Kelamin",
                            _jenisKelamin,
                            ["Laki-laki", "Perempuan"],
                            (val) => setState(() => _jenisKelamin = val),
                          ),
                          _buildDropdown("Kelas", _kelas, [
                            "1A",
                            "1B",
                            "2A",
                            "2B",
                          ], (val) => setState(() => _kelas = val)),
                          _buildDropdown(
                            "Wali Kelas",
                            _waliKelas,
                            ["Ust. Ahmad", "Ustadzah Rina", "Ustadz Fajar"],
                            (val) => setState(() => _waliKelas = val),
                          ),
                          _buildTextField("Alamat", _alamatCtrl),
                          _buildTextField("Telephone", _telpCtrl),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// ================= BUTTON =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Batal"),
                    ),

                    const SizedBox(width: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (_namaCtrl.text.isEmpty || _nisnCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Nama & NISN wajib diisi"),
                            ),
                          );
                          return;
                        }

                        simpanData();
                      },
                      child: const Text(
                        "Unggah",
                        style: TextStyle(color: Colors.white),
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

  /// ================= TEXTFIELD =================
  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          isDense: true,
        ),
      ),
    );
  }

  /// ================= DROPDOWN =================
  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          isDense: true,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: const Text("Pilih"),
            items:
                items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
