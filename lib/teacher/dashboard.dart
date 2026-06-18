import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sidebar_teacher.dart';
import 'teacher_menu.dart';

import 'data_siswa.dart';
import 'akun_saya.dart';

class DashboardTeacherPage extends StatefulWidget {
  const DashboardTeacherPage({super.key});

  @override
  State<DashboardTeacherPage> createState() => _DashboardTeacherPageState();
}

class _DashboardTeacherPageState extends State<DashboardTeacherPage> {
  bool _isSidebarVisible = true;
  final TeacherMenuController _menuController = TeacherMenuController();

  String? _kelasGuru;

  @override
  void initState() {
    super.initState();
    _loadGuru();
  }

  // ================= AMBIL DATA GURU LOGIN =================
  Future<void> _loadGuru() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) return;

    setState(() {
      _kelasGuru = doc['nama_kelas'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // ================= SIDEBAR =================
          SidebarTeacher(
            isVisible: _isSidebarVisible,
            onToggle: () {
              setState(() {
                _isSidebarVisible = !_isSidebarVisible;
              });
            },
            menuController: _menuController,
            onMenuChanged: (_) {
              setState(() {});
            },
          ),

          // ================= CONTENT =================
          Expanded(
            child: Column(
              children: [_appBar(), Expanded(child: _buildContent())],
            ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  Widget _appBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getTitle(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 'akun') {
                setState(() {
                  _menuController.setMenu(TeacherMenu.akunsaya);
                });
              } else if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'akun', child: Text("Akun Saya")),
                  PopupMenuItem(
                    value: 'logout',
                    child: Text("Logout", style: TextStyle(color: Colors.red)),
                  ),
                ],
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TITLE =================
  String _getTitle() {
    switch (_menuController.activeMenu) {
      case TeacherMenu.dataSiswa:
        return "Data Siswa";
      case TeacherMenu.akunsaya:
        return "Akun Saya";
      case TeacherMenu.beranda:
      default:
        return "Beranda";
    }
  }

  // ================= CONTENT =================
  Widget _buildContent() {
    switch (_menuController.activeMenu) {
      case TeacherMenu.dataSiswa:
        return const DataSiswaPage();

      case TeacherMenu.akunsaya:
        return const AkunGuruPage();

      case TeacherMenu.beranda:
      default:
        return _dashboardHome();
    }
  }

  // ================= DASHBOARD HOME =================
  Widget _dashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Selamat Datang Di Sistem Informasi MI Raudatul Qur'an",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ================= STATISTIK =================
          Row(
            children: [
              Expanded(child: _jumlahSiswaGuruCard()),
              const SizedBox(width: 16),
              Expanded(child: _jumlahPengumumanCard()),
            ],
          ),

          const SizedBox(height: 20),

          // ================= PENGUMUMAN =================
          _pengumumanTerbaru(),
          const SizedBox(height: 20),
          _pengumumanTersedia(),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green, size: 35),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Gunakan menu Data Siswa untuk melihat data siswa kelas Anda.",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pengumumanTerbaru() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pengumuman')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pengumuman Terbaru",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              if (docs.isEmpty) const Text("Belum ada pengumuman"),

              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final judul =
                    (data['deskripsi'] ?? '').toString().isEmpty
                        ? '(Tanpa Judul)'
                        : data['deskripsi'].toString();

                final date = (data['createdAt'] as Timestamp?)?.toDate();

                final tanggal =
                    date != null
                        ? DateFormat('dd MMM yyyy - HH:mm').format(date)
                        : '-';

                return ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: Colors.orange,
                  ),
                  title: Text(judul),
                  subtitle: Text(tanggal),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _pengumumanTersedia() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pengumuman')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pengumuman Tersedia",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              if (docs.isEmpty) const Text("Belum ada pengumuman"),

              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final judul =
                    (data['deskripsi'] ?? '').toString().isEmpty
                        ? '(Tanpa Judul)'
                        : data['deskripsi'].toString();

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.campaign),
                    title: Text(judul),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  // ================= JUMLAH SISWA SESUAI KELAS GURU =================
  Widget _jumlahSiswaGuruCard() {
    if (_kelasGuru == null) {
      return _dashboardCard(Icons.people, "Jumlah Siswa\n0");
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('siswa')
              .where('nama_kelas', isEqualTo: _kelasGuru)
              .snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return _dashboardCard(Icons.people, "Jumlah Siswa\n$total");
      },
    );
  }

  // ================= JUMLAH PENGUMUMAN =================
  Widget _jumlahPengumumanCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pengumuman').snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return _dashboardCard(Icons.campaign, "Pengumuman\n$total");
      },
    );
  }

  // ================= CARD =================
  Widget _dashboardCard(IconData icon, String title) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
