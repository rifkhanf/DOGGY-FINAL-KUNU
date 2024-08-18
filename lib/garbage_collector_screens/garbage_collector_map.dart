import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCollectorLocationScreen extends StatefulWidget {
  @override
  _UpdateCollectorLocationScreenState createState() =>
      _UpdateCollectorLocationScreenState();
}

class _UpdateCollectorLocationScreenState
    extends State<UpdateCollectorLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _selectedPosition = _currentPosition;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  Future<void> _saveLocation() async {
    if (_selectedPosition != null) {
      final String collectorId =
          'LA2x3Re3ZAYwjhyYHxwmZAYeOuY2'; // Example ID of the garbage collector

      final docRef = FirebaseFirestore.instance.collection('users').doc(
          collectorId); // Assuming 'users' is the collection where garbage collectors are stored

      // Check if the document exists
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, update it
        await docRef.update({
          'location': GeoPoint(
              _selectedPosition!.latitude, _selectedPosition!.longitude),
        });
      } else {
        // Document doesn't exist, create it
        await docRef.set({
          'location': GeoPoint(
              _selectedPosition!.latitude, _selectedPosition!.longitude),
          // Add any other necessary fields if required
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Location'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14.0,
                  ),
                  onTap: _onMapTapped,
                  markers: _selectedPosition != null
                      ? {
                          Marker(
                            markerId: MarkerId('selected-location'),
                            position: _selectedPosition!,
                          )
                        }
                      : {},
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _saveLocation,
                    child: Text('Save Location'),
                  ),
                ),
              ],
            ),
    );
  }
}
