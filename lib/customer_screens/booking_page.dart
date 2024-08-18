import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreenCustomer extends StatefulWidget {
  @override
  _BookingScreenCustomerState createState() => _BookingScreenCustomerState();
}

class _BookingScreenCustomerState extends State<BookingScreenCustomer> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _wasteQuantity;
  String? _additionalInfo;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      if (pickedTime.hour >= 8 && pickedTime.hour <= 17) {
        setState(() {
          _selectedTime = pickedTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a time between 8:00 AM and 5:00 PM')),
        );
      }
    }
  }

  void _submitBooking() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String userId = user.uid;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('bookings')
              .add({
            'date': _selectedDate?.toIso8601String(),
            'time': _selectedTime?.format(context),
            'waste_quantity': _wasteQuantity,
            'additional_info': _additionalInfo,
            'created_at': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking submitted successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book an Appointment',
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
        backgroundColor: Colors.yellow[700]!,
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Please select your booking details below:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  shadowColor: Colors.greenAccent,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.greenAccent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.calendar_today, color: Colors.yellow[800]!),
                          title: Text(_selectedDate == null
                              ? 'Select Date'
                              : '${_selectedDate!.toLocal()}'.split(' ')[0]),
                          onTap: () => _selectDate(context),
                          subtitle: _selectedDate == null
                              ? Text(
                                  'Date is required',
                                  style: TextStyle(color: Colors.red),
                                )
                              : null,
                        ),
                        Divider(color: Colors.greenAccent),
                        ListTile(
                          leading: Icon(Icons.access_time, color: Colors.yellow[800]!),
                          title: Text(_selectedTime == null
                              ? 'Select Time'
                              : _selectedTime!.format(context)),
                          onTap: () => _selectTime(context),
                          subtitle: _selectedTime == null
                              ? Text(
                                  'Time is required',
                                  style: TextStyle(color: Colors.red),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Waste Quantity (in kg)',
                    prefixIcon: Icon(Icons.line_weight, color: Colors.yellow[800]!),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow[700]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _wasteQuantity = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the waste quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Additional Information',
                    prefixIcon: Icon(Icons.info_outline, color: Colors.yellow[800]!),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow[700]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) {
                    _additionalInfo = value;
                  },
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedDate == null || _selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select a date and time.'),
                          ),
                        );
                      } else {
                        _submitBooking();
                      }
                    },
                    icon: Icon(Icons.check),
                    label: Text('Submit Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700]!,
                      elevation: 5,
                      shadowColor: Colors.yellow[300]!,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
