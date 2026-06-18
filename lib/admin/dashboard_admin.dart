import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_schoolproject/admin/surat.dart';

import 'sidebar_admin.dart';
import 'admin_menu.dart';
import 'datasiswa_admin.dart';
import 'data_alumni_admin.dart';
import 'master_kelas_page.dart';
import 'manajemen_user_admin.dart';
import 'pengumuman_admin.dart';
import 'daftar_guru.dart';
import 'akun_saya.dart';
import 'data_master.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  bool _isSidebarVisible = true;
  final AdminMenuController _menuController = AdminMenuController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          SidebarAdmin(
            isVisible: _isSidebarVisible,
            onToggle: () {
              setState(() {
                _isSidebarVisible = !_isSidebarVisible;
              });
            },
            menuController: _menuController,
          ),

          Expanded(
            child: Column(
              children: [
                _appBar(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _menuController,
                    builder: (context, _) => _buildContent(),
                  ),
                ),
              ],
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 'akun') {
                _menuController.setMenu(AdminMenu.akunsaya);
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

  // ================= JUDUL App Bar =================
  String _getTitle() {
    switch (_menuController.activeMenu) {
      case AdminMenu.dataMaster:
        return "Data Utama";
      case AdminMenu.dataSiswa:
        return "Data Siswa";
      case AdminMenu.dataKelas:
        return "Data Kelas";
      case AdminMenu.daftarGuru:
        return "Daftar Guru";
      case AdminMenu.dataAlumni:
        return "Data Alumni";
      case AdminMenu.suratKeterangan:
        return "Surat Keterangan";
      case AdminMenu.manajemenUser:
        return "Manajemen User";
      case AdminMenu.pengumuman:
        return "Pengumuman";
      case AdminMenu.akunsaya:
        return "Akun Saya";
      case AdminMenu.beranda:
      default:
        return "Beranda Admin";
    }
  }

  // ================= KONTEN =================
  Widget _buildContent() {
    switch (_menuController.activeMenu) {
      case AdminMenu.dataMaster:
        return DataMasterPage(menuController: _menuController);
      case AdminMenu.dataSiswa:
        return const DataSiswaAdminContent();
      case AdminMenu.dataKelas:
        return const MasterKelasPage();
      case AdminMenu.daftarGuru:
        return const DataGuruAdminContent();
      case AdminMenu.dataAlumni:
        return const DataAlumniAdmin();
      case AdminMenu.suratKeterangan:
        return const SuratKeteranganPage();
      case AdminMenu.manajemenUser:
        return const ManajemenUserAdmin();
      case AdminMenu.pengumuman:
        return const PengumumanAdminPage();
      case AdminMenu.akunsaya:
        return const AkunAdminPage();
      case AdminMenu.beranda:
      default:
        return _dashboardHome();
    }
  }

  // ================= DASHBOARD HOME =================
  Widget _dashboardHome() {
    return Column(
      children: [
        const SizedBox(height: 20),
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
        Expanded(child: _dashboardCards()),
      ],
    );
  }

  // ================= DASHBOARD CARDS =================
  Widget _dashboardCards() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          _DashboardCard(
            icon: Icons.storage,
            title: "Data Utama",
            onTap: () => _menuController.setMenu(AdminMenu.dataMaster),
          ),
          _DashboardCard(
            icon: Icons.people,
            title: "Manajemen User",
            onTap: () => _menuController.setMenu(AdminMenu.manajemenUser),
          ),

          // ================= PENGUMUMAN =================
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection("pengumuman")
                    .orderBy("createdAt", descending: true)
                    .limit(1)
                    .snapshots(),
            builder: (context, snapshot) {
              String deskripsi = "Belum ada pengumuman";
              String tanggal = "";

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final data = snapshot.data!.docs.first;

                deskripsi = data["deskripsi"];

                if (data["tanggal"] != null) {
                  Timestamp ts = data["tanggal"];
                  DateTime tgl = ts.toDate();
                  tanggal = "${tgl.day}-${tgl.month}-${tgl.year}";
                }
              }

              return _PengumumanCard(tanggal: tanggal, deskripsi: deskripsi);
            },
          ),
        ],
      ),
    );
  }
}

// ================= CARD NORMAL =================
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 250,
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
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CARD PENGUMUMAN =================
class _PengumumanCard extends StatelessWidget {
  final String tanggal;
  final String deskripsi;

  const _PengumumanCard({required this.tanggal, required this.deskripsi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 125, 46, 46),
            Color.fromARGB(255, 187, 102, 102),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign, color: Colors.white, size: 40),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pengumuman Terbaru",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  tanggal,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 10),

                Text(
                  deskripsi,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
