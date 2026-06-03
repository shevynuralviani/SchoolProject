import 'package:flutter/material.dart';
import 'admin_menu.dart';

class SidebarAdmin extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onToggle;
  final AdminMenuController menuController;

  const SidebarAdmin({
    super.key,
    required this.isVisible,
    required this.onToggle,
    required this.menuController,
  });

  @override
  State<SidebarAdmin> createState() => _SidebarAdminState();
}

class _SidebarAdminState extends State<SidebarAdmin> {
  bool _isDataMasterOpen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: widget.isVisible ? 220 : 60,
      decoration: const BoxDecoration(
        color: Colors.green,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(3, 0)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER SIDEBAR =================
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 26),
              onPressed: widget.onToggle,
              tooltip: "Tutup Sidebar",
            ),
          ),

          if (widget.isVisible) ...[
            const SizedBox(height: 10),
            const Center(
              child: CircleAvatar(radius: 36, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "ADMIN PANEL\nMI RQ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ================= MENU =================
          Expanded(
            child: ListView(
              children: [
                _menuItem(
                  icon: Icons.dashboard,
                  title: "Beranda",
                  menu: AdminMenu.beranda,
                ),

                if (widget.isVisible) ...[
                  ListTile(
                    leading: const Icon(Icons.folder, color: Colors.white),
                    title: const Text(
                      "Data Master",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      _isDataMasterOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    onTap: () {
                      setState(() {
                        _isDataMasterOpen = !_isDataMasterOpen;
                      });
                    },
                  ),
                  if (_isDataMasterOpen) ...[
                    _subMenu("Data Siswa", AdminMenu.dataSiswa),
                    _subMenu("Data Video", AdminMenu.dataVideo),
                    _subMenu("Data Alumni", AdminMenu.dataAlumni),
                    _subMenu("Data Kelas", AdminMenu.dataKelas),
                    _subMenu("Daftar Guru", AdminMenu.daftarGuru),
                  ],
                ],

                _menuItem(
                  icon: Icons.manage_accounts,
                  title: "Manajemen User",
                  menu: AdminMenu.manajemenUser,
                ),
                _menuItem(
                  icon: Icons.campaign,
                  title: "Pengumuman",
                  menu: AdminMenu.pengumuman,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU UTAMA =================
  Widget _menuItem({
    required IconData icon,
    required String title,
    required AdminMenu menu,
  }) {
    final bool active = widget.menuController.isActive(menu);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade800 : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: active ? Colors.yellow : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: active ? Colors.yellow : Colors.white),
        title:
            widget.isVisible
                ? Text(
                  title,
                  style: TextStyle(
                    color: active ? Colors.yellow : Colors.white,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                )
                : null,
        onTap: () {
          widget.menuController.setMenu(menu);
          setState(() {});
        },
      ),
    );
  }

  // ================= SUB MENU =================
  Widget _subMenu(String title, AdminMenu menu) {
    final bool active = widget.menuController.isActive(menu);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade700 : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: active ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.only(left: 56),
        title: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          widget.menuController.setMenu(menu);
          setState(() {});
        },
      ),
    );
  }
}
