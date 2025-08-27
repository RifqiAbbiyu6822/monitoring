// lib/main.dart - Updated version
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/temuan/temuan_screen.dart';
import 'screens/perbaikan/perbaikan_screen.dart';
import 'screens/history_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/database_management_screen.dart';
import 'services/database_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await _initializeDatabase();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MonitoringApp());
}

Future<void> _initializeDatabase() async {
  try {
    final databaseService = DatabaseService();
    await databaseService.database; // This will create/initialize the database
    debugPrint('Database initialized successfully');
  } catch (e) {
    debugPrint('Error initializing database: $e');
  }
}

class MonitoringApp extends StatelessWidget {
  const MonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring Jalan Tol MBZ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/temuan': (context) => const TemuanScreen(),
        '/perbaikan': (context) => const PerbaikanScreen(),
        '/history': (context) => const HistoryScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/database': (context) => const DatabaseManagementScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    TemuanScreen(),
    PerbaikanScreen(),
    HistoryScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Temuan',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Perbaikan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Laporan',
          ),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryLight,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radius8),
                  ),
                  child: const Icon(
                    Icons.engineering,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Text(
                  'MBZ Monitoring',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Sistem Monitoring Jalan Tol',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Beranda'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Temuan'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Perbaikan'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Laporan'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Manajemen Database'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/database');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              _showSettingsDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Tentang Aplikasi'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan'),
        content: const Text('Fitur pengaturan akan segera hadir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang Aplikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MBZ Toll Road Monitoring',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            const Text('Versi: 1.0.0'),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Sistem monitoring terpadu untuk pengelolaan '
              'infrastruktur jalan tol yang efisien dan modern.',
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'Fitur Utama:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            const Text('• Pelaporan temuan infrastruktur'),
            const Text('• Manajemen perbaikan'),
            const Text('• Tracking progress pekerjaan'),
            const Text('• Laporan dan analytics'),
            const Text('• Backup dan restore data'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}