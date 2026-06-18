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

              const SizedBox(height: 40),

              const Divider(),

              const SizedBox(height: 20),

              const Text(
                "Daftar Pengumuman",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection("pengumuman")
                          .orderBy("createdAt", descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Belum ada pengumuman"));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        String tanggal = "-";

                        if (data["tanggal"] != null) {
                          final tgl = (data["tanggal"] as Timestamp).toDate();

                          tanggal = "${tgl.day}-${tgl.month}-${tgl.year}";
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              tanggal,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(data["deskripsi"] ?? ""),
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final konfirmasi = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Hapus Pengumuman"),
                                      content: const Text(
                                        "Yakin ingin menghapus pengumuman ini?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text("Batal"),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, true);
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

                                if (konfirmasi == true) {
                                  await FirebaseFirestore.instance
                                      .collection("pengumuman")
                                      .doc(doc.id)
                                      .delete();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Pengumuman berhasil dihapus",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
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
      ),
    );
  }
}
