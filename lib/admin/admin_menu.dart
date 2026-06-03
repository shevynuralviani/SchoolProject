import 'package:flutter/material.dart';

enum AdminMenu {
  beranda,
  dataMaster,
  dataSiswa,
  dataVideo,
  dataAlumni,
  dataKelas,
  dataTahunLulus,
  manajemenUser,
  daftarGuru,
  akunsaya,
  pengumuman,
}

class AdminMenuController extends ChangeNotifier {
  AdminMenu _activeMenu = AdminMenu.beranda;

  AdminMenu get activeMenu => _activeMenu;

  void setMenu(AdminMenu menu) {
    _activeMenu = menu;
    notifyListeners();
  }

  bool isActive(AdminMenu menu) => _activeMenu == menu;
}
