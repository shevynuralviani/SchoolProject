import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'tambah_kehadiran.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  void initState() {
    super.initState();
    loadUserData();
  }

  DateTime selectedDate = DateTime.now();

  String? selectedTahun;
  String? selectedKelas;
  String selectedBulan = "Januari";

  String userRole = "";
  String userKelas = "";

  // FIRESTORE
  final CollectionReference absensiCollection = FirebaseFirestore.instance
      .collection('absensi');

  // BULAN
  final List<String> bulanList = [
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

  // FORMAT TANGGAL
  String get formattedDate {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate);
  }

  // FORMAT FIRESTORE
  String get firestoreDate {
    return DateFormat('dd-MM-yyyy').format(selectedDate);
  }

  // AMBIL NOMOR BULAN
  int get selectedMonthIndex {
    return bulanList.indexOf(selectedBulan) + 1;
  }

  // PILIH TANGGAL
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// =========================
  /// LOAD USER LOGIN
  /// =========================
  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!doc.exists) return;

      final data = doc.data()!;

      setState(() {
        userRole = data['role']?.toString() ?? "";
        userKelas = data['kelas']?.toString() ?? "";

        // otomatis pilih kelas guru
        selectedKelas = userKelas;
      });
    } catch (e) {
      debugPrint("ERROR LOAD USER: $e");
    }
  }

  // POPUP
  void showTambahKehadiran() {
    showDialog(context: context, builder: (context) => const TambahKehadiran());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // SEARCH + KALENDER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari Nama Siswa...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                InkWell(
                  onTap: pickDate,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(formattedDate),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // TAHUN AJARAN
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('kelas')
                            .snapshots(),

                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      // LIST UNIQUE TAHUN PELAJARAN
                      List<String> tahunList = [];

                      for (var doc in docs) {
                        final data = doc.data() as Map<String, dynamic>? ?? {};

                        final tahun = data['tahun_pelajaran']?.toString() ?? '';

                        if (tahun.isNotEmpty && !tahunList.contains(tahun)) {
                          tahunList.add(tahun);
                        }
                      }

                      return DropdownButtonFormField<String>(
                        value:
                            tahunList.contains(selectedTahun)
                                ? selectedTahun
                                : null,

                        hint: const Text("Tahun Pelajaran"),

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        items:
                            tahunList.map((tahun) {
                              return DropdownMenuItem(
                                value: tahun,
                                child: Text(tahun),
                              );
                            }).toList(),

                        onChanged: (value) {
                          if (value == null) return;

                          final selectedDoc = docs.firstWhere((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};

                            return data['tahun_pelajaran'] == value;
                          });

                          final data =
                              selectedDoc.data() as Map<String, dynamic>? ?? {};

                          setState(() {
                            selectedTahun = value;

                            // AMBIL NAMA KELAS
                            selectedKelas =
                                data['nama_kelas']?.toString() ?? '-';
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: showTambahKehadiran,

                  icon: const Icon(Icons.add, color: Colors.white),

                  label: const Text(
                    "Tambah Kehadiran",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // INDIKATOR
            StreamBuilder<QuerySnapshot>(
              stream:
                  absensiCollection
                      .where('tanggal', isEqualTo: firestoreDate)
                      .where('kelas', isEqualTo: selectedKelas)
                      .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final docs = snapshot.data!.docs;

                int hadir = 0;
                int sakit = 0;
                int izin = 0;
                int alfa = 0;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};

                  switch (data['status']) {
                    case 'Hadir':
                      hadir++;
                      break;

                    case 'Sakit':
                      sakit++;
                      break;

                    case 'Izin':
                      izin++;
                      break;

                    case 'Alfa':
                      alfa++;
                      break;
                  }
                }

                return Row(
                  children: [
                    Expanded(child: statusCard("Hadir", hadir, Colors.green)),
                    const SizedBox(width: 6),

                    Expanded(child: statusCard("Izin", izin, Colors.orange)),
                    const SizedBox(width: 6),

                    Expanded(child: statusCard("Sakit", sakit, Colors.red)),
                    const SizedBox(width: 6),

                    Expanded(child: statusCard("Alfa", alfa, Colors.grey)),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),

            // HEADER
            tableHeader([
              "No",
              "Nama",
              "NIS",
              "Hadir",
              "Sakit",
              "Izin",
              "Alfa",
              "Keterangan",
            ]),

            // DATA HARIAN
            StreamBuilder<QuerySnapshot>(
              stream:
                  absensiCollection
                      .where('tanggal', isEqualTo: firestoreDate)
                      .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("Terjadi Error")),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text("Belum ada data absensi pada tanggal ini"),
                    ),
                  );
                }

                return Column(
                  children: List.generate(docs.length, (index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return Container(
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),

                      child: Row(
                        children: [
                          Expanded(child: Text("${index + 1}")),

                          Expanded(child: Text(data['nama'] ?? '-')),

                          Expanded(child: Text(data['nis'] ?? '-')),

                          Expanded(
                            child: Center(
                              child:
                                  data['status'] == 'Hadir'
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                      : const Text("-"),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child:
                                  data['status'] == 'Sakit'
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.red,
                                      )
                                      : const Text("-"),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child:
                                  data['status'] == 'Izin'
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.orange,
                                      )
                                      : const Text("-"),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child:
                                  data['status'] == 'Alfa'
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.grey,
                                      )
                                      : const Text("-"),
                            ),
                          ),

                          Expanded(child: Text(data['keterangan'] ?? '-')),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 20),

            // REKAP BULANAN
            Row(
              children: [
                const Text(
                  "Rekap Absensi Bulanan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedBulan,

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),

                    items:
                        bulanList
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedBulan = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: downloadPdfRekap,

                  icon: const Icon(Icons.download, color: Colors.white),

                  label: const Text(
                    "Unduh",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // HEADER REKAP
            tableHeader([
              "No",
              "Nama",
              "NIS",
              "Hadir",
              "Sakit",
              "Izin",
              "Alfa",
              "Total",
              "Persentase",
            ]),

            // DATA REKAP FIREBASE
            StreamBuilder<QuerySnapshot>(
              stream:
                  absensiCollection
                      .where('kelas', isEqualTo: selectedKelas)
                      .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.data!.docs;

                Map<String, Map<String, dynamic>> siswaMap = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  final tanggal = data['tanggal']?.toString() ?? '';

                  try {
                    final parsedDate = DateFormat('dd-MM-yyyy').parse(tanggal);

                    if (parsedDate.month != selectedMonthIndex) {
                      continue;
                    }

                    final nis = data['nis'] ?? '';
                    final nama = data['nama'] ?? '';
                    final status = data['status'] ?? '';

                    if (!siswaMap.containsKey(nis)) {
                      siswaMap[nis] = {
                        'nama': nama,
                        'nis': nis,
                        'hadir': 0,
                        'sakit': 0,
                        'izin': 0,
                        'alfa': 0,
                      };
                    }

                    switch (status) {
                      case 'Hadir':
                        siswaMap[nis]!['hadir']++;
                        break;

                      case 'Sakit':
                        siswaMap[nis]!['sakit']++;
                        break;

                      case 'Izin':
                        siswaMap[nis]!['izin']++;
                        break;

                      case 'Alfa':
                        siswaMap[nis]!['alfa']++;
                        break;
                    }
                  } catch (e) {}
                }

                final siswaList = siswaMap.values.toList();

                if (siswaList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("Belum ada rekap bulan ini")),
                  );
                }

                return Column(
                  children: List.generate(siswaList.length, (index) {
                    final data = siswaList[index];

                    final hadir = data['hadir'];
                    final sakit = data['sakit'];
                    final izin = data['izin'];
                    final alfa = data['alfa'];

                    final total = hadir + sakit + izin + alfa;

                    final persen =
                        total == 0
                            ? 0
                            : ((hadir / total) * 100).toStringAsFixed(1);

                    return Container(
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),

                      child: Row(
                        children: [
                          Expanded(child: Text("${index + 1}")),

                          Expanded(child: Text(data['nama'])),

                          Expanded(child: Text(data['nis'])),

                          Expanded(child: Text("$hadir")),

                          Expanded(child: Text("$sakit")),

                          Expanded(child: Text("$izin")),

                          Expanded(child: Text("$alfa")),

                          Expanded(child: Text("$total")),

                          Expanded(child: Text("$persen%")),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // STATUS CARD
  Widget statusCard(String title, int jumlah, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,

            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),

              Row(
                children: [
                  Text(
                    "$jumlah",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Text("siswa"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TABLE HEADER
  Widget tableHeader(List<String> titles) {
    return Container(
      color: Colors.amber,
      padding: const EdgeInsets.all(6),

      child: Row(
        children:
            titles
                .map(
                  (e) => Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  // download rekap absen
  Future<void> downloadPdfRekap() async {
    final pdf = pw.Document();

    final snapshot =
        await absensiCollection.where('kelas', isEqualTo: selectedKelas).get();

    final docs = snapshot.docs;

    Map<String, Map<String, dynamic>> siswaMap = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};

      final tanggal = data['tanggal']?.toString() ?? '';

      try {
        final parsedDate = DateFormat('dd-MM-yyyy').parse(tanggal);

        if (parsedDate.month != selectedMonthIndex) {
          continue;
        }

        final nis = data['nis']?.toString() ?? '';
        final nama = data['nama']?.toString() ?? '';
        final status = data['status']?.toString() ?? '';

        if (!siswaMap.containsKey(nis)) {
          siswaMap[nis] = {
            'nama': nama,
            'nis': nis,
            'hadir': 0,
            'sakit': 0,
            'izin': 0,
            'alfa': 0,
          };
        }

        switch (status) {
          case 'Hadir':
            siswaMap[nis]!['hadir']++;
            break;

          case 'Sakit':
            siswaMap[nis]!['sakit']++;
            break;

          case 'Izin':
            siswaMap[nis]!['izin']++;
            break;

          case 'Alfa':
            siswaMap[nis]!['alfa']++;
            break;
        }
      } catch (e) {}
    }

    // AMBIL DATA KEPALA SEKOLAH DARI COLLECTION GURU
    String namaKepsek = "-";

    try {
      final kepsekSnapshot =
          await FirebaseFirestore.instance
              .collection('guru')
              .where('jabatan', isEqualTo: 'Kepala Madrasah')
              .limit(1)
              .get();

      if (kepsekSnapshot.docs.isNotEmpty) {
        final data = kepsekSnapshot.docs.first.data() as Map<String, dynamic>;

        namaKepsek = data['nama_guru']?.toString() ?? "-";
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final siswaList = siswaMap.values.toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build:
            (context) => [
              // HEADER
              pw.Center(
                child: pw.Text(
                  "Data Rekap Absen Kelas ${selectedKelas ?? '-'}\n"
                  "Tahun Pelajaran ${selectedTahun ?? '-'}",
                  textAlign: pw.TextAlign.center,

                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              // TABEL
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),

                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.orange,
                ),

                cellAlignment: pw.Alignment.centerLeft,

                headers: [
                  "No",
                  "Nama",
                  "NIS",
                  "Hadir",
                  "Sakit",
                  "Izin",
                  "Alfa",
                  "Total",
                  "Persentase",
                ],

                data: List.generate(siswaList.length, (index) {
                  final data = siswaList[index];

                  final hadir = data['hadir'];
                  final sakit = data['sakit'];
                  final izin = data['izin'];
                  final alfa = data['alfa'];

                  final total = hadir + sakit + izin + alfa;

                  final persen =
                      total == 0
                          ? "0%"
                          : "${((hadir / total) * 100).toStringAsFixed(1)}%";

                  return [
                    "${index + 1}",
                    data['nama'],
                    data['nis'],
                    "$hadir",
                    "$sakit",
                    "$izin",
                    "$alfa",
                    "$total",
                    persen,
                  ];
                }),
              ),

              pw.SizedBox(height: 50),

              // TTD
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,

                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,

                    children: [
                      pw.Text(
                        "Batam, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}",
                      ),

                      pw.SizedBox(height: 10),

                      pw.Text("Kepala Sekolah"),

                      pw.SizedBox(height: 60),

                      pw.Text(
                        namaKepsek,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
