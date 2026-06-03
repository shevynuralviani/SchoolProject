import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PengumumanAdminPage extends StatefulWidget {
  const PengumumanAdminPage({super.key});

  @override
  State<PengumumanAdminPage> createState() => _PengumumanAdminPageState();
}

class _PengumumanAdminPageState extends State<PengumumanAdminPage> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  DateTime? selectedDate;

  // ================= PILIH TANGGAL =================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _tanggalController.text =
            "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  // ================= UPLOAD PENGUMUMAN =================
  Future<void> _uploadPengumuman() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Silakan pilih tanggal")));
      return;
    }

    if (_deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deskripsi tidak boleh kosong")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("pengumuman").add({
        "tanggal": Timestamp.fromDate(selectedDate!),
        "deskripsi": _deskripsiController.text.trim(),
        "createdAt": Timestamp.now(),
      });

      _tanggalController.clear();
      _deskripsiController.clear();
      selectedDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengumuman berhasil diunggah!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload: $e")));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Formulir Pengumuman",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // ================= TANGGAL =================
              const Text(
                "Tanggal",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: 300,
                child: TextField(
                  controller: _tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Masukkan Tanggal",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= DESKRIPSI =================
              const Text(
                "Deskripsi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: 500,
                child: TextField(
                  controller: _deskripsiController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Tulis pengumuman di sini",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ================= BUTTON =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),

                    onPressed: () {
                      _tanggalController.clear();
                      _deskripsiController.clear();
                      selectedDate = null;
                    },

                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),

                    onPressed: () {
                      _uploadPengumuman();
                    },

                    child: const Text(
                      "Unggah",
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
