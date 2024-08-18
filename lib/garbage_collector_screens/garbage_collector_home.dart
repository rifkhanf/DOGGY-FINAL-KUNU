import 'package:flutter/material.dart';
import '../garbage_collector_screens/garbage_collection_routes.dart';
import '../garbage_collector_screens/garbage_collector_profile/garbage_profile_details.dart';
import 'booking_page_collector.dart';

class GarbageCollectorHomePage extends StatefulWidget {
  @override
  _GarbageCollectorHomePageState createState() =>
      _GarbageCollectorHomePageState();
}

class _GarbageCollectorHomePageState extends State<GarbageCollectorHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    // Updated Home Page
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.home, size: 100, color: Colors.teal),
        SizedBox(height: 20),
        Text(
          'Welcome to the Garbage Collector Home',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      ],
    ),
    GarbageCollectionRoutes(),
    BookingListScreenCollector(), // Added the appointments screen
    GarbageCollectorProfileSection(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(
            _selectedIndex == 0
                ? 'Garbage Collector Home'
                : _selectedIndex == 1
                    ? 'Collections'
                    : _selectedIndex == 2
                        ? 'Appointments'
                        : 'Profile',
            key: ValueKey<int>(_selectedIndex),
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Collections',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Appointments',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.teal,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
