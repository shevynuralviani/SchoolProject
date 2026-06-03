import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddVideoGuru extends StatefulWidget {
  final VoidCallback onClose;

  /// UBAH DI SINI (String → Map)
  final Function(Map<String, dynamic>) onUploaded;

  const AddVideoGuru({
    super.key,
    required this.onClose,
    required this.onUploaded,
  });

  @override
  State<AddVideoGuru> createState() => _AddVideoGuruState();
}

class _AddVideoGuruState extends State<AddVideoGuru>
    with SingleTickerProviderStateMixin {
  String? selectedFile;
  final TextEditingController linkController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    linkController.dispose();
    super.dispose();
  }

  void pickVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.single.name;

        /// kosongkan link kalau pilih file
        linkController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(5, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pilih Upload File atau Masukkan Link Video",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// ================= UPLOAD FILE =================
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Upload File",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: pickVideoFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(selectedFile ?? "Choose File"),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= LINK VIDEO =================
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Link Video",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: linkController,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => selectedFile = null);
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Masukkan Link Video",
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: widget.onClose,
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),

                /// ================= UPLOAD BUTTON =================
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    final hasil = selectedFile ?? linkController.text.trim();

                    if (hasil.isNotEmpty) {
                      widget.onUploaded({
                        "title": selectedFile ?? "Video dari Link",
                        "url": hasil,
                        "uploadedBy": "Guru",
                        "role": "Guru",
                      });
                    }
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
    );
  }
}
