import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String sunRequirement; // "High", "Partial", "Low"
  final int waterFrequencyDays; // e.g., 7 (every week)
  final DateTime lastWatered;
  final String imagePath; // Local path to the image on the phone
  final bool isEdible;

  Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.sunRequirement,
    required this.waterFrequencyDays,
    required this.lastWatered,
    required this.imagePath,
    required this.isEdible,
  });

  // Convert a Plant Object to a Map (for sending to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'scientificName': scientificName,
      'sunRequirement': sunRequirement,
      'waterFrequencyDays': waterFrequencyDays,
      'lastWatered': Timestamp.fromDate(
        lastWatered,
      ), // Firestore uses Timestamp
      'imagePath': imagePath,
      'isEdible': isEdible,
    };
  }

  // Create a Plant Object from a Firestore Document
  factory Plant.fromMap(String id, Map<String, dynamic> map) {
    return Plant(
      id: id,
      name: map['name'] ?? 'Unknown Plant',
      scientificName: map['scientificName'] ?? '',
      sunRequirement: map['sunRequirement'] ?? 'Partial',
      waterFrequencyDays: map['waterFrequencyDays'] ?? 7,
      // Convert Firestore Timestamp back to DateTime
      lastWatered: (map['lastWatered'] as Timestamp).toDate(),
      imagePath: map['imagePath'] ?? '',
      isEdible: map['isEdible'] ?? false,
    );
  }
}
