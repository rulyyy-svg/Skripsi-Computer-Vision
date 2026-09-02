import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/screens/recommendation_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;

  // 1. Variabel Penampung Pilihan Langsung
  String _selectedGender = "";
  String _selectedConc = "";
  String _selectedAroma = ""; // Akan diisi oleh skor tertinggi

  // 2. Map Skor untuk 20 Keluarga Aroma
  final Map<String, int> _familyScores = {
    'Floral': 0,
    'Woody': 0,
    'Fresh': 0,
    'Citrus': 0,
    'Sweet': 0,
    'Oriental': 0,
    'Fruity': 0,
    'Aquatic': 0,
    'Musky': 0,
    'Powdery': 0,
    'Gourmand': 0,
    'Spicy': 0,
    'Aromatic': 0,
    'Earthy': 0,
    'Vanilla': 0,
    'Nutty': 0,
    'Green': 0,
    'Tuberose': 0,
    'Amber': 0,
    'Creamy': 0,
  };

  // 3. Daftar Pertanyaan (Mapping ke 20 Aroma)
  late final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Siapa yang akan menggunakan parfum ini?',
      'subtitle': 'Menyesuaikan koleksi untuk hasil terbaik.',
      'options': [
        {'text': 'Pria', 'type': 'gender', 'value': 'Pria', 'icon': Icons.male},
        {
          'text': 'Wanita',
          'type': 'gender',
          'value': 'Wanita',
          'icon': Icons.female,
        },
        {
          'text': 'Unisex',
          'type': 'gender',
          'value': 'Unisex',
          'icon': Icons.wc,
        },
      ],
    },
    {
      'question': 'Di mana Anda akan paling sering menggunakannya?',
      'subtitle': 'Lokasi menentukan karakter aroma yang tepat.',
      'options': [
        {
          'text': 'Kantor & Ruangan Ber-AC',
          'type': 'score',
          'icon': Icons.business_center,
          'scores': {
            'Fresh': 5,
            'Musky': 4,
            'Powdery': 4,
            'Floral': 3,
            'Citrus': 2,
          },
        },
        {
          'text': 'Acara Formal atau Malam Hari',
          'type': 'score',
          'icon': Icons.nightlife,
          'scores': {
            'Oriental': 5,
            'Amber': 5,
            'Spicy': 4,
            'Woody': 4,
            'Gourmand': 3,
          },
        },
        {
          'text': 'Aktivitas Luar Ruangan & Olahraga',
          'type': 'score',
          'icon': Icons.directions_run,
          'scores': {
            'Citrus': 5,
            'Aquatic': 5,
            'Fresh': 4,
            'Green': 3,
            'Aromatic': 3,
          },
        },
        {
          'text': 'Kencan atau Santai di Kafe',
          'type': 'score',
          'icon': Icons.favorite,
          'scores': {
            'Sweet': 5,
            'Vanilla': 5,
            'Fruity': 4,
            'Gourmand': 4,
            'Creamy': 3,
          },
        },
      ],
    },
    {
      'question': 'Bayangkan aroma favorit Anda di alam...',
      'subtitle': 'Pilih elemen alam yang paling menenangkan bagi Anda.',
      'options': [
        {
          'text': 'Hutan Basah & Batang Kayu',
          'type': 'score',
          'icon': Icons.forest,
          'scores': {'Woody': 5, 'Earthy': 5, 'Green': 4, 'Aromatic': 3},
        },
        {
          'text': 'Bunga Bermekaran & Kebun',
          'type': 'score',
          'icon': Icons.local_florist,
          'scores': {'Floral': 5, 'Tuberose': 5, 'Fruity': 3, 'Sweet': 2},
        },
        {
          'text': 'Udara Laut & Deburan Ombak',
          'type': 'score',
          'icon': Icons.waves,
          'scores': {'Aquatic': 5, 'Fresh': 4, 'Citrus': 3, 'Aromatic': 2},
        },
        {
          'text': 'Rempah Pasar Tradisional & Hangat',
          'type': 'score',
          'icon': Icons.bakery_dining,
          'scores': {'Spicy': 5, 'Oriental': 4, 'Amber': 4, 'Nutty': 3},
        },
      ],
    },
    {
      'question': 'Kesan apa yang ingin Anda tinggalkan?',
      'subtitle': 'Aroma adalah identitas yang diingat orang lain.',
      'options': [
        {
          'text': 'Sangat Bersih & Higienis',
          'type': 'score',
          'icon': Icons.clean_hands,
          'scores': {'Musky': 5, 'Powdery': 5, 'Fresh': 4, 'Citrus': 3},
        },
        {
          'text': 'Manis, Ramah, & Menyenangkan',
          'type': 'score',
          'icon': Icons.sentiment_very_satisfied,
          'scores': {
            'Sweet': 5,
            'Vanilla': 5,
            'Gourmand': 5,
            'Creamy': 4,
            'Nutty': 3,
          },
        },
        {
          'text': 'Misterius, Dewasa, & Tegas',
          'type': 'score',
          'icon': Icons.visibility_off,
          'scores': {
            'Woody': 5,
            'Oriental': 4,
            'Amber': 4,
            'Spicy': 3,
            'Earthy': 3,
          },
        },
      ],
    },
    {
      'question': 'Pilih tingkat ketahanan parfum',
      'subtitle': 'Menentukan konsentrasi minyak parfum dalam botol.',
      'options': [
        {
          'text': 'Extrait de Parfume (Sangat Awet)',
          'type': 'conc',
          'value': 'Extrait de Parfume',
          'icon': Icons.flash_on,
        },
        {
          'text': 'Eau de Parfume (Tahan Lama)',
          'type': 'conc',
          'value': 'Eau de Parfume',
          'icon': Icons.timer,
        },
        {
          'text': 'Eau de Toilette (Standar)',
          'type': 'conc',
          'value': 'Eau de Toilette',
          'icon': Icons.shutter_speed,
        },
        {
          'text': 'Eau de Cologne (Ringan)',
          'type': 'conc',
          'value': 'Eau de Cologne',
          'icon': Icons.opacity,
        },
        {
          'text': 'Body Mist (Segar Sejenak)',
          'type': 'conc',
          'value': 'Body Mist',
          'icon': Icons.air,
        },
        {
          'text': 'Eau de Luxe',
          'type': 'conc',
          'value': 'Eau de Luxe (EDL)',
          'icon': Icons.stars,
        },
      ],
    },
  ];

  void _answerQuestion(Map<String, dynamic> option) {
    // 1. Logika Scoring (Untuk 20 Keluarga Aroma)
    // Jika pilihan yang diklik memiliki data 'scores', tambahkan poinnya ke _familyScores
    if (option.containsKey('scores')) {
      Map<String, int> selectedScores = Map<String, int>.from(option['scores']);
      selectedScores.forEach((key, value) {
        if (_familyScores.containsKey(key)) {
          _familyScores[key] = _familyScores[key]! + value;
        }
      });
    }

    // 2. Logika Direct Selection (Gender & Konsentrasi)
    if (option['type'] == 'gender') {
      _selectedGender = option['value'];
    } else if (option['type'] == 'conc') {
      _selectedConc = option['value'];
    }

    setState(() {
      // Jika masih ada pertanyaan berikutnya
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      }
      // Jika ini adalah pertanyaan terakhir (Selesai)
      else {
        // --- PROSES PENENTUAN PEMENANG AROMA ---
        // Kita urutkan _familyScores dari yang poinnya paling tinggi
        var sortedFamilies = _familyScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Ambil kunci (key) dari aroma yang skornya paling besar
        _selectedAroma = sortedFamilies.first.key;

        // Tampilkan Dialog Berhasil sebelum pindah halaman
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color(0xFF00838F),
            ),
            const SizedBox(height: 20),
            const Text(
              "Analisis Berhasil!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Kami menemukan preferensi parfum Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(height: 30),
            _buildResultTile(Icons.wc, "Gender", _selectedGender),
            _buildResultTile(Icons.auto_awesome, "Aroma", _selectedAroma),
            _buildResultTile(Icons.timer, "Tipe", _selectedConc),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecommendationResultScreen(
                      category: _selectedAroma,
                      gender: _selectedGender,
                      concentration: _selectedConc,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "LIHAT REKOMENDASI",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00838F)),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF00838F),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Quiz Parfum",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 10,
                  width: MediaQuery.of(context).size.width * 0.85 * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00838F), Color(0xFF4DD0E1)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "PERTANYAAN ${_currentQuestionIndex + 1} / ${_questions.length}",
              style: const TextStyle(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00838F),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _questions[_currentQuestionIndex]['question'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _questions[_currentQuestionIndex]['subtitle'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _questions[_currentQuestionIndex]['options'].length,
                itemBuilder: (context, index) {
                  var option =
                      _questions[_currentQuestionIndex]['options'][index];
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00838F).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          option['icon'],
                          color: const Color(0xFF00838F),
                        ),
                      ),
                      title: Text(
                        option['text'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                      onTap: () => _answerQuestion(option),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
