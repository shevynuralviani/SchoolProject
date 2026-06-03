import 'package:flutter/material.dart';
import 'admin_menu.dart';

class DataMasterPage extends StatelessWidget {
  final AdminMenuController menuController;

  const DataMasterPage({super.key, required this.menuController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
        children: [
          _item(
            "Data Siswa",
            Icons.school,
            () => menuController.setMenu(AdminMenu.dataSiswa),
          ),
          _item(
            "Video",
            Icons.video_library,
            () => menuController.setMenu(AdminMenu.dataVideo),
          ),
          _item(
            "Alumni",
            Icons.groups,
            () => menuController.setMenu(AdminMenu.dataAlumni),
          ),
          _item(
            "Kelas",
            Icons.class_,
            () => menuController.setMenu(AdminMenu.dataKelas),
          ),
          _item(
            "Guru",
            Icons.person,
            () => menuController.setMenu(AdminMenu.daftarGuru),
          ),
          _item(
            "Tahun Lulus",
            Icons.event_available,
            () => menuController.setMenu(AdminMenu.dataTahunLulus),
          ),
        ],
      ),
    );
  }

  Widget _item(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
