import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahDataSiswaAdminDialog extends StatefulWidget {
  const TambahDataSiswaAdminDialog({super.key});

  @override
  State<TambahDataSiswaAdminDialog> createState() =>
      _TambahDataSiswaAdminDialogState();
}

class _TambahDataSiswaAdminDialogState
    extends State<TambahDataSiswaAdminDialog> {
  // ================= CONTROLLER =================
  final _namaCtrl = TextEditingController();
  final _nisCtrl = TextEditingController();
  final _nisnCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  // ================= STATE =================
  String? _jenisKelamin;
  String? _kelasId;
  String? _kelasNama;
  String? _waliKelas;
  DateTime? _tanggalLahir;

  List<String> _listWaliKelas = [];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nisCtrl.dispose();
    _nisnCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _alamatCtrl.dispose();
    _telpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: SingleChildScrollView(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text(
                "Tambah Data Siswa",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= KOLOM KIRI =================
                  Expanded(
                    child: Column(
                      children: [
                        _text("Nama Siswa", _namaCtrl),
                        _text("NIS", _nisCtrl),
                        _text("NISN", _nisnCtrl),
                        _text("Tempat Lahir", _tempatLahirCtrl),
                        _buildDatePicker(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ================= KOLOM KANAN =================
                  Expanded(
                    child: Column(
                      children: [
                        _dropdownJenisKelamin(),
                        _dropdownKelasFirestore(),
                        _dropdownWaliKelas(),
                        _text("Alamat", _alamatCtrl),
                        _text("Telephone", _telpCtrl),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ================= BUTTON =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _simpanData,
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DATE PICKER =================

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _tanggalLahir = picked;
      });
    }
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: _pickTanggal,
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: "Tanggal Lahir",
            border: OutlineInputBorder(),
          ),
          child: Text(
            _tanggalLahir == null
                ? "Pilih Tanggal"
                : "${_tanggalLahir!.day}-${_tanggalLahir!.month}-${_tanggalLahir!.year}",
          ),
        ),
      ),
    );
  }

  // ================= SIMPAN DATA =================

  Future<void> _simpanData() async {
    if (_namaCtrl.text.isEmpty ||
        _nisCtrl.text.isEmpty ||
        _nisnCtrl.text.isEmpty ||
        _tempatLahirCtrl.text.isEmpty ||
        _tanggalLahir == null ||
        _alamatCtrl.text.isEmpty ||
        _telpCtrl.text.isEmpty ||
        _kelasId == null ||
        _jenisKelamin == null ||
        _waliKelas == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua data")));
      return;
    }

    await FirebaseFirestore.instance.collection('siswa').add({
      "nama": _namaCtrl.text.trim(),
      "nis": _nisCtrl.text.trim(),
      "nisn": _nisnCtrl.text.trim(),
      "tempat_lahir": _tempatLahirCtrl.text.trim(),

      "tanggal_lahir":
          "${_tanggalLahir!.day}-${_tanggalLahir!.month}-${_tanggalLahir!.year}",

      "jenis_kelamin": _jenisKelamin,
      "alamat": _alamatCtrl.text.trim(),
      "telp": _telpCtrl.text.trim(),
      "kelas_id": _kelasId,
      "nama_kelas": _kelasNama,
      "wali_kelas": _waliKelas,

      "created_at": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data siswa berhasil ditambahkan")),
    );

    Navigator.pop(context);
  }

  // ================= TEXT FIELD =================

  Widget _text(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ================= DROPDOWN JENIS KELAMIN =================

  Widget _dropdownJenisKelamin() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _jenisKelamin,
        decoration: const InputDecoration(
          labelText: "Jenis Kelamin",
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: "Laki-laki", child: Text("Laki-laki")),
          DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
        ],
        onChanged: (v) => setState(() => _jenisKelamin = v),
      ),
    );
  }

  // ================= DROPDOWN KELAS =================

  Widget _dropdownKelasFirestore() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('kelas').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.only(bottom: 15));
        }

        final docs = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: DropdownButtonFormField<String>(
            value: docs.any((d) => d.id == _kelasId) ? _kelasId : null,

            decoration: const InputDecoration(
              labelText: "Kelas",
              border: OutlineInputBorder(),
            ),

            items:
                docs.map((d) {
                  return DropdownMenuItem<String>(
                    value: d.id,
                    child: Text(d['nama']),
                  );
                }).toList(),

            onChanged: (v) async {
              if (v == null) return;

              final kelasDoc =
                  await FirebaseFirestore.instance
                      .collection('kelas')
                      .doc(v)
                      .get();

              setState(() {
                _kelasId = v;
                _kelasNama = kelasDoc['nama_kelas'] ?? '';
                _waliKelas = kelasDoc['nama_guru'] ?? '';
                _listWaliKelas = [kelasDoc['nama_guru'] ?? ''];
              });
            },
          ),
        );
      },
    );
  }

  // ================= DROPDOWN WALI KELAS =================

  Widget _dropdownWaliKelas() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _waliKelas,
        decoration: const InputDecoration(
          labelText: "Wali Kelas",
          border: OutlineInputBorder(),
        ),
        items:
            _listWaliKelas.map((wali) {
              return DropdownMenuItem(value: wali, child: Text(wali));
            }).toList(),
        onChanged: (v) => setState(() => _waliKelas = v),
      ),
    );
  }
}
