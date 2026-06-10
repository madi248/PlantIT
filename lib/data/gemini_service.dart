import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Flash is faster & cheaper for this
      apiKey: GEMINI_API_KEY,
    );
  }

  Future<Map<String, dynamic>> identifyPlant(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();

    // Strict instructions for the AI to behave like an API
    final prompt = TextPart(
      "Identify this plant. Return a raw JSON object ONLY. No Markdown. No ```json tags. "
      "Structure: {"
      "'name': 'Common Name', "
      "'scientificName': 'Scientific Name', "
      "'sunRequirement': 'Low, Partial, or High', "
      "'waterFrequencyDays': integer (approx days between watering), "
      "'isEdible': boolean, "
      "'description': 'Short 2-sentence summary'"
      "}",
    );

    final imagePart = DataPart('image/jpeg', imageBytes);

    try {
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      String? text = response.text;

      if (text == null) throw Exception("AI returned empty response");

      // Cleanup: Sometimes AI adds markdown ```json ... ``` despite instructions
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      // Convert String -> Map
      return jsonDecode(text);
    } catch (e) {
      throw Exception("Failed to identify plant: $e");
    }
  }

  Future<Map<String, dynamic>> searchPlant(String query) async {
    // Instructions for text-only search
    final prompt = Content.text(
      "You are a botanical encyclopedia. The user is searching for '$query'. "
      "Return a raw JSON object with the following details for this specific plant. "
      "If the query is not a real plant, return {'error': 'Not a plant'}. "
      "JSON Structure: {"
      "'name': 'Common Name', "
      "'scientificName': 'Scientific Name', "
      "'sunRequirement': 'Low, Partial, or High', "
      "'waterFrequencyDays': integer (approx days), "
      "'isEdible': boolean, "
      "'description': '2-sentence fun fact or care summary'"
      "}",
    );

    try {
      final response = await _model.generateContent([prompt]);
      String? text = response.text;

      if (text == null) throw Exception("Empty response");

      // Cleanup Markdown if present
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return jsonDecode(text);
    } catch (e) {
      throw Exception("Search failed: $e");
    }
  }

  Future<String> chatWithPlant({
    required String plantName,
    required String type, // e.g. "Cactus"
    required bool isThirsty,
    required String message,
  }) async {
    final mood = isThirsty ? "cranky and thirsty" : "happy and vibrant";

    final prompt = Content.text(
      "You are a $type named $plantName. You are currently $mood. "
      "The user just said: '$message'. "
      "Reply in the first person. Keep it short (max 2 sentences). Be sassy or funny.",
    );

    try {
      final response = await _model.generateContent([prompt]);
      return response.text ?? "I'm speechless...";
    } catch (e) {
      return "I can't hear you right now.";
    }
  }
}
