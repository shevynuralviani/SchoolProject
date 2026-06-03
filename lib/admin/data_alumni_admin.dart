import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_data_alumni.dart';

class DataAlumniAdmin extends StatefulWidget {
  const DataAlumniAdmin({super.key});

  @override
  State<DataAlumniAdmin> createState() => _DataAlumniAdminState();
}

class _DataAlumniAdminState extends State<DataAlumniAdmin> {
  String _searchText = "";

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _openEdit(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TambahAlumniDialog(docId: docId, data: data),
    );
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
            // SEARCH
            SizedBox(
              width: 650,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari Nama Siswa Alumni...",
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

            const SizedBox(height: 16),

            // BUTTON TAMBAH
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                iconSize: 40,
                icon: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.add, color: Colors.white),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const TambahAlumniDialog(),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // TABLE
            Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,

                  child: SizedBox(
                    width: 1700,

                    child: Column(
                      children: [
                        // HEADER
                        Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.amber,

                          child: const Row(
                            children: [
                              _Header("ID"),
                              _Header("Nama"),
                              _Header("NIS"),
                              _Header("NISN"),
                              _Header("Jenis Kelamin"),
                              _Header("Tempat Lahir"),
                              _Header("Tanggal Lahir"),
                              _Header("Alamat"),
                              _Header("Telphone"),
                              _Header("Tahun Lulus"),
                              _Header("Aksi"),
                            ],
                          ),
                        ),

                        // DATA
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('alumni')
                                    .orderBy('created_at', descending: true)
                                    .snapshots(),

                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final docs = snapshot.data!.docs;

                              final filteredDocs =
                                  docs.where((doc) {
                                    final nama =
                                        doc['nama'].toString().toLowerCase();
                                    return nama.contains(
                                      _searchText.toLowerCase(),
                                    );
                                  }).toList();

                              return Scrollbar(
                                controller: _verticalController,
                                thumbVisibility: true,

                                child: ListView.builder(
                                  controller: _verticalController,
                                  itemCount: filteredDocs.length,

                                  itemBuilder: (context, i) {
                                    final doc = filteredDocs[i];
                                    final data =
                                        doc.data() as Map<String, dynamic>;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ),

                                      child: Row(
                                        children: [
                                          _Cell("${i + 1}"),
                                          _Cell(data['nama'] ?? "-"),
                                          _Cell(data['nis'] ?? "-"),
                                          _Cell(data['nisn'] ?? "-"),
                                          _Cell(data['jenis_kelamin'] ?? "-"),
                                          _Cell(data['tempat_lahir'] ?? "-"),
                                          _Cell(data['tanggal_lahir'] ?? "-"),
                                          _Cell(data['alamat'] ?? "-"),
                                          _Cell(data['no_telp'] ?? "-"),
                                          _Cell(data['tahun'] ?? "-"),

                                          _CellAction(
                                            onEdit: () {
                                              _openEdit(doc.id, data);
                                            },

                                            onDelete: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('alumni')
                                                  .doc(doc.id)
                                                  .delete();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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

/* HEADER */

class _Header extends StatelessWidget {
  final String text;

  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/* CELL */

class _Cell extends StatelessWidget {
  final String text;

  const _Cell(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/* ACTION CELL */

class _CellAction extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CellAction({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
