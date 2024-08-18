import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingListScreenCollector extends StatefulWidget {
  @override
  _BookingListScreenCollectorState createState() =>
      _BookingListScreenCollectorState();
}

class _BookingListScreenCollectorState
    extends State<BookingListScreenCollector> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Fetch bookings from Firestore
        QuerySnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collectionGroup('bookings').get();

        // Return the data as a list of maps
        return snapshot.docs.map((doc) {
          return doc.data()..['documentId'] = doc.id;
        }).toList();
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Bookings'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookings(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings found.'));
          } else {
            // Display the list of bookings
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> booking = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.event_note),
                    title: Text('Date: ${booking['date']}'),
                    subtitle: Text(
                        'Time: ${booking['time']}\nWaste Quantity: ${booking['waste_quantity']} kg\nAdditional Info: ${booking['additional_info']}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
