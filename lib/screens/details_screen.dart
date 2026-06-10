import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:plantitapp/screens/chat_screen.dart';
import '../models/plant_model.dart';
import '../data/database_service.dart';

class DetailsScreen extends StatefulWidget {
  final Plant plant;

  const DetailsScreen({super.key, required this.plant});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;

  // Calculate days overdue or remaining
  int get daysUntilWatering {
    final nextDate = widget.plant.lastWatered.add(
      Duration(days: widget.plant.waterFrequencyDays),
    );
    return nextDate.difference(DateTime.now()).inDays;
  }

  Future<void> _handleWater() async {
    setState(() => _isLoading = true);

    // Update the 'lastWatered' timestamp in Firestore
    await _db.updatePlant(widget.plant.id, {'lastWatered': DateTime.now()});

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Plant watered! Good job.")));
      Navigator.pop(context); // Go back to update the list
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Plant?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deletePlant(widget.plant.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatting the date: "Oct 12, 2024"
    final lastWateredString = DateFormat.yMMMd().format(
      widget.plant.lastWatered,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. The Parallax Header
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2D6A4F),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.plant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // The Image
                  File(widget.plant.imagePath).existsSync()
                      ? Image.file(
                          File(widget.plant.imagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey),

                  // Gradient for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  // Navigate to Chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(plant: widget.plant),
                    ),
                  );
                },
                tooltip: "Talk to me!",
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 2. The Content List
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    _buildStatusCard(),
                    const SizedBox(height: 20),

                    // Scientific Name
                    const Text(
                      "Scientific Name",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      widget.plant.scientificName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 30),

                    // Quick Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat(
                          Icons.wb_sunny,
                          "Sunlight",
                          widget.plant.sunRequirement,
                        ),
                        _buildStat(
                          Icons.water_drop,
                          "Frequency",
                          "${widget.plant.waterFrequencyDays} Days",
                        ),
                        _buildStat(
                          Icons.restaurant,
                          "Edible",
                          widget.plant.isEdible ? "Yes" : "No",
                        ),
                      ],
                    ),
                    const Divider(height: 30),

                    // Last Activity
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history, color: Colors.blue),
                      ),
                      title: const Text("Last Watered"),
                      subtitle: Text(lastWateredString),
                    ),

                    const SizedBox(height: 50),

                    // Delete Button
                    Center(
                      child: TextButton.icon(
                        onPressed: _handleDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          "Remove from Garden",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),

      // 3. The Big Action Button (FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _handleWater,
        backgroundColor: const Color(0xFF2D6A4F),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.water_drop, color: Colors.white),
        label: Text(
          _isLoading ? "Watering..." : "Water Plant",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Helper Widget for the "Thirsty" Alert
  Widget _buildStatusCard() {
    bool isThirsty = daysUntilWatering <= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isThirsty ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isThirsty ? Colors.red.shade100 : Colors.green.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isThirsty
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: isThirsty ? Colors.red : Colors.green,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isThirsty ? "Needs Water!" : "Healthy & Happy",
                  style: TextStyle(
                    color: isThirsty ? Colors.red[900] : Colors.green[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isThirsty
                      ? "This plant is ${daysUntilWatering.abs()} days overdue."
                      : "Next watering in $daysUntilWatering days.",
                  style: TextStyle(
                    color: isThirsty ? Colors.red[700] : Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Stats
  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
