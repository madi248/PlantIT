import 'package:flutter/material.dart';
import 'package:plantitapp/screens/camera_screen.dart';
import 'package:plantitapp/screens/wiki_screen.dart';
import '../data/auth_service.dart';
import 'auth/login_screen.dart';
import './my_garden_screen.dart';

// Placeholder widgets for the tabs (we will build these files later)
// This allows the code to run NOW without errors.
class MyGardenPlaceholder extends StatelessWidget {
  const MyGardenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("My Garden (Coming Soon)"));
}

class ScannerPlaceholder extends StatelessWidget {
  const ScannerPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Camera Scanner (Coming Soon)"));
}

class WikiPlaceholder extends StatelessWidget {
  const WikiPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Plant Wiki (Coming Soon)"));
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key}); // This const constructor fixes your error!

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  // The list of screens for the bottom navigation
  final List<Widget> _screens = const [
    MyGardenScreen(),
    CameraScreen(),
    WikiScreen(),
  ];

  // Colors
  final Color plantGreen = const Color(0xFF2D6A4F);

  void _handleLogout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PlantIT",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        // Smooth transition between tabs
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD8F3DC), // Light green highlight
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist, color: Color(0xFF2D6A4F)),
            label: 'My Garden',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt, color: Color(0xFF2D6A4F)),
            label: 'Identify',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF2D6A4F)),
            label: 'Wiki',
          ),
        ],
      ),
    );
  }
}
