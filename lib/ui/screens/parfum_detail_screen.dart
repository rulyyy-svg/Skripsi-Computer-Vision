import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/parfum_model.dart';

class ParfumDetailScreen extends StatefulWidget {
  final ParfumModel parfum;

  const ParfumDetailScreen({super.key, required this.parfum});

  @override
  State<ParfumDetailScreen> createState() => _ParfumDetailScreenState();
}

class _ParfumDetailScreenState extends State<ParfumDetailScreen> {
  bool isFavorite = false;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.parfum.id)
        .get();

    if (mounted) {
      setState(() => isFavorite = doc.exists);
    }
  }

  void _toggleFavorite() async {
    if (uid == null) return;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.parfum.id);

    if (isFavorite) {
      await favRef.delete();
    } else {
      await favRef.set({
        'brand': widget.parfum.brand,
        'varian': widget.parfum.varian,
        'gender': widget.parfum.gender,
        'konsentrasi': widget.parfum.konsentrasi,
        'aroma_utama': widget.parfum.aromaUtama,
        'top_notes': widget.parfum.topNotes,
        'middle_notes': widget.parfum.middleNotes,
        'base_notes': widget.parfum.baseNotes,
        'harga': widget.parfum.harga,
        'deskripsi': widget.parfum.deskripsi,
        'ukuran': widget.parfum.ukuran,
        'daya_tahan': widget.parfum.dayaTahan,
        'bpom': widget.parfum.bpom,
        'image_url': widget.parfum.imageUrl,
        'addedAt': Timestamp.now(),
      });
    }

    if (mounted) {
      setState(() => isFavorite = !isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? "Berhasil simpan ke favorit" : "Dihapus dari favorit",
          ),
          backgroundColor: const Color(0xFF00838F),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. HEADER IMAGE
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF00838F),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.2),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                child: Hero(
                  tag: widget.parfum.id,
                  child: Image.network(
                    widget.parfum.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 2. CONTENT
          // 2. CONTENT
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                25,
                30,
                25,
                10,
              ), // Padding disesuaikan
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- GROUP BRAND & VARIAN ---
                  Text(
                    widget.parfum.brand.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: 2,
                      color: Color(0xFF00838F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ), // Jarak kecil antara brand & varian
                  Text(
                    widget.parfum.varian,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- BADGE BPOM ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "BPOM: ${widget.parfum.bpom}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25), // Jarak ke bagian harga
                  const Divider(
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ), // Garis pemisah halus
                  const SizedBox(height: 20),

                  // --- HARGA & KONSENTRASI (DIBUAT SEJAJAR/ROW AGAR RAPI) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Estimasi Harga",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "± Rp ${widget.parfum.harga}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00838F),
                            ),
                          ),
                        ],
                      ),
                      // Badge Konsentrasi ditaruh di kanan harga agar seimbang
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00838F), Color(0xFF00ACC1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00838F).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.parfum.konsentrasi
                              .split('=')[0]
                              .trim(), // Ambil teks depannya saja (misal: EDP) agar tidak kepanjangan
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // ... Lanjut ke Info Panel kamu

                  // Info Panel
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoIcon(
                          Icons.wc_rounded,
                          "GENDER",
                          widget.parfum.gender,
                        ),
                        _buildInfoIcon(
                          Icons.straighten_rounded,
                          "UKURAN",
                          widget.parfum.ukuran,
                        ),
                        _buildInfoIcon(
                          Icons.access_time_filled_rounded,
                          "DURASI",
                          "± ${widget.parfum.dayaTahan}",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  const Text(
                    "DESKRIPSI",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.parfum.deskripsi,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 35),

                  // --- KOMPOSISI AROMA (TERMASUK FRAGRANCE FAMILY) ---
                  const Text(
                    "KOMPOSISI AROMA",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildModernNote(
                    "Fragrance Family",
                    widget.parfum.fragranceFamily,
                    const Color(0xFFE0F2F1),
                    Icons.auto_awesome_mosaic_rounded,
                    "Keluarga aroma utama yang menjadi karakter parfum ini.",
                  ),
                  _buildModernNote(
                    "Top Notes",
                    widget.parfum.topNotes,
                    const Color(0xFFFFF3E0),
                    Icons.air_rounded,
                    "Aroma pembuka yang tercium di menit-menit awal.",
                  ),
                  _buildModernNote(
                    "Heart Notes",
                    widget.parfum.middleNotes,
                    const Color(0xFFFCE4EC),
                    Icons.favorite_rounded,
                    "Inti aroma yang muncul setelah top notes menguap.",
                  ),
                  _buildModernNote(
                    "Base Notes",
                    widget.parfum.baseNotes,
                    const Color(0xFFEFEBE9),
                    Icons.layers_rounded,
                    "Aroma dasar yang bertahan paling lama di kulit.",
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00838F), size: 26),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildModernNote(
    String title,
    String content,
    Color color,
    IconData icon,
    String hint,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.8), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
