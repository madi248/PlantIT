import 'package:flutter/material.dart';
import 'package:plantitapp/screens/details_screen.dart';
import '../data/database_service.dart';
import '../models/plant_model.dart';
import '../widgets/plant_card.dart';

class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: StreamBuilder<List<Plant>>(
        stream: dbService.getPlants(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Empty State (No Plants yet)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_florist_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your garden is empty",
                    style: TextStyle(color: Colors.grey[500], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Go to the scanner to add your first plant!",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // 4. Data State (The Grid)
          final plants = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header text
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "My Collection",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // The Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 items per row
                          childAspectRatio: 0.8, // Taller cards
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      return PlantCard(
                        plant: plant,
                        onTap: () {
                          // TODO: Navigate to Details Screen
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text("Selected: ${plant.name}")),
                          // );
                          // LINK THE SCREENS HERE
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(plant: plant),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
