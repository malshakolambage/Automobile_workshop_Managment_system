import 'package:flutter/material.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'history_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  final String username;

  const MainScreen({
    super.key,
    required this.username,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int currentIndex = 0;

  late final List<Widget> pages = [
    HomePage(username: widget.username),
    const BookingPage(),
    const HistoryPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),

      // FIX: was `body: pages[currentIndex]`, which destroys and rebuilds
      // the selected page every time you switch tabs — losing scroll
      // position, form input, and (once wired to a backend) re-firing
      // API calls on every tab switch. IndexedStack keeps every page
      // alive in memory and just shows/hides them.
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
            ),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: currentIndex,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          backgroundColor: const Color(0xFF1A1A28),

          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.white,

          unselectedItemColor: Colors.white54,

          elevation: 0,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Booking",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Alerts",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}