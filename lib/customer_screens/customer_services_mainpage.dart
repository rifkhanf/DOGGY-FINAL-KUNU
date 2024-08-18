import 'package:flutter/material.dart';
import 'collection_schedule_screen.dart';
import 'garbage_bins.dart';
import 'update_location_screen.dart';
import 'booking_page.dart';

class CustomerRoutesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        title: Text(
          'SERVICES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(3, 3),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        shadowColor: Colors.yellow[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 16),
            ServiceCard(
              title: 'Update Location',
              description:
                  'Keep your address up-to-date to ensure timely and accurate garbage collection.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateLocationScreen(),
                  ),
                );
              },
              color: Colors.orangeAccent,
              icon: Icons.location_on,
            ),
            SizedBox(height: 16),
            ServiceCard(
              title: 'Change Collection Schedule',
              description:
                  'Adjust your garbage collection schedule according to your convenience.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectionScheduleScreen(),
                  ),
                );
              },
              color: Colors.teal,
              icon: Icons.schedule,
            ),
            SizedBox(height: 16),
            ServiceCard(
              title: 'View Garbage Bins',
              description:
                  'Check the status and location of your assigned garbage bins.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GarbageBinsScreen(),
                  ),
                );
              },
              color: Colors.lightGreen,
              icon: Icons.delete,
            ),
            SizedBox(height: 16),
            ServiceCard(
              title: 'Book an Appointment',
              description:
                  'Schedule an appointment for any service related to garbage management.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreenCustomer(),
                  ),
                );
              },
              color: Colors.blueAccent,
              icon: Icons.add_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color color;
  final IconData icon;

  ServiceCard({
    required this.title,
    required this.description,
    required this.onTap,
    required this.color,
    required this.icon,
  });

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: _isHovered
              ? Matrix4.translationValues(0, -10, 0)
              : Matrix4.translationValues(0, 0, 0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.greenAccent,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 12 : 8,
                offset: _isHovered ? Offset(0, 6) : Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Icon(widget.icon, color: Colors.white, size: 28),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
