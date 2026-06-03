import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahKehadiran extends StatefulWidget {
  const TambahKehadiran({super.key});

  @override
  State<TambahKehadiran> createState() => _TambahKehadiranState();
}

class _TambahKehadiranState extends State<TambahKehadiran> {
  // FIRESTORE
  final CollectionReference siswaCollection = FirebaseFirestore.instance
      .collection('siswa');

  final CollectionReference absensiCollection = FirebaseFirestore.instance
      .collection('absensi');

  // USER LOGIN
  String userKelas = "";
  String userRole = "";

  bool isLoadingUser = true;

  // STATUS PER SISWA
  Map<String, String> statusSiswa = {};

  // KETERANGAN PER SISWA
  Map<String, TextEditingController> keteranganController = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    for (var controller in keteranganController.values) {
      controller.dispose();
    }

    super.dispose();
  }

  /// LOAD USER LOGIN
  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          isLoadingUser = false;
        });
        return;
      }

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!doc.exists) {
        setState(() {
          isLoadingUser = false;
        });
        return;
      }

      final data = doc.data()!;

      setState(() {
        userRole = data['role']?.toString() ?? "";
        userKelas = data['nama_kelas']?.toString() ?? "";
        isLoadingUser = false;
      });
    } catch (e) {
      debugPrint("ERROR LOAD USER: $e");

      setState(() {
        isLoadingUser = false;
      });
    }
  }

  /// SIMPAN ABSENSI
  Future<void> simpanAbsensi({
    required String nama,
    required String nis,
    required String kelas,
    required String status,
    required String keterangan,
  }) async {
    try {
      final tanggal = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // CEK DUPLIKAT ABSENSI
      final check =
          await absensiCollection
              .where('nis', isEqualTo: nis)
              .where('tanggal', isEqualTo: tanggal)
              .get();

      // JIKA SUDAH ADA ABSENSI HARI INI
      if (check.docs.isNotEmpty) {
        return;
      }

      await absensiCollection.add({
        'nama': nama,
        'nis': nis,
        'nama_kelas': kelas,
        'status': status,
        'keterangan': keterangan,
        'tanggal': tanggal,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("ERROR SIMPAN ABSENSI: $e");
    }
  }

  Widget radioStatus(
    String currentStatus,
    String value,
    Color color,
    Function(String) onChanged,
  ) {
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },

      child: Container(
        width: 22,
        height: 22,

        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),

        child:
            currentStatus == value
                ? Center(
                  child: Container(
                    width: 12,
                    height: 12,

                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                : null,
      ),
    );
  }

  Widget tableCell(Widget child, {double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),

      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,

        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),

        child: child,
      ),
    );
  }

  Widget tableHeader(List<String> titles) {
    return Container(
      color: Colors.amber,

      child: Row(
        children:
            titles
                .map(
                  (e) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,

                      child: Text(
                        e,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Container(
        width: 900,
        padding: const EdgeInsets.all(12),

        child:
            isLoadingUser
                ? const SizedBox(
                  height: 300,

                  child: Center(child: CircularProgressIndicator()),
                )
                : userKelas.isEmpty
                ? const SizedBox(
                  height: 300,

                  child: Center(child: Text('Kelas guru tidak ditemukan')),
                )
                : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // TITLE
                      Text(
                        "Tambah Kehadiran Kelas $userKelas",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // HEADER TABLE
                      tableHeader([
                        "No",
                        "Nama",
                        "NIS",
                        "Hadir",
                        "Sakit",
                        "Izin",
                        "Alfa",
                        "Ket",
                      ]),

                      // DATA SISWA
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            siswaCollection
                                .where(
                                  'nama_kelas',
                                  isEqualTo: userKelas.trim(),
                                )
                                .snapshots(),

                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("Terjadi Error"),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            );
                          }

                          final siswaDocs = snapshot.data!.docs;

                          if (siswaDocs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("Data siswa kosong"),
                            );
                          }

                          return Column(
                            children: List.generate(siswaDocs.length, (index) {
                              final data =
                                  siswaDocs[index].data()
                                      as Map<String, dynamic>;

                              String siswaId = siswaDocs[index].id;

                              // DEFAULT STATUS
                              statusSiswa.putIfAbsent(siswaId, () => "Hadir");

                              // DEFAULT CONTROLLER
                              keteranganController.putIfAbsent(
                                siswaId,
                                () => TextEditingController(),
                              );

                              return Row(
                                children: [
                                  tableCell(Text("${index + 1}")),

                                  tableCell(Text(data['nama'] ?? '-')),

                                  tableCell(Text(data['nis'] ?? '-')),

                                  // HADIR
                                  tableCell(
                                    radioStatus(
                                      statusSiswa[siswaId]!,
                                      "Hadir",
                                      Colors.green,
                                      (value) {
                                        setState(() {
                                          statusSiswa[siswaId] = value;
                                        });
                                      },
                                    ),
                                  ),

                                  // SAKIT
                                  tableCell(
                                    radioStatus(
                                      statusSiswa[siswaId]!,
                                      "Sakit",
                                      Colors.red,
                                      (value) {
                                        setState(() {
                                          statusSiswa[siswaId] = value;
                                        });
                                      },
                                    ),
                                  ),

                                  // IZIN
                                  tableCell(
                                    radioStatus(
                                      statusSiswa[siswaId]!,
                                      "Izin",
                                      Colors.orange,
                                      (value) {
                                        setState(() {
                                          statusSiswa[siswaId] = value;
                                        });
                                      },
                                    ),
                                  ),

                                  // ALFA
                                  tableCell(
                                    radioStatus(
                                      statusSiswa[siswaId]!,
                                      "Alfa",
                                      Colors.grey,
                                      (value) {
                                        setState(() {
                                          statusSiswa[siswaId] = value;
                                        });
                                      },
                                    ),
                                  ),

                                  // KETERANGAN
                                  tableCell(
                                    TextField(
                                      controller: keteranganController[siswaId],

                                      decoration: const InputDecoration(
                                        hintText: "Keterangan",
                                        border: InputBorder.none,
                                        isDense: true,

                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),

                            onPressed: () => Navigator.pop(context),

                            child: const Text(
                              "Batal",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),

                            onPressed: () async {
                              try {
                                final siswaSnapshot =
                                    await siswaCollection
                                        .where(
                                          'nama_kelas',
                                          isEqualTo: userKelas,
                                        )
                                        .get();

                                for (var siswa in siswaSnapshot.docs) {
                                  final data =
                                      siswa.data() as Map<String, dynamic>;

                                  String siswaId = siswa.id;

                                  await simpanAbsensi(
                                    nama: data['nama'] ?? '',
                                    nis: data['nis'] ?? '',
                                    kelas:
                                        data['nama_kelas']?.toString().trim() ??
                                        '',
                                    status: statusSiswa[siswaId] ?? 'Hadir',
                                    keterangan:
                                        keteranganController[siswaId]?.text ??
                                        '',
                                  );
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Absensi berhasil disimpan',
                                      ),
                                    ),
                                  );

                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                debugPrint(e.toString());

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Gagal menyimpan absensi: $e',
                                    ),
                                  ),
                                );
                              }
                            },

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
      ),
    );
  }
}
