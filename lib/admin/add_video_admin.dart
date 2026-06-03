import 'package:flutter/material.dart';

class AddVideoAdmin extends StatefulWidget {
  final VoidCallback onClose;

  /// UBAH KE dynamic
  final Function(Map<String, dynamic>) onUploaded;

  const AddVideoAdmin({
    super.key,
    required this.onClose,
    required this.onUploaded,
  });

  @override
  State<AddVideoAdmin> createState() => _AddVideoAdminState();
}

class _AddVideoAdminState extends State<AddVideoAdmin>
    with SingleTickerProviderStateMixin {
  final TextEditingController titleController = TextEditingController();
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
    titleController.dispose();
    linkController.dispose();
    super.dispose();
  }

  /// VALIDASI YOUTUBE
  bool isValidYoutubeUrl(String url) {
    return url.contains("youtube.com") || url.contains("youtu.be");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.scale(scale: _scale.value, child: child),
          );
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tambah Video YouTube",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  /// ================= JUDUL =================
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Judul Video",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= LINK =================
                  TextField(
                    controller: linkController,
                    decoration: const InputDecoration(
                      labelText: "Link YouTube",
                      border: OutlineInputBorder(),
                      hintText: "https://www.youtube.com/watch?v=xxxx",
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ================= BUTTON =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: widget.onClose,
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
                          final title = titleController.text.trim();
                          final url = linkController.text.trim();

                          if (title.isEmpty || url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Judul dan Link wajib diisi"),
                              ),
                            );
                            return;
                          }

                          if (!isValidYoutubeUrl(url)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Link harus dari YouTube"),
                              ),
                            );
                            return;
                          }

                          /// 🔥 KIRIM DATA LENGKAP
                          widget.onUploaded({
                            "title": title,
                            "url": url,
                            "role": "Admin",
                            "uploadedBy": "Admin",
                          });

                          Navigator.pop(context);
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
      ),
    );
  }
}
