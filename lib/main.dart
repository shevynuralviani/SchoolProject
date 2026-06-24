import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'login/login_guru.dart';
import 'teacher/dashboard.dart';
import 'admin/dashboard_admin.dart';
import 'login/login_admin.dart';
import 'teacher/data_siswa.dart';
import 'admin/surat.dart';
import 'admin/tambah_surat.dart';
import 'teacher/profile_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/adminlogin': (context) => const LoginAdmin(),
        '/dashboard': (context) => const DashboardTeacherPage(),
        '/dashboard_admin': (context) => DashboardAdminPage(),
        '/surat': (context) => const SuratKeteranganPage(),
        '/surat/tambah': (context) => const FormTambahSuratKeterangan(),
        '/akun': (context) => const AkunPage(),
        '/data': (context) => const DataSiswaPage(),
      },
    );
  }
}
