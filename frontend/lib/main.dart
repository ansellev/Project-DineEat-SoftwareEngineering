import 'package:flutter/material.dart';
import 'provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'DineEas Table Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1BAC4B),
            primary: const Color(0xFF1BAC4B),
            secondary: const Color(0xFF158C3A),
            background: const Color(0xFFF8F9FA),
          ),
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.currentUser == null) {
      return const LoginScreen();
    }
    return const NavigationController();
  }
}

class NavigationController extends StatefulWidget {
  const NavigationController({Key? key}) : super(key: key);

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List of Root Tab Controllers
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToBookings: () {
          setState(() {
            _currentIndex = 1; // Direct redirect to booking tab
          });
        },
      ),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFFEFFDF4),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant, color: Color(0xFF1BAC4B)),
              label: 'Jelajah',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_sharp),
              selectedIcon: Icon(Icons.bookmark, color: Color(0xFF1BAC4B)),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Color(0xFF1BAC4B)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
