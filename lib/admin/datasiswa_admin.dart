import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_data_siswa_admin.dart';

class DataSiswaAdminContent extends StatefulWidget {
  const DataSiswaAdminContent({super.key});

  @override
  State<DataSiswaAdminContent> createState() => _DataSiswaAdminContentState();
}

class _DataSiswaAdminContentState extends State<DataSiswaAdminContent> {
  String _searchText = "";

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
            /// SEARCH
            SizedBox(
              width: 650,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari Nama Siswa...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 15),

            /// BUTTON TAMBAH
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                iconSize: 40,
                icon: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.add, color: Colors.white),
                ),
                tooltip: "Tambah Data Siswa",
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const TambahDataSiswaAdminDialog(),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            /// TABLE
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
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Text("Belum ada data siswa"),
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
                                                    (_) => EditDataSiswaDialog(
                                                      docId: doc.id,
                                                      data: data,
                                                    ),
                                              );
                                            },
                                            onDelete: () async {
                                              final confirm = await showDialog(
                                                context: context,
                                                builder:
                                                    (_) => AlertDialog(
                                                      title: const Text(
                                                        "Konfirmasi",
                                                      ),
                                                      content: const Text(
                                                        "Yakin ingin menghapus data ini?",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                          child: const Text(
                                                            "Batal",
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                          child: const Text(
                                                            "Hapus",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirm == true) {
                                                await FirebaseFirestore.instance
                                                    .collection('siswa')
                                                    .doc(doc.id)
                                                    .delete();
                                              }
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
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ActionCell({required this.onDelete, required this.onEdit});

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

class EditDataSiswaDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditDataSiswaDialog({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<EditDataSiswaDialog> createState() => _EditDataSiswaDialogState();
}

class _EditDataSiswaDialogState extends State<EditDataSiswaDialog> {
  late TextEditingController namaController;
  late TextEditingController nisController;
  late TextEditingController nisnController;
  late TextEditingController tempatLahirController;
  late TextEditingController tanggalLahirController;
  late TextEditingController alamatController;
  late TextEditingController telpController;

  String? jenisKelamin;

  @override
  void initState() {
    super.initState();

    namaController = TextEditingController(text: widget.data['nama']);
    nisController = TextEditingController(text: widget.data['nis']);
    nisnController = TextEditingController(text: widget.data['nisn']);
    tempatLahirController = TextEditingController(
      text: widget.data['tempat_lahir'],
    );
    tanggalLahirController = TextEditingController(
      text: widget.data['tanggal_lahir'],
    );
    alamatController = TextEditingController(text: widget.data['alamat']);
    telpController = TextEditingController(text: widget.data['telp']);

    jenisKelamin = widget.data['jenis_kelamin'];
  }

  Future<void> updateData() async {
    await FirebaseFirestore.instance
        .collection('siswa')
        .doc(widget.docId)
        .update({
          "nama": namaController.text,
          "nis": nisController.text,
          "nisn": nisnController.text,
          "jenis_kelamin": jenisKelamin,
          "tempat_lahir": tempatLahirController.text,
          "tanggal_lahir": tanggalLahirController.text,
          "alamat": alamatController.text,
          "telp": telpController.text,
        });

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil diperbarui")));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: Container(
        width: 850,
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Data Siswa",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// KIRI
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: "Nama Siswa",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: nisController,
                        decoration: const InputDecoration(
                          labelText: "NIS",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: nisnController,
                        decoration: const InputDecoration(
                          labelText: "NISN",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: tempatLahirController,
                        decoration: const InputDecoration(
                          labelText: "Tempat Lahir",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                /// KANAN
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: jenisKelamin,
                        decoration: const InputDecoration(
                          labelText: "Jenis Kelamin",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Laki-laki",
                            child: Text("Laki-laki"),
                          ),
                          DropdownMenuItem(
                            value: "Perempuan",
                            child: Text("Perempuan"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            jenisKelamin = value.toString();
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: tanggalLahirController,
                        decoration: const InputDecoration(
                          labelText: "Tanggal Lahir",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: alamatController,
                        decoration: const InputDecoration(
                          labelText: "Alamat",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: telpController,
                        decoration: const InputDecoration(
                          labelText: "Telephone",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// TOMBOL
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),

                const SizedBox(width: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: updateData,
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
    );
  }
}
