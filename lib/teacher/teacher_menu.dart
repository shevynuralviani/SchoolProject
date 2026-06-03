enum TeacherMenu { beranda, dataSiswa, suratIzin, video, akunsaya, absen }

class TeacherMenuController {
  TeacherMenu _activeMenu = TeacherMenu.beranda;

  TeacherMenu get activeMenu => _activeMenu;

  void setMenu(TeacherMenu menu) {
    _activeMenu = menu;
  }

  bool isActive(TeacherMenu menu) {
    return _activeMenu == menu;
  }
}
