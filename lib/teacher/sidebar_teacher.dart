import 'package:flutter/material.dart';
import 'teacher_menu.dart';

class SidebarTeacher extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onToggle;
  final TeacherMenuController menuController;

  // CALLBACK BARU
  final Function(TeacherMenu) onMenuChanged;

  const SidebarTeacher({
    super.key,
    required this.isVisible,
    required this.onToggle,
    required this.menuController,
    required this.onMenuChanged,
  });

  @override
  State<SidebarTeacher> createState() => _SidebarTeacherState();
}

class _SidebarTeacherState extends State<SidebarTeacher> {
  bool _isPelayananOpen = false;

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
          // ================= HEADER =================
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
            Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'images/logo_madrasah.jpeg',
                    width: 68,
                    height: 68,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Sistem Informasi\nMI RQ",
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
                  menu: TeacherMenu.beranda,
                ),

                _menuItem(
                  icon: Icons.folder,
                  title: "Data Siswa",
                  menu: TeacherMenu.dataSiswa,
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
    required TeacherMenu menu,
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

          widget.onMenuChanged(menu);

          setState(() {});
        },
      ),
    );
  }

  // ================= SUB MENU =================
  Widget _subMenu(String title, TeacherMenu menu) {
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

          widget.onMenuChanged(menu);

          setState(() {});
        },
      ),
    );
  }
}
