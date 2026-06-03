import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TambahAlumniDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const TambahAlumniDialog({super.key, this.docId, this.data});

  @override
  State<TambahAlumniDialog> createState() => _TambahAlumniDialogState();
}

class _TambahAlumniDialogState extends State<TambahAlumniDialog> {
  final _nama = TextEditingController();
  final _nis = TextEditingController();
  final _nisn = TextEditingController();
  final _tahunLulus = TextEditingController();
  final _tempatLahir = TextEditingController();
  final _tglLahir = TextEditingController();
  final _alamat = TextEditingController();
  final _telp = TextEditingController();

  String? _jenisKelamin;

  bool _loading = false;

  bool get isEdit => widget.docId != null;

  @override
  void initState() {
    super.initState();

    if (isEdit && widget.data != null) {
      final d = widget.data!;

      _nama.text = d['nama'] ?? "";
      _nis.text = d['nis'] ?? "";
      _nisn.text = d['nisn'] ?? "";
      _tahunLulus.text = d['tahun'] ?? "";
      _tempatLahir.text = d['tempat_lahir'] ?? "";
      _tglLahir.text = d['tanggal_lahir'] ?? "";
      _alamat.text = d['alamat'] ?? "";
      _telp.text = d['no_telp'] ?? "";
      _jenisKelamin = d['jenis_kelamin'];
    }
  }

  @override
  void dispose() {
    _nama.dispose();
    _nis.dispose();
    _nisn.dispose();
    _tahunLulus.dispose();
    _tempatLahir.dispose();
    _tglLahir.dispose();
    _alamat.dispose();
    _telp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      child: SizedBox(
        width: 750,

        child: Padding(
          padding: const EdgeInsets.all(30),

          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  isEdit ? "Edit Data Alumni" : "Tambah Data Alumni",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                _field("Nama", _nama),
                _field("NIS", _nis),
                _field("NISN", _nisn),

                _dropdownJenisKelamin(),

                _field("Tempat Lahir", _tempatLahir),

                _dateField("Tanggal Lahir", _tglLahir),

                _field("Tahun Lulus", _tahunLulus),

                _field("Alamat", _alamat),

                _field("No. Telp", _telp),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),

                    const SizedBox(width: 25),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _loading ? null : _simpanData,
                      child:
                          _loading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
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
      ),
    );
  }

  Future<void> _simpanData() async {
    if (_nama.text.isEmpty ||
        _nis.text.isEmpty ||
        _nisn.text.isEmpty ||
        _tahunLulus.text.isEmpty ||
        _jenisKelamin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data wajib")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final data = {
        "nama": _nama.text.trim(),
        "nis": _nis.text.trim(),
        "nisn": _nisn.text.trim(),
        "jenis_kelamin": _jenisKelamin,
        "tempat_lahir": _tempatLahir.text.trim(),
        "tanggal_lahir": _tglLahir.text.trim(),
        "tahun": _tahunLulus.text.trim(),
        "alamat": _alamat.text.trim(),
        "no_telp": _telp.text.trim(),

        "updated_at": FieldValue.serverTimestamp(),
      };

      if (isEdit) {
        await FirebaseFirestore.instance
            .collection('alumni')
            .doc(widget.docId)
            .update(data);
      } else {
        data["created_at"] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance.collection('alumni').add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: "Tanggal Lahir",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2005),
            firstDate: DateTime(1980),
            lastDate: DateTime.now(),
          );

          if (picked != null) {
            controller.text = DateFormat('dd-MM-yyyy').format(picked);
          }
        },
      ),
    );
  }

  Widget _dropdownJenisKelamin() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
        onChanged: (v) {
          setState(() => _jenisKelamin = v);
        },
      ),
    );
  }
}
