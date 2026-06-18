import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'dart:html' as html;

Future<Uint8List> generatePdfFromData(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  /// LOAD LOGO
  final logoKiri = await rootBundle.load('images/logo_madrasah.jpeg');
  final logoKanan = await rootBundle.load('images/logo_kemenag.jpeg');

  final imageKiri = pw.MemoryImage(logoKiri.buffer.asUint8List());
  final imageKanan = pw.MemoryImage(logoKanan.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      build:
          (context) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                /// ===== KOP SURAT & LOGO =====
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(imageKiri),
                    ),

                    pw.SizedBox(width: 5),

                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            "LEMBAGA PENDIDIKAN RAUDLATUL QUR'AN BATAM",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                          pw.Text(
                            "MADRASAH IBTIDAIYAH RAUDLATUL QUR'AN",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "Nomor Pokok Sekolah Nasional (NPSN) : 60706116",
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            "Nomor Statistik Madrasah (NSM) : 111221710009",
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            "TERAKREDITASI : A",
                            textAlign: pw.TextAlign.center,
                          ),

                          pw.SizedBox(height: 4),

                          pw.Text(
                            "Jl. Bida Ayu Pintu 1 Blok S No.153, Mangsang, Sei Beduk, Kota Batam",
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            "Website: https://raudlatulquranbatam.sch.id | No HP: 0853-3833-9347",
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 5),

                    pw.Container(
                      width: 60,
                      height: 60,
                      child: pw.Image(imageKanan),
                    ),
                  ],
                ),

                /// ===== GARIS ATAS (FULL WIDTH) =====
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  height: 2,
                  color: PdfColors.black,
                ),

                /// ===== GARIS BAWAH (FULL WIDTH) =====
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  height: 2,
                  color: PdfColors.black,
                ),

                pw.SizedBox(height: 20),

                /// ===== JUDUL =====
                pw.Center(
                  child: pw.Text(
                    "SURAT KETERANGAN",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text("Nomor : ${data["nomorSurat"] ?? "-"}"),
                pw.SizedBox(height: 16),

                pw.Text("Yang bertanda tangan di bawah ini menerangkan bahwa:"),

                pw.SizedBox(height: 12),

                pw.Text("Nama : ${data["nama"] ?? "-"}"),
                pw.Text("NISN : ${data["nisn"] ?? "-"}"),
                pw.Text("Kelas : ${data["nama_kelas"] ?? "-"}"),
                pw.Text("TTL : ${data["ttl"] ?? "-"}"),
                pw.Text("Jenis Kelamin : ${data["jenis_kelamin"] ?? "-"}"),
                pw.Text("Alamat : ${data["alamat"] ?? "-"}"),

                pw.SizedBox(height: 16),

                pw.Text(
                  "Adalah benar siswa kami yang masih aktif pada tahun ajaran ${data["tahunAjaran"] ?? "-"}.",
                ),

                pw.SizedBox(height: 12),

                pw.Text("Surat ini dibuat untuk keperluan:"),
                pw.Text(data["keperluan"] ?? "-"),

                pw.SizedBox(height: 40),

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "Batam, ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                      ),
                      pw.SizedBox(height: 40),
                      pw.Text("Kepala Sekolah"),
                    ],
                  ),
                ),
              ],
            ),
          ),
    ),
  );

  return pdf.save();
}

class FormTambahSuratKeterangan extends StatefulWidget {
  const FormTambahSuratKeterangan({super.key});

  @override
  State<FormTambahSuratKeterangan> createState() =>
      _FormTambahSuratKeteranganState();
}

class _FormTambahSuratKeteranganState extends State<FormTambahSuratKeterangan> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final nisnController = TextEditingController();
  final kelasController = TextEditingController();
  final ttlController = TextEditingController();
  final jenisKelaminController = TextEditingController();
  final alamatController = TextEditingController();
  final nomorSuratController = TextEditingController();
  final keperluanController = TextEditingController();
  final tahunAjaranController = TextEditingController();

  String? jenisSurat;

  /// ================= AUTO FILL =================
  Future<void> autoFillFromFirestore(String nama) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("siswa")
            .where("nama", isEqualTo: nama)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();

      nisnController.text = data["nisn"] ?? "";
      kelasController.text = data["nama_kelas"] ?? "";
      jenisKelaminController.text = data["jenis_kelamin"] ?? "";
      alamatController.text = data["alamat"] ?? "";
      ttlController.text = "${data["tempat_lahir"]}, ${data["tanggal_lahir"]}";
    }
  }

  /// ================= SEARCH =================
  Future<List<String>> searchSiswa(String query) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("siswa")
            .orderBy("nama")
            .startAt([query])
            .endAt([query + '\uf8ff'])
            .limit(5)
            .get();

    return snapshot.docs.map((e) => e["nama"].toString()).toList();
  }

  /// ================= PRINT (WEB) =================
  void printPdf(Uint8List bytes) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    /// buka tab baru + auto print
    html.window.open(url, "_blank");
  }

  /// ================= SIMPAN =================
  Future<void> simpanData() async {
    try {
      final dataSurat = {
        "nama": namaController.text,
        "nisn": nisnController.text,
        "nama_kelas": kelasController.text,
        "ttl": ttlController.text,
        "jenis_kelamin": jenisKelaminController.text,
        "alamat": alamatController.text,
        "nomorSurat": nomorSuratController.text,
        "keperluan": keperluanController.text,
        "tahunAjaran": tahunAjaranController.text,
        "jenisSurat": jenisSurat,
      };

      /// GENERATE PDF DARI MAP
      final pdfData = await generatePdfFromData(dataSurat);

      /// PRINT
      printPdf(pdfData);

      /// SIMPAN KE FIRESTORE
      await FirebaseFirestore.instance.collection("surat").add({
        ...dataSurat,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Surat berhasil dibuat & siap print")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// ================= UI (TIDAK DIUBAH) =================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: isMobile ? double.infinity : 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Buat Surat Keterangan",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        isMobile
                            ? constraints.maxWidth
                            : (constraints.maxWidth / 2) - 12;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: width,
                          child: Autocomplete<String>(
                            optionsBuilder: (textEditingValue) async {
                              return await searchSiswa(textEditingValue.text);
                            },
                            onSelected: (value) async {
                              namaController.text = value;
                              await autoFillFromFirestore(value);
                            },
                            fieldViewBuilder: (
                              context,
                              controller,
                              focusNode,
                              _,
                            ) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: "Nama Siswa",
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                        ),

                        _field("NISN", nisnController, width),
                        _field("Kelas", kelasController, width),
                        _field("Tempat, Tgl Lahir", ttlController, width),
                        _field("Jenis Kelamin", jenisKelaminController, width),
                        _field("Alamat", alamatController, width),
                        _field("Nomor Surat", nomorSuratController, width),
                        _field("Tahun Ajaran", tahunAjaranController, width),

                        _dropdown(
                          "Jenis Surat",
                          [
                            "Surat Keterangan Aktif Belajar",
                            "Surat Keterangan Berkelakuan Baik",
                          ],
                          jenisSurat,
                          (v) => setState(() => jenisSurat = v),
                          width,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: keperluanController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: "Keperluan",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          simpanData();
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
      ),
    );
  }

  Widget _field(String label, TextEditingController c, double width) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
