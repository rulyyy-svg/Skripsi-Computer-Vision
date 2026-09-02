class ParfumModel {
  final String id;
  final String brand;
  final String varian;
  final String gender;
  final String konsentrasi;
  final String aromaUtama;
  final String topNotes;
  final String middleNotes;
  final String baseNotes;
  final int harga;
  final String deskripsi;
  final String ukuran;
  final String dayaTahan;
  final String imageUrl; // INI YANG TADI KURANG
  final String bpom;
  final String fragranceFamily;

  ParfumModel({
    required this.id,
    required this.brand,
    required this.varian,
    required this.gender,
    required this.konsentrasi,
    required this.aromaUtama,
    required this.topNotes,
    required this.middleNotes,
    required this.baseNotes,
    required this.harga,
    required this.deskripsi,
    required this.ukuran,
    required this.dayaTahan,
    required this.imageUrl, // INI JUGA
    required this.bpom,
    required this.fragranceFamily,
  });

  factory ParfumModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ParfumModel(
      id: id,
      brand: data['brand'] ?? '',
      varian: data['varian'] ?? '',
      gender: data['gender'] ?? '',
      konsentrasi: data['konsentrasi'] ?? '',
      aromaUtama: data['aroma_utama'] ?? '',
      topNotes: data['top_notes'] ?? '',
      middleNotes: data['middle_notes'] ?? '',
      baseNotes: data['base_notes'] ?? '',
      harga: (data['harga'] is int) ? data['harga'] : 0,
      deskripsi: data['deskripsi'] ?? '',
      ukuran: data['ukuran'] ?? '',
      dayaTahan: data['daya_tahan'] ?? '',
      bpom: data['bpom'] ?? '-',
      imageUrl:
          data['image_url'] ??
          'https://via.placeholder.com/150', // Field di Firebase harus image_url
      fragranceFamily: data['fragrance_family'] ?? '',
    );
  }
}
