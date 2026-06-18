import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_datasiswa.dart';
import 'edit_data_siswa.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  String _searchText = "";
  String? _kelasGuru;
  bool _loading = true;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ambilKelasGuru();
  }

  Future<void> _ambilKelasGuru() async {
    try {
      final email = FirebaseAuth.instance.currentUser?.email;

      if (email == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();

        setState(() {
          _kelasGuru = (data['nama_kelas'] ?? '').toString().trim();

          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print(e);

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_kelasGuru == null || _kelasGuru!.isEmpty) {
      return const Center(
        child: Text(
          "Guru belum memiliki kelas",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "Cari Nama Siswa...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),

            const SizedBox(height: 15),

            /// TOMBOL TAMBAH SISWA
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 28),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return const Dialog(
                        child: SizedBox(
                          width: 700,
                          child: TambahDataSiswaPage(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            /// TABEL
            Expanded(
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,

                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,

                  child: SizedBox(
                    width: 1750,

                    child: Column(
                      children: [
                        /// HEADER
                        Container(
                          color: const Color(0xFFFFD700),

                          padding: const EdgeInsets.symmetric(vertical: 12),

                          child: const Row(
                            children: [
                              _Header("No"),
                              _Header("Nama"),
                              _Header("NIS"),
                              _Header("NISN"),
                              _Header("Jenis Kelamin"),
                              _Header("Tempat Lahir"),
                              _Header("Tanggal Lahir"),
                              _Header("Kelas"),
                              _Header("Wali Kelas"),
                              _Header("Alamat"),
                              _Header("Telepon"),
                              _Header("Aksi"),
                            ],
                          ),
                        ),

                        /// DATA SISWA
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('siswa')
                                    .where('nama_kelas', isEqualTo: _kelasGuru)
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
                                        (data['nama'] ?? "")
                                            .toString()
                                            .toLowerCase();

                                    return nama.contains(
                                      _searchText.toLowerCase(),
                                    );
                                  }).toList();

                              if (filteredDocs.isEmpty) {
                                return const Center(
                                  child: Text("Tidak ada data siswa"),
                                );
                              }

                              return Scrollbar(
                                controller: _verticalController,
                                thumbVisibility: true,

                                child: ListView.builder(
                                  controller: _verticalController,

                                  itemCount: filteredDocs.length,

                                  itemBuilder: (context, index) {
                                    final doc = filteredDocs[index];

                                    final docId = doc.id;

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
                                          _Cell("${index + 1}"),
                                          _Cell(data['nama'] ?? "-"),
                                          _Cell(data['nis'] ?? "-"),
                                          _Cell(data['nisn'] ?? "-"),
                                          _Cell(data['jenis_kelamin'] ?? "-"),
                                          _Cell(data['tempat_lahir'] ?? "-"),
                                          _Cell(data['tanggal_lahir'] ?? "-"),
                                          _Cell(data['nama_kelas'] ?? "-"),
                                          _Cell(data['wali_kelas'] ?? "-"),
                                          _Cell(data['alamat'] ?? "-"),
                                          _Cell(data['telephone'] ?? "-"),

                                          /// AKSI
                                          SizedBox(
                                            width: 140,

                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,

                                              children: [
                                                IconButton(
                                                  iconSize: 20,
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.orange,
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder:
                                                          (_) =>
                                                              EditDataSiswaPage(
                                                                siswaId: docId,
                                                                dataSiswa: data,
                                                              ),
                                                    );
                                                  },
                                                ),

                                                IconButton(
                                                  iconSize: 20,
                                                  padding: EdgeInsets.zero,

                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),

                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            "Konfirmasi Hapus",
                                                          ),
                                                          content: const Text(
                                                            "Apakah kamu yakin ingin menghapus data siswa ini?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: const Text(
                                                                "Batal",
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () async {
                                                                Navigator.pop(
                                                                  context,
                                                                );

                                                                try {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                        'siswa',
                                                                      )
                                                                      .doc(
                                                                        docId,
                                                                      )
                                                                      .delete();

                                                                  if (!context
                                                                      .mounted)
                                                                    return;

                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                        "Data siswa berhasil dihapus",
                                                                      ),
                                                                    ),
                                                                  );
                                                                } catch (e) {
                                                                  if (!context
                                                                      .mounted)
                                                                    return;

                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  ).showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                        "Gagal menghapus: $e",
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: const Text(
                                                                "Hapus",
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
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
