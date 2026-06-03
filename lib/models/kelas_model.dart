import 'guru_model.dart';

class KelasModel {
  final String id;
  final String nama;
  final GuruModel waliKelas;
  final String? tahunPelajaran;

  KelasModel({
    required this.id,
    required this.nama,
    required this.waliKelas,
    this.tahunPelajaran,
  });
}
