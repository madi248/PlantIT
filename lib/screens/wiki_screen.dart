import 'package:flutter/material.dart';
import '../data/gemini_service.dart';
import '../data/database_service.dart';
import '../models/plant_model.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final data = await _geminiService.searchPlant(query);

      if (data.containsKey('error')) {
        setState(() => _errorMessage = "That doesn't look like a plant!");
      } else {
        setState(() => _result = data);
      }
    } catch (e) {
      setState(
        () =>
            _errorMessage = "Could not find plant. Try checking the spelling.",
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToGarden() async {
    if (_result == null) return;

    // Create a plant object (Note: Image path is empty since we didn't take a photo)
    final newPlant = Plant(
      id: '',
      name: _result!['name'],
      scientificName: _result!['scientificName'],
      sunRequirement: _result!['sunRequirement'],
      waterFrequencyDays: _result!['waterFrequencyDays'],
      lastWatered: DateTime.now(),
      imagePath: '', // Empty string = use placeholder icon
      isEdible: _result!['isEdible'],
    );

    await _dbService.addPlant(newPlant);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to your Garden!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              const Text(
                "Plant Wiki",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              const Text(
                "Ask the AI Botanist about any plant.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // 2. Search Bar
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: "e.g., Peace Lily, Tomato...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: _handleSearch,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 3. The Body Area (Loading / Error / Result)
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2D6A4F),
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _result != null
                    ? _buildResultCard()
                    : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // State: When nothing is searched yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "Search for a plant to see details",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // State: The Search Result
  Widget _buildResultCard() {
    // Fade Animation
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFD8F3DC).withOpacity(0.3), // Very light green
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD8F3DC)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _result!['name'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),
                  if (_result!['isEdible'])
                    const Icon(Icons.restaurant_menu, color: Colors.orange),
                ],
              ),
              Text(
                _result!['scientificName'],
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const Divider(height: 30),

              // Details
              _buildInfoRow(
                Icons.wb_sunny_outlined,
                "Sunlight",
                _result!['sunRequirement'],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.water_drop_outlined,
                "Watering",
                "Every ${_result!['waterFrequencyDays']} days",
              ),

              const Divider(height: 30),

              // Description
              Text(
                "About",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _result!['description'],
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 40),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _addToGarden,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Add to My Garden"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2D6A4F), size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
