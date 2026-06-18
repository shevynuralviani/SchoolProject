import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditDataSiswaPage extends StatefulWidget {
  final String? siswaId;
  final Map<String, dynamic>? dataSiswa;

  const EditDataSiswaPage({super.key, this.siswaId, this.dataSiswa});

  @override
  State<EditDataSiswaPage> createState() => _EditDataSiswaPageState();
}

class _EditDataSiswaPageState extends State<EditDataSiswaPage> {
  // ================= CONTROLLER =================
  final _namaCtrl = TextEditingController();
  final _nisCtrl = TextEditingController();
  final _nisnCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();

  final _kelasCtrl = TextEditingController();
  final _waliCtrl = TextEditingController();

  // ================= STATE =================
  String? _jenisKelamin;
  DateTime? _tanggalLahir;
  bool _loadingKelas = true;
  bool _isSaving = false;

  bool get isEdit => widget.siswaId != null;

  @override
  void initState() {
    super.initState();
    _loadDataGuru();

    if (isEdit && widget.dataSiswa != null) {
      final data = widget.dataSiswa!;

      _namaCtrl.text = data['nama'] ?? '';
      _nisCtrl.text = data['nis'] ?? '';
      _nisnCtrl.text = data['nisn'] ?? '';
      _tempatLahirCtrl.text = data['tempat_lahir'] ?? '';
      _alamatCtrl.text = data['alamat'] ?? '';
      _telpCtrl.text = data['telephone'] ?? '';
      _kelasCtrl.text = data['nama_kelas'] ?? '';
      _waliCtrl.text = data['nama_guru'] ?? '';
      _jenisKelamin = data['jenis_kelamin'];

      if (data['tanggal_lahir'] != null) {
        final parts = (data['tanggal_lahir'] as String).split('-');
        if (parts.length == 3) {
          _tanggalLahir = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nisCtrl.dispose();
    _nisnCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _alamatCtrl.dispose();
    _telpCtrl.dispose();
    _kelasCtrl.dispose();
    _waliCtrl.dispose();
    super.dispose();
  }

  // ================= LOAD DATA GURU =================
  Future<void> _loadDataGuru() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final kelasNama = userDoc.data()?['nama_kelas'];

      if (kelasNama == null || kelasNama.isEmpty) {
        setState(() => _loadingKelas = false);
        return;
      }

      final kelasQuery =
          await FirebaseFirestore.instance
              .collection('kelas')
              .where('nama_kelas', isEqualTo: kelasNama)
              .limit(1)
              .get();

      if (kelasQuery.docs.isNotEmpty) {
        final kelasData = kelasQuery.docs.first.data();

        setState(() {
          _kelasCtrl.text = kelasNama;
          _waliCtrl.text = kelasData['nama_guru'] ?? '';
          _loadingKelas = false;
        });
      } else {
        setState(() => _loadingKelas = false);
      }
    } catch (e) {
      setState(() => _loadingKelas = false);
    }
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
      setState(() => _tanggalLahir = picked);
    }
  }

  // ================= SIMPAN / UPDATE =================
  Future<void> _simpanData() async {
    if (_namaCtrl.text.isEmpty ||
        _nisCtrl.text.isEmpty ||
        _nisnCtrl.text.isEmpty ||
        _tempatLahirCtrl.text.isEmpty ||
        _alamatCtrl.text.isEmpty ||
        _telpCtrl.text.isEmpty ||
        _tanggalLahir == null ||
        _jenisKelamin == null ||
        _kelasCtrl.text.isEmpty ||
        _waliCtrl.text.isEmpty) {
      _showError("Lengkapi semua data terlebih dahulu");
      return;
    }

    try {
      setState(() => _isSaving = true);

      final data = {
        "nama": _namaCtrl.text.trim(),
        "nis": _nisCtrl.text.trim(),
        "nisn": _nisnCtrl.text.trim(),
        "jenis_kelamin": _jenisKelamin,
        "tempat_lahir": _tempatLahirCtrl.text.trim(),
        "tanggal_lahir":
            "${_tanggalLahir!.day}-${_tanggalLahir!.month}-${_tanggalLahir!.year}",
        "nama_kelas": _kelasCtrl.text,
        "nama_guru": _waliCtrl.text,
        "alamat": _alamatCtrl.text.trim(),
        "telephone": _telpCtrl.text.trim(),
      };

      if (isEdit) {
        await FirebaseFirestore.instance
            .collection('siswa')
            .doc(widget.siswaId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('siswa').add({
          ...data,
          "created_at": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Data siswa berhasil diupdate"
                : "Data siswa berhasil ditambahkan",
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(title: const Text("Error"), content: Text(msg)),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (_loadingKelas) {
      return const Center(child: CircularProgressIndicator());
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                isEdit ? "Edit Data Siswa" : "Tambah Data Siswa",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _text("Nama Siswa", _namaCtrl),
                        _text("NIS", _nisCtrl),
                        _text("NISN", _nisnCtrl),
                        _text("Tempat Lahir", _tempatLahirCtrl),
                        _datePicker(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      children: [
                        _genderDropdown(),
                        _readonly("Kelas", _kelasCtrl),
                        _readonly("Wali Kelas", _waliCtrl),
                        _text("Alamat", _alamatCtrl),
                        _text("Telephone", _telpCtrl),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

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
                            : Text(
                              isEdit ? "Update" : "Simpan",
                              style: const TextStyle(color: Colors.white),
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

  // ================= WIDGET =================
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

  Widget _readonly(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
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

  Widget _datePicker() {
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
}
