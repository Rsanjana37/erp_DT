import 'package:erp_test_ui/screens/dashboard_screen.dart';
import 'package:erp_test_ui/screens/home_screen.dart';
import 'package:erp_test_ui/screens/leave_application_screen.dart';
import 'package:erp_test_ui/screens/news_screen.dart';
import 'package:erp_test_ui/screens/performance_screen.dart';
import 'package:erp_test_ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:erp_test_ui/screens/chat_scren.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  void presshandler1() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageChat()),
    );
  }

  Widget activepage = HomePage();
  String title = '';
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 0) {
      activepage = HomePage();
    }

    if (_selectedIndex == 2) {
      activepage = ProfilePage();
      //title = 'Profile';
    }
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        // backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        backgroundColor: const Color.fromARGB(255, 12, 13, 27),
        selectedFontSize: 15,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: presshandler1,
              icon: const Icon(Icons.chat),
            ),
            label: 'ChatBot',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
      body: activepage,
      drawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Dashboard
            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EmployeeDashboard()), // Replace with your login page widget
                );
              },
            ),
            // Divider Line
            Divider(),
            // Leave Application
            ListTile(
              leading: Icon(Icons.document_scanner, color: Colors.blue),
              title: const Text('Leave Application'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LeaveApplicationScreen()), // Replace with your login page widget
                );
              },
            ),
            Divider(),
            // Performance
            ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text('Performance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaveChartScreen()),
                );
              },
            ),
            // Blog
            Divider(),
            ListTile(
              leading: Icon(Icons.article, color: Colors.blue),
              title: const Text('News'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsScreen(), // Replace with your key
                  ),
                );
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
