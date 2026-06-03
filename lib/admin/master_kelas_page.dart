import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MasterKelasPage extends StatefulWidget {
  const MasterKelasPage({super.key});

  @override
  State<MasterKelasPage> createState() => _MasterKelasPageState();
}

class _MasterKelasPageState extends State<MasterKelasPage> {
  final TextEditingController _kelasCtrl = TextEditingController();
  final TextEditingController _tpCtrl = TextEditingController();

  String? _guruTerpilihId;
  String? _editId;
  bool _isEdit = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _kelasCtrl.dispose();
    _tpCtrl.dispose();
    super.dispose();
  }

  /// ================= VALIDASI =================
  bool _validate() {
    if (_kelasCtrl.text.isEmpty ||
        _tpCtrl.text.isEmpty ||
        _guruTerpilihId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return false;
    }
    return true;
  }

  /// ================= TAMBAH =================
  Future<void> _tambahKelas() async {
    if (!_validate()) return;

    final guruDoc =
        await _firestore.collection("guru").doc(_guruTerpilihId).get();

    await _firestore.collection("kelas").add({
      "nama_kelas": _kelasCtrl.text.trim(),
      "tahun_pelajaran": _tpCtrl.text.trim(),
      "guru_id": _guruTerpilihId,
      "nama_guru": guruDoc.data()?["nama_guru"] ?? "-",
      "created_at": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Kelas berhasil ditambahkan")));

    _resetForm();
  }

  /// ================= UPDATE =================
  Future<void> _updateKelas() async {
    if (!_validate() || _editId == null) return;

    final guruDoc =
        await _firestore.collection("guru").doc(_guruTerpilihId).get();

    await _firestore.collection("kelas").doc(_editId).update({
      "nama_kelas": _kelasCtrl.text.trim(),
      "tahun_pelajaran": _tpCtrl.text.trim(),
      "guru_id": _guruTerpilihId,
      "nama_guru": guruDoc.data()?["nama_guru"] ?? "-",
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Kelas berhasil diupdate")));

    _resetForm();
  }

  /// ================= HAPUS =================
  Future<void> _hapusKelas(String id) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text("Yakin ingin menghapus kelas ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _firestore.collection("kelas").doc(id).delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kelas berhasil dihapus")));
    }
  }

  /// ================= EDIT MODE =================
  void _editKelas(DocumentSnapshot data) {
    setState(() {
      _editId = data.id;
      _isEdit = true;
      _kelasCtrl.text = data["nama_kelas"] ?? "";
      _tpCtrl.text = data["tahun_pelajaran"] ?? "";
      _guruTerpilihId = data["guru_id"];
    });
  }

  /// ================= RESET =================
  void _resetForm() {
    _kelasCtrl.clear();
    _tpCtrl.clear();
    setState(() {
      _guruTerpilihId = null;
      _editId = null;
      _isEdit = false;
    });
  }

  /// ================= STREAM GURU =================
  Stream<QuerySnapshot> getGuruStream() {
    return _firestore.collection("guru").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            /// ================= TABEL =================
            Expanded(
              flex: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Data Kelas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      /// HEADER
                      Container(
                        color: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Row(
                          children: [
                            _HeaderCell("No"),
                            _HeaderCell("Kelas"),
                            _HeaderCell("Tahun Pelajaran"),
                            _HeaderCell("Nama Guru"),
                            _HeaderCell("Aksi"),
                          ],
                        ),
                      ),

                      /// DATA FIRESTORE
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream:
                              _firestore
                                  .collection("kelas")
                                  .orderBy("created_at", descending: true)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, i) {
                                final data = docs[i];

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _DataCell("${i + 1}"),
                                      _DataCell(data["nama_kelas"] ?? "-"),
                                      _DataCell(data["tahun_pelajaran"] ?? "-"),
                                      _DataCell(data["nama_guru"] ?? "-"),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () => _editKelas(data),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => _hapusKelas(data.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            /// ================= FORM =================
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          _isEdit ? "Edit Kelas" : "Tambah Kelas",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _kelasCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nama Kelas",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: _tpCtrl,
                          decoration: const InputDecoration(
                            labelText: "Tahun Ajaran (Contoh: 2025/2026)",
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 15),

                        StreamBuilder<QuerySnapshot>(
                          stream: getGuruStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final guruDocs = snapshot.data!.docs;

                            return DropdownButtonFormField<String>(
                              value: _guruTerpilihId,
                              decoration: const InputDecoration(
                                labelText: "Nama Guru",
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  guruDocs.map((doc) {
                                    return DropdownMenuItem<String>(
                                      value: doc.id,
                                      child: Text(doc["nama_guru"] ?? "-"),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _guruTerpilihId = value;
                                });
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isEdit ? Colors.orange : Colors.green,
                            ),
                            onPressed: _isEdit ? _updateKelas : _tambahKelas,
                            child: Text(
                              _isEdit ? "Update" : "Simpan",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HEADER
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

/// DATA
class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text(text, textAlign: TextAlign.center));
  }
}
