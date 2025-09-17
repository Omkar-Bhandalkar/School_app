import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'students_screen.dart';
import 'teachers_screen.dart';
import 'attendance_screen.dart';
import 'timetable_screen.dart';
import 'exams_screen.dart';
import 'events_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StudentsScreen(),
    const TeachersScreen(),
    const AttendanceScreen(),
    const TimetableScreen(),
    const ExamsScreen(),
    const EventsScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.school),
      label: 'Students',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Teachers',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.check_circle),
      label: 'Attendance',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.schedule),
      label: 'Timetable',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: 'Exams',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.event),
      label: 'Events',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          items: _bottomNavItems,
        ),
      ),
    );
  }
}