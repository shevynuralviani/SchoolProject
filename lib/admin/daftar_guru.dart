import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_data_guru_admin.dart';

class DataGuruAdminContent extends StatefulWidget {
  const DataGuruAdminContent({super.key});

  @override
  State<DataGuruAdminContent> createState() => _DataGuruAdminContentState();
}

class _DataGuruAdminContentState extends State<DataGuruAdminContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchText = "";

  /// ================= TAMBAH DATA =================
  Future<void> tambahGuru(Map<String, String> data) async {
    await _firestore.collection("guru").add({
      "nama_guru": data["nama_guru"],
      "nip": data["nip"],
      "jabatan": data["jabatan"],
      "created_at": FieldValue.serverTimestamp(),
    });
  }

  /// ================= EDIT DATA =================
  Future<void> editGuru(String docId, Map<String, String> data) async {
    await _firestore.collection("guru").doc(docId).update({
      "nama_guru": data["nama_guru"],
      "nip": data["nip"],
      "jabatan": data["jabatan"],
    });
  }

  /// ================= DELETE DATA =================
  Future<void> deleteGuru(String docId) async {
    await _firestore.collection("guru").doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SEARCH
            SizedBox(
              width: 650,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari Nama Guru...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchText = value);
                },
              ),
            ),

            const SizedBox(height: 15),

            /// TOMBOL TAMBAH
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                iconSize: 40,
                icon: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.add, color: Colors.white),
                ),
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const TambahDataGuruAdminDialog(),
                  );

                  if (result != null && result is Map<String, String>) {
                    await tambahGuru(result);
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            /// HEADER
            Container(
              color: const Color(0xFFFFD700),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: const [
                  _HeaderCell("ID"),
                  _HeaderCell("Nama Guru"),
                  _HeaderCell("NIP"),
                  _HeaderCell("Jabatan"),
                  _HeaderCell("Aksi"),
                ],
              ),
            ),

            /// DATA REALTIME FIRESTORE
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection("guru")
                        .orderBy("created_at", descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Belum ada data guru"));
                  }

                  final docs = snapshot.data!.docs;

                  final filteredDocs =
                      docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final nama =
                            (data["nama_guru"] ?? "").toString().toLowerCase();

                        return nama.contains(_searchText.toLowerCase());
                      }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            _DataCell("${index + 1}"),
                            _DataCell(data["nama_guru"] ?? "-"),
                            _DataCell(data["nip"] ?? "-"),
                            _DataCell(data["jabatan"] ?? "-"),
                            _ActionCell(
                              onEdit: () async {
                                final result = await showDialog(
                                  context: context,
                                  builder:
                                      (_) => TambahDataGuruAdminDialog(
                                        dataAwal: data,
                                      ),
                                );

                                if (result != null) {
                                  await editGuru(doc.id, result);
                                }
                              },
                              onDelete: () => deleteGuru(doc.id),
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
    );
  }
}

/* ===================== WIDGET CELL ===================== */

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

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text(text, textAlign: TextAlign.center));
  }
}

class _ActionCell extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionCell({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
