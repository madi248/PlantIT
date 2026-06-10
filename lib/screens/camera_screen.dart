import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/gemini_service.dart';
import '../data/database_service.dart';
import '../models/plant_model.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();
  final DatabaseService _dbService = DatabaseService();

  bool _isAnalyzing = false;
  Map<String, dynamic>? _plantData; // Holds the AI result temporarily

  // Animation Controller for the "Scanning Line"
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _plantData = null; // Reset previous result
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final data = await _geminiService.identifyPlant(_image!);
      setState(() {
        _plantData = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _savePlant() async {
    if (_plantData == null || _image == null) return;

    final newPlant = Plant(
      id: '', // Firestore will generate this
      name: _plantData!['name'],
      scientificName: _plantData!['scientificName'],
      sunRequirement: _plantData!['sunRequirement'],
      waterFrequencyDays: _plantData!['waterFrequencyDays'],
      lastWatered: DateTime.now(),
      imagePath: _image!.path, // Saving local path
      isEdible: _plantData!['isEdible'],
    );

    await _dbService.addPlant(newPlant);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Plant saved to your Garden!"),
          backgroundColor: Colors.green,
        ),
      );
      // clear screen
      setState(() {
        _image = null;
        _plantData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for camera feel
      appBar: AppBar(
        title: const Text(
          "Plant Scanner",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. The Image Preview Area
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: _image == null
                  ? _buildEmptyState()
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                        // The Scanning Animation Overlay
                        if (_isAnalyzing) _buildScannerOverlay(),
                      ],
                    ),
            ),
          ),

          // 2. The Result Card (Pops up after analysis)
          if (_plantData != null) _buildResultCard(),

          // 3. Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.white54),
        SizedBox(height: 16),
        Text(
          "Tap below to take a picture",
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return AnimatedBuilder(
      animation: _scannerController,
      builder: (context, child) {
        return CustomPaint(painter: ScannerPainter(_scannerController.value));
      },
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _plantData!['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_plantData!['isEdible'])
                const Chip(
                  label: Text("Edible"),
                  backgroundColor: Colors.greenAccent,
                ),
            ],
          ),
          Text(
            _plantData!['scientificName'],
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(_plantData!['description'] ?? ""),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _savePlant,
              icon: const Icon(Icons.favorite),
              label: const Text("Save to My Garden"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library, size: 30),
            color: Colors.black87,
          ),

          // Big Action Button
          FloatingActionButton.large(
            onPressed: _image == null
                ? () => _pickImage(ImageSource.camera)
                : _analyzeImage,
            backgroundColor: const Color(0xFF2D6A4F),
            child: Icon(
              _image == null ? Icons.camera : Icons.search,
              color: Colors.white,
            ),
          ),

          IconButton(
            onPressed: () => setState(() {
              _image = null;
              _plantData = null;
            }),
            icon: const Icon(Icons.refresh, size: 30),
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the cool scanning laser effect
class ScannerPainter extends CustomPainter {
  final double animationValue;
  ScannerPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final y = animationValue * size.height;

    // Draw the line
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Draw a glow effect
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF00FF00).withOpacity(0.3),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, y - 20, size.width, 40));

    canvas.drawRect(Rect.fromLTWH(0, y - 20, size.width, 40), glowPaint);
  }

  @override
  bool shouldRepaint(ScannerPainter oldDelegate) => true;
}
