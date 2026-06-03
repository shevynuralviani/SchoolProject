import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_vidio.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoGalleryTeacher extends StatefulWidget {
  const VideoGalleryTeacher({super.key});

  @override
  State<VideoGalleryTeacher> createState() => _VideoGalleryTeacherState();
}

class _VideoGalleryTeacherState extends State<VideoGalleryTeacher> {
  final TextEditingController _searchController = TextEditingController();

  bool showAddVideoTeacher = false;

  /// ================= DELETE VIDEO =================
  void _deleteVideo(String id) async {
    await FirebaseFirestore.instance.collection('videos').doc(id).delete();
  }

  /// ================= AMBIL ID YOUTUBE =================
  String getYoutubeId(String url) {
    Uri uri = Uri.parse(url);

    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v']!;
    } else if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return "";
  }

  /// ================= PLAY VIDEO =================
  void playVideo(String url) {
    final videoId = getYoutubeId(url);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            width: 800,
            height: 450,
            child: Builder(
              builder: (context) {
                final controller =
                    WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(
                        Uri.parse(
                          "https://www.youtube.com/embed/$videoId?autoplay=1",
                        ),
                      );

                return WebViewWidget(controller: controller);
              },
            ),
          ),
        );
      },
    );
  }

  /// ================= KONFIRMASI HAPUS =================
  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Hapus Video"),
            content: const Text("Yakin ingin menghapus video ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () {
                  _deleteVideo(id);
                  Navigator.pop(context);
                },
                child: const Text("Hapus"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// ================= CONTENT =================
        Column(
          children: [
            /// ===== APP BAR =====
            PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            /// ================= SEARCH & ADD =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Cari Video",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() => showAddVideoTeacher = true);
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// ================= GRID VIDEO =================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('videos')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Belum ada video"));
                  }

                  final docs = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      final url = data["url"] ?? "";
                      final videoId = getYoutubeId(url);

                      final thumbnail =
                          "https://img.youtube.com/vi/$videoId/0.jpg";

                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => playVideo(url),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image:
                                    videoId.isNotEmpty
                                        ? DecorationImage(
                                          image: NetworkImage(thumbnail),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                                color: Colors.grey[300],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black26,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          /// ===== HAPUS =====
                          Positioned(
                            top: 6,
                            right: 6,
                            child: PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (_) => confirmDelete(docs[index].id),
                              itemBuilder:
                                  (_) => const [
                                    PopupMenuItem(
                                      value: "hapus",
                                      child: Text("Hapus"),
                                    ),
                                  ],
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
        ),

        /// ================= POPUP ADD VIDEO =================
        if (showAddVideoTeacher)
          Center(
            child: AddVideoGuru(
              onClose: () => setState(() => showAddVideoTeacher = false),
              onUploaded: (val) async {
                await FirebaseFirestore.instance.collection('videos').add({
                  "title": val["title"],
                  "url": val["url"],
                  "uploadedBy": "guru",
                  "role": "guru",
                  "createdAt": FieldValue.serverTimestamp(),
                });

                setState(() {
                  showAddVideoTeacher = false;
                });
              },
            ),
          ),
      ],
    );
  }
}
