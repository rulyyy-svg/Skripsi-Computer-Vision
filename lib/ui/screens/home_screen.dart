import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/ui/screens/quiz_screen.dart';
import 'package:flutter_application_1/ui/screens/scanner_screen.dart';
import 'package:flutter_application_1/ui/screens/profile_screen.dart';
import 'package:flutter_application_1/models/parfum_model.dart';
import 'package:flutter_application_1/ui/screens/parfum_detail_screen.dart';
import 'package:flutter_application_1/ui/screens/catalog_screen.dart';
import 'NotificationScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  String selectedAroma = "Semua";
  String selectedConcentration = "Semua";

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildModernHeader(uid),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildPromoBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _buildSectionTitle("Keluarga Aroma"),
                  const SizedBox(height: 15),
                  _buildFragranceFamilyList(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Jenis Konsentrasi"),
                  const SizedBox(height: 15),
                  _buildConcentrationList(),
                  const SizedBox(height: 30),
                  _buildPerfumeExploreHeader(),
                ],
              ),
            ),
            _buildPerfumeGrid(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      floatingActionButton: _buildModernFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPerfumeExploreHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Jelajahi Parfum",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CatalogScreen()),
            );
          },
          child: const Text(
            "Lihat Semua",
            style: TextStyle(
              color: Color(0xFF00838F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

// --- HEADER MODERN DENGAN NOTIFIKASI REAL-TIME ---
  Widget _buildModernHeader(String? uid) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00838F), Color(0xFF0097A7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              String name = "User";
              String? photoBase64;

              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                name = data['nama'] ?? "User";
                photoBase64 = data['photo_url'];
              }

              return Row(
                children: [
                  // Foto Profil (Klik untuk ke ProfileScreen)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      backgroundImage:
                          (photoBase64 != null && photoBase64.isNotEmpty)
                              ? MemoryImage(base64Decode(photoBase64))
                              : null,
                      child: (photoBase64 == null || photoBase64.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Teks Sambutan
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Datang,",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // TOMBOL NOTIFIKASI DENGAN BADGE ANGKA
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('notifications')
                        .where('isRead',
                            isEqualTo: false) // Hanya hitung yang belum dibaca
                        .snapshots(),
                    builder: (context, notifySnap) {
                      int unreadCount = 0;
                      if (notifySnap.hasData) {
                        unreadCount = notifySnap.data!.docs.length;
                      }

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreen(),
                                ),
                              );
                            },
                          ),
                          // Munculkan bulatan merah jika ada pesan belum dibaca
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF00838F), width: 1),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Cari brand atau varian...",
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF00838F),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // --- PROMO BANNER ---
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: NetworkImage(
            "https://i.pinimg.com/1200x/d6/98/82/d69882ec496a015ccbc25ba75d9e765a.jpg",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomLeft,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Temukan Karaktermu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LIST KELUARGA AROMA ---
  Widget _buildFragranceFamilyList() {
    final families = [
      {'n': 'Semua', 'i': Icons.all_inclusive_rounded},
      {'n': 'Floral', 'i': Icons.local_florist_rounded},
      {'n': 'Woody', 'i': Icons.forest_rounded},
      {'n': 'Fresh', 'i': Icons.water_drop_rounded},
      {'n': 'Citrus', 'i': Icons.eco_rounded},
      {'n': 'Sweet', 'i': Icons.cake_rounded},
      {'n': 'Oriental', 'i': Icons.wb_sunny_rounded},
      {'n': 'Fruity', 'i': Icons.apple_rounded},
      {'n': 'Aquatic', 'i': Icons.waves_rounded},
      {'n': 'Musky', 'i': Icons.bubble_chart_rounded},
      {'n': 'Powdery', 'i': Icons.cloud_rounded},
      {'n': 'Gourmand', 'i': Icons.icecream_rounded},
      {'n': 'Spicy', 'i': Icons.whatshot_rounded},
      {'n': 'Aromatic', 'i': Icons.spa_rounded},
      {'n': 'Earthy', 'i': Icons.landscape_rounded},
      {'n': 'Vanilla', 'i': Icons.cookie_rounded},
      {'n': 'Nutty', 'i': Icons.grain_rounded},
      {'n': 'Green', 'i': Icons.grass_rounded},
      {'n': 'Tuberose', 'i': Icons.settings_input_antenna_rounded},
      {'n': 'Amber', 'i': Icons.wb_iridescent_rounded},
      {'n': 'Creamy', 'i': Icons.bakery_dining_rounded},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: families.map((c) {
          final name = c['n'] as String;
          return GestureDetector(
            onTap: () => setState(() => selectedAroma = name),
            child: _buildCategoryCard(
              name,
              c['i'] as IconData,
              selectedAroma == name,
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- LIST JENIS KONSENTRASI ---
  Widget _buildConcentrationList() {
    final concentrations = [
      {'n': 'Semua', 'i': Icons.all_inclusive_rounded},
      {
        'n': 'Extrait de Parfume (Parfume)',
        'i': Icons.workspace_premium_rounded,
      },
      {'n': 'Eau de Parfume (EDP)', 'i': Icons.opacity_rounded},
      {'n': 'Eau de Toilette (EDT)', 'i': Icons.bubble_chart_outlined},
      {'n': 'Eau de Cologne (EDC)', 'i': Icons.water_rounded},
      {'n': 'Eau de Luxe (EDL)', 'i': Icons.stars_rounded},
      {'n': 'Body Mist', 'i': Icons.air_rounded},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: concentrations.map((c) {
          final name = c['n'] as String;
          return GestureDetector(
            onTap: () => setState(() => selectedConcentration = name),
            child: _buildCategoryCard(
              name,
              c['i'] as IconData,
              selectedConcentration == name,
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- CARD KATEGORI ---
  Widget _buildCategoryCard(String title, IconData icon, bool isSelected) {
    bool hasParentheses = title.contains(" (");
    String mainTitle = hasParentheses ? title.split(" (")[0] : title;
    String subTitle = hasParentheses ? "(${title.split(" (")[1]}" : "";

    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00838F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF00838F),
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mainTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF00838F) : Colors.black87,
            ),
          ),
          if (subTitle.isNotEmpty)
            Text(
              subTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // --- GRID PARFUM (FILTER LOGIC) ---
  Widget _buildPerfumeGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('parfums').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // 1. Ambil data database dan bersihkan (trim & lowercase)
          String dbFamily =
              (data['fragrance_family'] ?? "").toString().toLowerCase().trim();
          String dbConc = (data['konsentrasi'] ?? "").toString().trim();
          String dbVarian =
              (data['varian'] ?? "").toString().toLowerCase().trim();
          String dbBrand =
              (data['brand'] ?? "").toString().toLowerCase().trim();

          // 2. Siapkan filter user dan bersihkan juga
          String searchKey = searchQuery.toLowerCase().trim();
          String aromaKey = selectedAroma.toLowerCase().trim();

          // --- LOGIKA FILTER ---

          // Pencarian
          bool matchesSearch =
              dbVarian.contains(searchKey) || dbBrand.contains(searchKey);

          // Aroma (Dibuat lebih fleksibel agar "Sweet" bisa nemu "Sweet" di dalam list panjang)
          bool matchesAroma =
              (selectedAroma == "Semua") || dbFamily.contains(aromaKey);

          // Konsentrasi
          bool matchesConc = (selectedConcentration == "Semua") ||
              (dbConc == selectedConcentration);

          return matchesSearch && matchesAroma && matchesConc;
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                "Parfum tidak ditemukan",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final bool isFilteringActive = searchQuery.isNotEmpty ||
            selectedAroma != "Semua" ||
            selectedConcentration != "Semua";
        final displayDocs =
            isFilteringActive ? filteredDocs : filteredDocs.take(2).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: displayDocs.length,
          itemBuilder: (context, index) {
            var parfum = ParfumModel.fromFirestore(
              displayDocs[index].data() as Map<String, dynamic>,
              displayDocs[index].id,
            );
            return _buildItemCard(parfum);
          },
        );
      },
    );
  }

  // --- ITEM CARD ---
  Widget _buildItemCard(ParfumModel parfum) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParfumDetailScreen(parfum: parfum),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  parfum.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parfum.varian,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    parfum.brand,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Rp ${parfum.harga}",
                    style: const TextStyle(
                      color: Color(0xFF00838F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FAB SCAN ---
  Widget _buildModernFab(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScannerScreen()),
      ),
      child: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF00838F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00838F).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
