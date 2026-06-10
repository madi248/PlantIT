import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plant_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // 1. ADD a new plant to the user's garden
  Future<void> addPlant(Plant plant) async {
    if (userId == null) return;

    // Go to: users -> {uid} -> plants -> {auto-generated-id}
    await _db
        .collection('users')
        .doc(userId)
        .collection('plants')
        .add(plant.toMap());
  }

  // 2. GET a stream of all plants (Real-time updates)
  Stream<List<Plant>> getPlants() {
    if (userId == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(userId)
        .collection('plants')
        .orderBy('lastWatered', descending: false) // Show thirsty plants first
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Plant.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // 3. UPDATE a plant (e.g., after watering)
  Future<void> updatePlant(String plantId, Map<String, dynamic> data) async {
    if (userId == null) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .update(data);
  }

  // 4. DELETE a plant
  Future<void> deletePlant(String plantId) async {
    if (userId == null) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .delete();
  }
}
