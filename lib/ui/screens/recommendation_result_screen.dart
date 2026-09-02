import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/parfum_model.dart';
import 'package:flutter_application_1/ui/screens/parfum_detail_screen.dart';

class RecommendationResultScreen extends StatelessWidget {
  final String category;
  final String gender;
  final String concentration;

  const RecommendationResultScreen({
    super.key,
    required this.category,
    required this.gender,
    required this.concentration,
  });

  @override
  // ... (bagian atas tetap sama)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Rekomendasi Untukmu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Info Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF00838F),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Wrap(
              spacing: 10,
              children: [
                _buildChip(category),
                _buildChip(gender),
                _buildChip(concentration),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // AMBIL SEMUA DATA PARFUM (Agar tidak terbentur filter Firestore yang kaku)
              stream: FirebaseFirestore.instance
                  .collection('parfums')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text("Error koneksi"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00838F)),
                  );
                }

                // 1. Ambil semua dokumen
                final allDocs = snapshot.data!.docs;

                // 2. Filter secara MANUAL di sisi aplikasi (Lebih fleksibel dibanding Firestore .where)
                List<ParfumModel> filteredParfums = allDocs
                    .map((doc) {
                      return ParfumModel.fromFirestore(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      );
                    })
                    .where((p) {
                      // Kita bersihkan spasi dan samakan huruf kecil semua agar PASTI ketemu
                      final aromaDB = p.aromaUtama.trim().toLowerCase();
                      final aromaUser = category.trim().toLowerCase();

                      // Minimal aroma_utama harus mengandung kata yang dipilih user
                      return aromaDB.contains(aromaUser);
                    })
                    .toList();

                if (filteredParfums.isEmpty) return _buildEmptyState();

                // 3. LOGIKA SORTING (Ranking)
                // Kita urutkan agar yang Gender & Konsentrasi cocok berada di paling atas
                filteredParfums.sort((a, b) {
                  // Prioritas 1: Gender Cocok
                  int scoreA = (a.gender.toLowerCase() == gender.toLowerCase())
                      ? 2
                      : 0;
                  int scoreB = (b.gender.toLowerCase() == gender.toLowerCase())
                      ? 2
                      : 0;

                  // Prioritas 2: Konsentrasi Cocok
                  if (a.konsentrasi.toLowerCase().contains(
                    concentration.toLowerCase(),
                  ))
                    scoreA += 1;
                  if (b.konsentrasi.toLowerCase().contains(
                    concentration.toLowerCase(),
                  ))
                    scoreB += 1;

                  return scoreB.compareTo(scoreA); // Score tinggi di atas
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: filteredParfums.length,
                  itemBuilder: (context, index) =>
                      _buildParfumCard(context, filteredParfums[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00838F),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 5),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              "Maaf, kombinasi $category ($concentration) untuk $gender belum tersedia.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Cobalah kategori lain atau jelajahi katalog lengkap kami.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParfumCard(BuildContext context, ParfumModel parfum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParfumDetailScreen(parfum: parfum),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 1. Gambar Parfum
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  parfum.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // 2. Bagian Teks (Dibungkus Expanded agar tidak Overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parfum.brand,
                      style: const TextStyle(
                        color: Color(0xFF00838F),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      parfum.varian,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                      maxLines: 1, // Batasi 1 baris
                      overflow: TextOverflow
                          .ellipsis, // Tambahkan titik-titik jika kepanjangan
                    ),
                    const SizedBox(height: 6),

                    // Baris Konsentrasi & Daya Tahan
                    // Gunakan Wrap atau Row yang dibungkus Expanded lagi jika masih overflow
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flash_on,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            parfum.dayaTahan,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.local_offer_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            parfum.konsentrasi,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${parfum.harga}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Ikon Panah
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
