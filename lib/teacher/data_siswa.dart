import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_datasiswa.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  String _searchText = "";
  String? _selectedKelas;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
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
            /// ================= SEARCH =================
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Nama Siswa...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _searchText = val);
                    },
                  ),
                ),

                const SizedBox(width: 20),

                const Text("Pilih Kelas"),

                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedKelas,
                      hint: const Text("Pilih"),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: const [
                        DropdownMenuItem(value: "1A", child: Text("1A")),
                        DropdownMenuItem(value: "1B", child: Text("1B")),
                        DropdownMenuItem(value: "2A", child: Text("2A")),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedKelas = value);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// ================= TAMBAH =================
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
                    builder: (_) => const TambahDataSiswaPage(),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            /// ================= TABLE =================
            Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1700, // samakan dengan admin
                    child: Column(
                      children: [
                        /// HEADER
                        Container(
                          color: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Row(
                            children: [
                              _Header("ID"),
                              _Header("Nama"),
                              _Header("NIS"),
                              _Header("NISN"),
                              _Header("Jenis Kelamin"),
                              _Header("Tempat Lahir"),
                              _Header("Tanggal Lahir"),
                              _Header("Kelas"),
                              _Header("Wali Kelas"),
                              _Header("Alamat"),
                              _Header("Telephone"),
                              _Header("Aksi"),
                            ],
                          ),
                        ),

                        /// DATA
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('siswa')
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
                                    final data =
                                        doc.data() as Map<String, dynamic>;

                                    final nama =
                                        (data["nama"] ?? "")
                                            .toString()
                                            .toLowerCase();

                                    final kelas =
                                        (data["nama_kelas"] ?? "").toString();

                                    return nama.contains(
                                          _searchText.toLowerCase(),
                                        ) &&
                                        (_selectedKelas == null ||
                                            kelas == _selectedKelas);
                                  }).toList();

                              if (filteredDocs.isEmpty) {
                                return const Center(
                                  child: Text("Belum ada data siswa"),
                                );
                              }

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
                                        vertical: 10,
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
                                          _Cell(data['nama_kelas'] ?? "-"),
                                          _Cell(data['wali_kelas'] ?? "-"),
                                          _Cell(data['alamat'] ?? "-"),
                                          _Cell(data['telp'] ?? "-"),

                                          _ActionCell(
                                            onEdit: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (_) => TambahDataSiswaPage(
                                                      docId: doc.id,
                                                      data: data,
                                                    ),
                                              );
                                            },
                                            onDelete: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('siswa')
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

/// ================= WIDGET =================

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

class _ActionCell extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionCell({required this.onEdit, required this.onDelete});

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
