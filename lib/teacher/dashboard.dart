import 'package:flutter/material.dart';

import 'sidebar_teacher.dart';
import 'teacher_menu.dart';

import 'data_siswa.dart';
import 'vidio.dart';
import 'akun_saya.dart';
import 'surat_keterangan.dart';
import 'absen_siswa.dart';

class DashboardTeacherPage extends StatefulWidget {
  const DashboardTeacherPage({super.key});

  @override
  State<DashboardTeacherPage> createState() => _DashboardTeacherPageState();
}

class _DashboardTeacherPageState extends State<DashboardTeacherPage> {
  bool _isSidebarVisible = true;
  final TeacherMenuController _menuController = TeacherMenuController();

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
          // ===== JUDUL =====
          Text(
            _getTitle(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          // ===== MENU AKUN =====
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
      case TeacherMenu.video:
        return "Video Edukasi";
      case TeacherMenu.akunsaya:
        return "Akun Saya";
      case TeacherMenu.suratIzin:
        return "Pengajuan Surat Keterangan";
      case TeacherMenu.absen:
        return "Absensi Siswa Siswi";
      case TeacherMenu.beranda:
      default:
        return "Beranda";
    }
  }

  // ================= BUILD CONTENT (KUNCI UTAMA) =================
  Widget _buildContent() {
    switch (_menuController.activeMenu) {
      case TeacherMenu.dataSiswa:
        return const DataSiswaPage();

      case TeacherMenu.video:
        return const VideoGalleryTeacher();

      case TeacherMenu.akunsaya:
        return const AkunGuruPage();

      case TeacherMenu.suratIzin:
        return const SuratKeteranganPage();

      case TeacherMenu.absen:
        return const AbsensiPage();

      case TeacherMenu.beranda:
      default:
        return _dashboardHome();
    }
  }

  // ================= DASHBOARD HOME =================
  Widget _dashboardHome() {
    return Column(
      children: [
        // ===== HEADER =====
        Container(
          width: double.infinity,
          color: Colors.amber,
          padding: const EdgeInsets.all(16),
          child: const Text(
            "Selamat Datang Di Sistem Informasi MI Raudatul Qur'an",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ===== CARD MENU =====
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _dashboardCard(Icons.calendar_month, "Kalender Akademik"),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _menuController.setMenu(TeacherMenu.video);
                    });
                  },
                  child: _dashboardCard(Icons.video_library, "Video Edukasi"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= DASHBOARD CARD =================
  Widget _dashboardCard(IconData icon, String title, {bool wide = false}) {
    return Container(
      width: wide ? 420 : 260,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
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
