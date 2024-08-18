import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadLatestNewsPage extends StatefulWidget {
  @override
  _UploadLatestNewsPageState createState() => _UploadLatestNewsPageState();
}

class _UploadLatestNewsPageState extends State<UploadLatestNewsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _uploadNews() async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      await _firestore.collection('latest_news').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('News uploaded successfully!')),
      );

      _titleController.clear();
      _descriptionController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Latest News'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'News Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'News Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadNews,
              child: Text('Upload News'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700], // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
