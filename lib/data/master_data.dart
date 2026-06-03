import '../models/guru_model.dart';
import '../models/kelas_model.dart';

class MasterData {
  /// ================= GURU =================
  static List<GuruModel> guruList = [
    GuruModel(id: "1", nama: "Ust. Ahmad"),
    GuruModel(id: "2", nama: "Ustadzah Rina"),
  ];

  /// ================= KELAS =================
  static List<KelasModel> kelasList = [
    KelasModel(
      id: "1",
      nama: "1A",
      waliKelas: guruList[0],
      tahunPelajaran: "2025/2026",
    ),
    KelasModel(
      id: "2",
      nama: "1B",
      waliKelas: guruList[1],
      tahunPelajaran: "2025/2026",
    ),
  ];
}
