import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/parfum_model.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // =========================================================
  // IMAGE PICKER
  // =========================================================
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // =========================================================
  // CAMERA REALTIME
  // =========================================================
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRealtimeMode = false;
  bool _isProcessing = false;

  // =========================================================
  // HASIL DETEKSI & WAKTU INFERENSI
  // =========================================================
  String _currentLabel = "SIAP SCAN";
  double _currentConfidence = 0.0;
  bool _isProductFound = false;
  int _inferenceTime = 0; // Menyimpan waktu inferensi dalam milidetik (ms)

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  // =========================================================
  // LOAD MODEL TFLITE
  // =========================================================
  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/models/model.tflite",
        labels: "assets/models/labels.txt",
      );
    } catch (e) {
      debugPrint("Gagal load model: $e");
    }
  }

  // =========================================================
  // INISIALISASI KAMERA
  // =========================================================
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Gagal inisialisasi kamera: $e");
    }
  }

  // =========================================================
  // MULAI REALTIME SCANNER
  // =========================================================
  Future<void> _startRealtimeScanner() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    setState(() {
      _image = null;
      _isRealtimeMode = true;
      _currentLabel = "MENCARI...";
      _currentConfidence = 0.0;
      _isProductFound = false;
      _inferenceTime = 0;
    });

    await _cameraController!.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _runModelOnFrame(image);
      }
    });
  }

  // =========================================================
  // HENTIKAN REALTIME SCANNER
  // =========================================================
  Future<void> _stopRealtimeScanner() async {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }

    if (mounted) {
      setState(() {
        _isRealtimeMode = false;
      });
    }
  }

  // =========================================================
  // DETEKSI REALTIME DARI FRAME KAMERA
  // =========================================================
  Future<void> _runModelOnFrame(CameraImage image) async {
    try {
      // Mulai hitung waktu komputasi model
      final startTime = DateTime.now().millisecondsSinceEpoch;

      var recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 270,
        numResults: 3,
        threshold: 0.1,
      );

      // Hitung selisih waktu setelah proses klasifikasi selesai
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final currentInference = endTime - startTime;

      // Tidak ada hasil
      if (recognitions == null || recognitions.isEmpty) {
        if (mounted) {
          setState(() {
            _currentLabel = "ARAHKAN KE BOTOL";
            _currentConfidence = 0.0;
            _isProductFound = false;
            _inferenceTime = currentInference;
          });
        }
        return;
      }

      List<String> topPredictions = [];

      for (var item in recognitions) {
        String rawLabel = item["label"];
        String cleanLabel = rawLabel.contains(' ')
            ? rawLabel.split(' ').sublist(1).join(' ')
            : rawLabel;

        double conf = (item["confidence"] as num).toDouble();

        topPredictions.add(
          "$cleanLabel (${(conf * 100).toStringAsFixed(1)}%)",
        );
      }

      String predictionText = topPredictions.join("\n");
      final top = recognitions.first;

      String rawLabel = top["label"];
      String cleanLabel = rawLabel.contains(' ')
          ? rawLabel.split(' ').sublist(1).join(' ')
          : rawLabel;

      double confidence = (top["confidence"] as num).toDouble();

      // Jika confidence rendah atau mendeteksi background
      if (confidence < 0.75 || cleanLabel.toLowerCase() == "background") {
        if (mounted) {
          setState(() {
            _currentLabel = predictionText;
            _currentConfidence = confidence;
            _isProductFound = false;
            _inferenceTime = currentInference;
          });
        }
        return;
      }

      // Jika confidence tinggi / objek valid ditemukan
      if (mounted) {
        setState(() {
          _currentLabel = predictionText;
          _currentConfidence = confidence;
          _isProductFound = true;
          _inferenceTime = currentInference;
        });
      }
    } catch (e) {
      debugPrint("Realtime error: $e");
    }
    {
      await Future.delayed(const Duration(milliseconds: 700));
      _isProcessing = false;
    }
  }

  // =========================================================
  // PILIH GAMBAR DARI GALERI
  // =========================================================
  Future<void> _pickImage() async {
    await _stopRealtimeScanner();

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _currentLabel = "MEMPROSES...";
      _currentConfidence = 0.0;
      _isProductFound = false;
      _inferenceTime = 0;
    });

    _runModelOnImage(_image!);
  }

  // =========================================================
  // DETEKSI DARI GAMBAR GALERI
  // =========================================================
  Future<void> _runModelOnImage(File image) async {
    try {
      // Mulai hitung waktu komputasi gambar statis
      final startTime = DateTime.now().millisecondsSinceEpoch;

      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 3,
        threshold: 0.5,
      );

      final endTime = DateTime.now().millisecondsSinceEpoch;
      final currentInference = endTime - startTime;

      if (recognitions != null && recognitions.isNotEmpty) {
        _processRecognition(recognitions.first, currentInference);
      }
    } catch (e) {
      debugPrint("Image scan error: $e");
    }
  }

  // =========================================================
  // PROSES HASIL DETEKSI GALERI
  // =========================================================
  void _processRecognition(dynamic top, int totalInference) {
    String rawLabel = top["label"];
    String cleanLabel = rawLabel.contains(' ')
        ? rawLabel.split(' ').sublist(1).join(' ')
        : rawLabel;

    double confidence = (top["confidence"] as num).toDouble();

    if (!mounted) return;

    setState(() {
      if (confidence < 0.6 || cleanLabel.toLowerCase() == "background") {
        _currentLabel = "TIDAK DIKENALI";
        _isProductFound = false;
      } else {
        _currentLabel = cleanLabel;
        _isProductFound = true;
      }

      _currentConfidence = confidence;
      _inferenceTime = totalInference; // Menyimpan durasi waktu
    });
  }

  // =========================================================
  // AMBIL DETAIL DARI FIRESTORE
  // =========================================================
  Future<void> _fetchAndShowDetail() async {
    if (!_isProductFound) return;

    _showLoadingIndicator();

    try {
      // Jika mode realtime masih aktif saat data ditarik, amankan dengan menghentikannya
      String labelTarget = _currentLabel;
      if (labelTarget.contains('\n')) {
        // Mengisolasi baris pertama jika _currentLabel berisi teks gabungan Top-3
        labelTarget = labelTarget.split('\n').first.split(' (').first;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('parfums')
          .where('label', isEqualTo: labelTarget)
          .limit(1)
          .get();

      if (!mounted) return;
      Navigator.pop(context);

      if (snapshot.docs.isNotEmpty) {
        final parfum = ParfumModel.fromFirestore(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );

        // SIMPAN RIWAYAT KE FIREBASE
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('history')
                .add({
              'nama': parfum.varian,
              'brand': parfum.brand,
              'akurasi': "${(_currentConfidence * 100).toStringAsFixed(1)}%",
              'timestamp': FieldValue.serverTimestamp(),
            });
            print("Riwayat Berhasil Disimpan!");
          } catch (e) {
            print("Gagal simpan riwayat: $e");
          }
        }

        _showFullDetail(parfum);
      } else {
        _showSnackBar("Data '$labelTarget' tidak ditemukan di database");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar("Koneksi bermasalah: $e");
    }
  }

  // =========================================================
  // BOTTOM SHEET DETAIL PRODUK
  // =========================================================
  void _showFullDetail(ParfumModel parfum) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      parfum.brand.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parfum.varian,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Confidence Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orangeAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.psychology,
                            color: Colors.orangeAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "AI MATCH: ${(_currentConfidence * 100).toStringAsFixed(1)}% ($_inferenceTime ms)",
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      color: Colors.white10,
                      height: 40,
                    ),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildSmallInfoCard("Ukuran", parfum.ukuran ?? "-"),
                        _buildSmallInfoCard("BPOM", parfum.bpom),
                        _buildSmallInfoCard("Longevity", parfum.dayaTahan),
                        _buildSmallInfoCard(
                            "Konsentrasi", parfum.konsentrasi ?? "EDP"),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("FRAGRANCE PROFILE"),
                    _infoRow(
                        Icons.bubble_chart, "Family", parfum.fragranceFamily),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          _noteRow("Top Notes", parfum.topNotes ?? "-"),
                          const Divider(color: Colors.white10),
                          _noteRow("Middle Notes", parfum.middleNotes ?? "-"),
                          const Divider(color: Colors.white10),
                          _noteRow("Base Notes", parfum.baseNotes ?? "-"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("DESKRIPSI"),
                    Text(
                      parfum.deskripsi,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HELPER WIDGETS
  // =========================================================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSmallInfoCard(String title, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 30,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _noteRow(String type, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              type,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  void _showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }

  // =========================================================
  // UI UTAMA
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text(
          "AI PARFUM SCANNER",
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Preview Area
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _isProductFound ? Colors.cyanAccent : Colors.white10,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: _isRealtimeMode && _isCameraInitialized
                    ? CameraPreview(_cameraController!)
                    : _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : const Icon(
                            Icons.image_search,
                            color: Colors.white10,
                            size: 80,
                          ),
              ),
            ),

            const SizedBox(height: 30),

            // Hasil Prediksi & Info Komputasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text(
                    _currentLabel.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isProductFound ? Colors.cyanAccent : Colors.white,
                      fontSize: _currentLabel.contains('\n') ? 14 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _currentConfidence,
                    backgroundColor: Colors.white10,
                    color: Colors.orangeAccent,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 12),
                  // Informasi Waktu Inferensi di Main View
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.speed, color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "Waktu Inferensi: $_inferenceTime ms",
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _actionButton(
              onPressed: _pickImage,
              label: "PILIH GAMBAR",
              icon: Icons.photo_library,
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 15),
            _actionButton(
              onPressed: _isRealtimeMode
                  ? _stopRealtimeScanner
                  : _startRealtimeScanner,
              label: _isRealtimeMode ? "STOP REALTIME" : "SCAN REALTIME",
              icon: _isRealtimeMode ? Icons.stop : Icons.camera_alt,
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 15),
            if (_isProductFound && _currentConfidence > 0.6)
              _actionButton(
                onPressed: _fetchAndShowDetail,
                label: "LIHAT DETAIL",
                icon: Icons.auto_awesome,
                color: Colors.cyanAccent,
                isDark: true,
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required Color color,
    bool isDark = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: isDark ? Colors.black : Colors.white),
        label: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
