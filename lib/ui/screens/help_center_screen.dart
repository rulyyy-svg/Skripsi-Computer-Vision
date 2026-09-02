import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  // --- FUNGSI SAKTI UNTUK BUKA WA/EMAIL/WEB ---
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak bisa membuka $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pusat Bantuan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Illustration
            Container(
              height: 180,
              width: double.infinity,
              color: const Color(0xFF00838F).withOpacity(0.05),
              child: const Icon(
                Icons.help_center_rounded,
                size: 80,
                color: Color(0xFF00838F),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pertanyaan Populer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  _buildFaqItem(
                    "Bagaimana cara mendeteksi parfum?",
                    "Klik tombol 'Scan Parfum' di halaman utama, lalu arahkan kamera ke botol parfum secara jelas agar sistem AI dapat mengenali varian tersebut.",
                  ),
                  _buildFaqItem(
                    "Apakah data saya aman?",
                    "Ya, semua data akun dan riwayat Anda disimpan dengan enkripsi menggunakan Firebase Cloud demi keamanan privasi Anda.",
                  ),
                  _buildFaqItem(
                    "Kenapa parfum saya tidak terdeteksi?",
                    "Pastikan botol berada di area dengan cahaya cukup, label tidak tertutup tangan, dan jarak kamera tidak terlalu jauh.",
                  ),
                  _buildFaqItem(
                    "Tentang Aplikasi Parfumku",
                    "Parfumku adalah aplikasi cerdas berbasis Flutter yang dikembangkan untuk membantu pecinta parfum mengidentifikasi varian parfum melalui pemindaian label (Scanner) dan memberikan rekomendasi parfum berdasarkan kepribadian user (Quiz).\n\n"
                        "Versi: 1.0.0 (BETA)\n"
                        "Teknologi: Flutter, Firebase Firestore, Firebase Auth.\n"
                        "Dibuat oleh: Muhammad Bagas Ruliansyah",
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Hubungi Kami",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  _buildContactItem(
                    Icons.email_outlined,
                    "Email Support",
                    "bagasruliansyah2@email.com",
                    () => _launchURL(
                      "mailto:bagasruliansyah2@email.com?subject=Tanya Parfumku",
                    ),
                  ),
                  _buildContactItem(
                    Icons.chat_bubble_outline_rounded,
                    "WhatsApp Admin",
                    "+62 895 1028 1788",
                    () => _launchURL(
                      "https://wa.me/6289510281788",
                    ), // Ganti angka dengan nomor aslimu
                  ),
                  _buildContactItem(
                    Icons.language_rounded,
                    "Website Resmi",
                    "www.parfumku-app.com",
                    () => _launchURL(
                      "https://www.google.com",
                    ), // Ganti dengan link webmu nanti
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk FAQ bergaya Dropdown
  Widget _buildFaqItem(String question, String answer) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        shape: const Border(), // Menghilangkan garis border saat dibuka
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Kontak
  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00838F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF00838F)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
