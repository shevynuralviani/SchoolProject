import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:html' as html;

import 'tambah_surat.dart';

class SuratKeteranganPage extends StatefulWidget {
  const SuratKeteranganPage({super.key});

  @override
  State<SuratKeteranganPage> createState() => _SuratKeteranganPageState();
}

class _SuratKeteranganPageState extends State<SuratKeteranganPage> {
  /// ================= FORMAT TANGGAL =================
  String formatTanggal(Timestamp? timestamp) {
    if (timestamp == null) return "-";

    try {
      DateTime date = timestamp.toDate();

      List<String> bulan = [
        "Januari",
        "Februari",
        "Maret",
        "April",
        "Mei",
        "Juni",
        "Juli",
        "Agustus",
        "September",
        "Oktober",
        "November",
        "Desember",
      ];

      return "${date.day} ${bulan[date.month - 1]} ${date.year}";
    } catch (e) {
      return "-";
    }
  }

  /// ================= PRINT ULANG =================
  Future<void> printUlangPdf(Map<String, dynamic> data) async {
    try {
      final Uint8List bytes = await generatePdfFromData(data);

      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.window.open(url, "_blank");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal print: $e")));
    }
  }

  /// ================= DELETE SURAT =================
  Future<void> deleteSurat(String docId) async {
    try {
      await FirebaseFirestore.instance.collection("surat").doc(docId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Surat berhasil dihapus")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== TOMBOL BUAT SK =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const FormTambahSuratKeterangan(),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Buat SK",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          /// ===== TABEL DATA =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("surat")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Belum ada data surat"));
                  }

                  final docs = snapshot.data!.docs;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isSmallScreen = constraints.maxWidth < 700;

                      return SingleChildScrollView(
                        scrollDirection:
                            isSmallScreen ? Axis.horizontal : Axis.vertical,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth:
                                isSmallScreen ? 700 : constraints.maxWidth,
                          ),
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              Colors.amber,
                            ),
                            columnSpacing: screenWidth * 0.02,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 60,

                            /// ===== HEADER (DITAMBAH AKSI) =====
                            columns: const [
                              DataColumn(label: Text("No")),
                              DataColumn(label: Text("Jenis Surat")),
                              DataColumn(label: Text("Keperluan")),
                              DataColumn(label: Text("Tahun Ajaran")),
                              DataColumn(label: Text("Tanggal Pembuatan")),
                              DataColumn(label: Text("File")),
                              DataColumn(label: Text("Aksi")),
                            ],

                            /// ===== ROW DATA =====
                            rows: List.generate(docs.length, (index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;

                              final docId = docs[index].id;

                              return DataRow(
                                cells: [
                                  DataCell(Text("${index + 1}")),
                                  DataCell(Text(data["jenisSurat"] ?? "-")),
                                  DataCell(Text(data["keperluan"] ?? "-")),
                                  DataCell(Text(data["tahunAjaran"] ?? "-")),
                                  DataCell(
                                    Text(formatTanggal(data["createdAt"])),
                                  ),

                                  /// ===== PRINT =====
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await printUlangPdf(data);
                                      },
                                    ),
                                  ),

                                  /// ===== DELETE =====
                                  DataCell(
                                    IconButton(
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
                                                "Apakah kamu yakin ingin menghapus surat ini?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Batal"),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                  onPressed: () async {
                                                    Navigator.pop(
                                                      context,
                                                    ); // tutup dialog dulu
                                                    await deleteSurat(docId);
                                                  },
                                                  child: const Text(
                                                    "Hapus",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
