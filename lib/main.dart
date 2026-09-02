import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahkan ini
import 'ui/screens/splash_screen.dart';

void main() async {
  // 1. Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase (Ini yang bikin aplikasi konek ke cloud)
  await Firebase.initializeApp();

  // 3. Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parfumku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Pakai warna 0xFF00838F supaya senada dengan UI yang kita buat
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00838F)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
