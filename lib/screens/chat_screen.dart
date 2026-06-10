import 'package:flutter/material.dart';
import '../models/plant_model.dart';
import '../data/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  final Plant plant;
  const ChatScreen({super.key, required this.plant});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _gemini = GeminiService();

  // Start with a greeting from the plant
  late List<Map<String, String>> messages;

  @override
  void initState() {
    super.initState();
    messages = [
      {
        "role": "plant",
        "text": "Hey! I'm ${widget.plant.name}. What do you want?",
      },
    ];
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Show User Message immediately
    setState(() {
      messages.add({"role": "user", "text": text});
      _controller.clear();
    });

    // 2. Calculate Thirst for context
    final nextWaterDate = widget.plant.lastWatered.add(
      Duration(days: widget.plant.waterFrequencyDays),
    );
    final isThirsty = DateTime.now().isAfter(nextWaterDate);

    // 3. Get AI Response
    try {
      final reply = await _gemini.chatWithPlant(
        plantName: widget.plant.name,
        type: widget.plant.scientificName,
        isThirsty: isThirsty,
        message: text,
      );

      if (mounted) {
        setState(() {
          messages.add({"role": "plant", "text": reply});
        });
      }
    } catch (e) {
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.plant.name}"),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? Radius.zero : null,
                        bottomLeft: isUser ? null : Radius.zero,
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Say something...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
