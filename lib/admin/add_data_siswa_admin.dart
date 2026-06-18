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
                    onPressed: _isSaving ? null : _simpanData,
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
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

  bool _isSaving = false;

  Future<void> _simpanData() async {
    if (_namaCtrl.text.trim().isEmpty ||
        _nisCtrl.text.trim().isEmpty ||
        _nisnCtrl.text.trim().isEmpty ||
        _tempatLahirCtrl.text.trim().isEmpty ||
        _alamatCtrl.text.trim().isEmpty ||
        _telpCtrl.text.trim().isEmpty ||
        _tanggalLahir == null ||
        _kelasId == null ||
        _kelasNama == null ||
        _waliKelas == null ||
        _jenisKelamin == null) {
      showDialog(
        context: context,
        builder:
            (_) => const AlertDialog(
              title: Text('Peringatan'),
              content: Text('Lengkapi semua data terlebih dahulu.'),
            ),
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      await FirebaseFirestore.instance.collection('siswa').add({
        "nama": _namaCtrl.text.trim(),
        "nis": _nisCtrl.text.trim(),
        "nisn": _nisnCtrl.text.trim(),

        "jenis_kelamin": _jenisKelamin,

        "tempat_lahir": _tempatLahirCtrl.text.trim(),

        "tanggal_lahir":
            "${_tanggalLahir!.day}-${_tanggalLahir!.month}-${_tanggalLahir!.year}",

        "nama_kelas": _kelasNama,

        "wali_kelas": _waliKelas,

        "alamat": _alamatCtrl.text.trim(),

        "telephone": _telpCtrl.text.trim(),

        "created_at": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data siswa berhasil ditambahkan")),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error"),
              content: Text(e.toString()),
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
                    child: Text(d['nama_kelas']),
                  );
                }).toList(),

            onChanged: (v) async {
              if (v == null) return;

              final kelasDoc =
                  await FirebaseFirestore.instance
                      .collection('kelas')
                      .doc(v)
                      .get();

              final data = kelasDoc.data() as Map<String, dynamic>;

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
