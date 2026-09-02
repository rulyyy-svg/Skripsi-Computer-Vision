import 'dart:async';
import 'package:flutter/material.dart';
// Tambahkan baris di bawah ini:
import 'package:flutter_application_1/ui/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  // ... dan seterusnya
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Memulai timer untuk pindah halaman
    _startSplashScreen();
  }

  Future<Timer> _startSplashScreen() async {
    var duration = const Duration(seconds: 3); // Durasi splash screen (3 detik)
    return Timer(duration, () {
      // Navigasi ke halaman utama (Home)
      // Navigasi menggunakan pushReplacement agar pengguna tidak bisa kembali ke splash screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        // Ganti HomeScreenPlaceholder dengan HomeScreen aslimu nanti
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan dekorasi gradasi agar terlihat elegan
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // Putih Bersih
              Color(0xFFE0F7FA), // Biru Cyan Sangat Muda (memberi kesan segar)
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Aplikasi
            Image.asset(
              'assets/images/logo.png',
              width: 150, // Sesuaikan ukuran logomu
              height: 150,
            ),
            const SizedBox(height: 20),
            // Nama Aplikasi (Opsional jika logo sudah ada teksnya)
            const Text(
              "Harap Tunggu",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064), // Biru Cyan Tua
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 50),
            // Loading Indicator (Memberi kesan proses)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00838F)),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Placeholder untuk Home Screen (Hapus ini jika HomeScreen asli sudah dibuat) --
class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parfumku Home")),
      body: const Center(child: Text("Halaman Utama Akan Di Sini")),
    );
  }
}
