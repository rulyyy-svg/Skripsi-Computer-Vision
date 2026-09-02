import 'dart:convert'; // Untuk Base64
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/ui/screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'help_center_screen.dart';
import 'favorite_screen.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- FUNGSI UNTUK MENGHITUNG JUMLAH FAVORIT SECARA REAL-TIME ---
  Stream<int> countFavorites(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // --- FUNGSI UNTUK MENGHITUNG JUMLAH RIWAYAT SCAN SECARA REAL-TIME ---
  Stream<int> countHistory(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<String> getAverageAccuracy(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return "0%"; // Jika belum pernah scan

      double totalAccuracy = 0;
      for (var doc in snap.docs) {
        // Mengambil string "95.5%" -> dihilangkan % -> diubah ke double
        String rawAcc = doc['akurasi'] ?? "0%";
        double accValue = double.tryParse(rawAcc.replaceAll('%', '')) ?? 0;
        totalAccuracy += accValue;
      }

      double average = totalAccuracy / snap.docs.length;
      return "${average.toStringAsFixed(1)}%";
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil Pengguna",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan koneksi"));
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Data profil tidak ditemukan"),
                  Text(
                    "UID: $uid",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String namaUser = userData['nama'] ?? "User";
          String emailUser = userData['email'] ?? "-";
          String? photoBase64 = userData['photo_url'];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // --- 1. FOTO PROFIL ---
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF00838F),
                    backgroundImage:
                        (photoBase64 != null && photoBase64.isNotEmpty)
                            ? MemoryImage(base64Decode(photoBase64))
                            : null,
                    child: (photoBase64 == null || photoBase64.isEmpty)
                        ? Text(
                            namaUser.isNotEmpty
                                ? namaUser[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 45,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  namaUser,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(emailUser, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),

// --- 2. STATISTIK DINAMIS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Scan Terhitung Otomatis
                      StreamBuilder<int>(
                        stream: countHistory(uid),
                        builder: (context, countSnap) {
                          return _buildStatItem(
                              "Scan", "${countSnap.data ?? 0}");
                        },
                      ),
                      // Favorit Terhitung Otomatis
                      StreamBuilder<int>(
                        stream: countFavorites(uid),
                        builder: (context, countSnap) {
                          return _buildStatItem(
                              "Favorit", "${countSnap.data ?? 0}");
                        },
                      ),
                      // Akurasi Terhitung Otomatis (LOGIKA BARU)
                      StreamBuilder<String>(
                        stream: getAverageAccuracy(uid),
                        builder: (context, accSnap) {
                          return _buildStatItem(
                              "Akurasi", accSnap.data ?? "0%");
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- 3. MENU LIST ---
                _buildMenuItem(Icons.history, "Riwayat Deteksi", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HistoryScreen(), // Pastikan di-import di atas
                    ),
                  );
                }),
                _buildMenuItem(Icons.favorite_border, "Parfum Favorit", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteScreen(),
                    ),
                  );
                }),
                _buildMenuItem(Icons.settings_outlined, "Pengaturan Akun", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                }),
                _buildMenuItem(Icons.help_outline, "Pusat Bantuan", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                }),

                const Divider(
                  height: 40,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),

                // --- 4. TOMBOL LOGOUT ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        "Keluar Akun",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 10),
                const Text(
                  "Parfumku App v1.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Text(
                  "Created with ❤️ for Skripsi Project",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00838F),
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
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
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
