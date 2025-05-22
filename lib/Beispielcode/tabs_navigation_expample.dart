// main.dart
import 'package:flutter/material.dart';
import 'tabs_screen.dart';

void demomain() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aspira Demo',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF8D6CCB),
        useMaterial3: true,
      ),
      home: const TabsScreen(),
    );
  }
}

// tabs_screen.dart
import 'package:flutter/material.dart';

final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _focusNavigatorKey = GlobalKey<NavigatorState>();

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedTabIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _openFokusModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Neue Fokus-Tätigkeit erfassen", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: 'Titel'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: null,
              child: Text("Speichern"),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    switch (_selectedTabIndex) {
      case 0:
        return AppBar(
          title: const Text('Home'),
        );
      case 1:
        return AppBar(
          title: const Text('Fokus'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openFokusModalSheet(context),
            ),
          ],
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          Navigator(
            key: _homeNavigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (ctx) => const DummyScreen(title: 'Home Screen'),
            ),
          ),
          Navigator(
            key: _focusNavigatorKey,
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (ctx) => const DummyScreen(title: 'Fokus Screen'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _selectTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Fokus',
          ),
        ],
      ),
    );
  }
}

class DummyScreen extends StatelessWidget {
  final String title;

  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Zurück'),
          )
        ],
      ),
    );
  }
}

