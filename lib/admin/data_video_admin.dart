import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_video_admin.dart';

class VideoGalleryContent extends StatefulWidget {
  const VideoGalleryContent({super.key});

  @override
  State<VideoGalleryContent> createState() => _VideoGalleryContentState();
}

class _VideoGalleryContentState extends State<VideoGalleryContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchText = "";

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  /// ================= BUKA YOUTUBE =================
  Future<void> openYoutube(String url) async {
    final Uri youtube = Uri.parse(url);
    await launchUrl(youtube, mode: LaunchMode.externalApplication);
  }

  /// ================= DIALOG EDIT =================
  void showEditDialog(String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data["title"] ?? "");
    final linkController = TextEditingController(text: data["url"] ?? "");

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Video",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Judul Video",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: "Link YouTube",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),

                    const SizedBox(width: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        await _firestore.collection("videos").doc(docId).update(
                          {
                            "title": titleController.text,
                            "url": linkController.text,
                          },
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Video berhasil diupdate"),
                          ),
                        );
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
        );
      },
    );
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
                  hintText: "Cari Judul Video...",
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
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      return AddVideoAdmin(
                        onClose: () {
                          Navigator.of(dialogContext).pop();
                        },
                        onUploaded: (data) async {
                          await FirebaseFirestore.instance
                              .collection("videos")
                              .add({
                                "title": data["title"],
                                "url": data["url"],
                                "createdAt": FieldValue.serverTimestamp(),
                                "uploadedBy": data["uploadedBy"],
                                "role": data["role"],
                              });

                          Navigator.of(dialogContext).pop();
                        },
                      );
                    },
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
                    width: 900,
                    child: Column(
                      children: [
                        /// HEADER
                        Container(
                          color: const Color(0xFFFFD700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Row(
                            children: [
                              _Header("No"),
                              _Header("Judul Video"),
                              _Header("Link Video"),
                              _Header("Tanggal Upload"),
                              _Header("Pengunggah"),
                              _Header("Aksi"),
                            ],
                          ),
                        ),

                        /// DATA
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream:
                                _firestore
                                    .collection("videos")
                                    .orderBy("createdAt", descending: true)
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
                                    final title =
                                        (data["title"] ?? "")
                                            .toString()
                                            .toLowerCase();

                                    return title.contains(
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

                                    String tanggal = "-";

                                    if (data["createdAt"] != null) {
                                      final t =
                                          (data["createdAt"] as Timestamp)
                                              .toDate();

                                      tanggal = "${t.day}/${t.month}/${t.year}";
                                    }

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
                                          _Cell(data["title"] ?? "-"),

                                          /// LINK
                                          SizedBox(
                                            width: 140,
                                            child: InkWell(
                                              onTap:
                                                  () => openYoutube(
                                                    data["url"] ?? "",
                                                  ),
                                              child: const Text(
                                                "Buka Video",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),

                                          _Cell(tanggal),

                                          _Cell(
                                            "${data["uploadedBy"] ?? "-"} (${data["role"] ?? ""})",
                                          ),

                                          _ActionCell(
                                            onEdit: () {
                                              showEditDialog(doc.id, data);
                                            },
                                            onDelete: () async {
                                              await _firestore
                                                  .collection("videos")
                                                  .doc(doc.id)
                                                  .delete();
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
