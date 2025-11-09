import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // This imports FilteringTextInputFormatter
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CounsellingScreen extends StatefulWidget {
  const CounsellingScreen({super.key});

  @override
  _CounsellingScreenState createState() => _CounsellingScreenState();
}

class _CounsellingScreenState extends State<CounsellingScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = FlutterSecureStorage();
  String name = '';
  String usn = '';
  String department = '';
  String semester = '';
  String reason = '';
  bool isLoading = false;

  // Function to fetch user details from backend
  Future<void> _fetchUserDetails() async {
    final userId = await storage.read(key: 'userId');
    if (userId == null || userId.isEmpty) {
      print('User ID not found!');
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.111:5000/api/auth/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}'); // ✅ DEBUG LOG
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed Data: $data'); // ✅ DEBUG LOG
        setState(() {
          name = data['user']['name']?.toString() ?? '';
          semester = data['user']['semester']?.toString() ?? '';
          department = data['user']['department']?.toString() ?? '';
        });
      } else {
        print('Failed to fetch user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Function to handle the form submission
  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final userId = await storage.read(key: 'userId');
    if (userId == null || userId.isEmpty) {
      print('User ID not found!');
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.111:5000/api/appointments/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'name': name,
          'usn': usn.toUpperCase(),
          'semester': semester,
          'department': department,
          'reason': reason,
        }),
      );
      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        print('Failed to book appointment');
      }
    } catch (e) {
      print('Error booking appointment: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // Fetch user details when screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF2EDE5),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          // Half-screen Image
          Container(
            height: screenHeight * 0.25, // Takes half of the screen
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'images/result2.png',
                ), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              label: 'Name:',
                              initialValue: name,
                              onSaved:
                                  null, // No input allowed, so no onSaved needed
                              validator: null, // No validation needed
                              enabled: false,
                              screenWidth: screenWidth,
                            ),
                            _buildTextField(
                              label: 'Semester:',
                              initialValue: semester,
                              onSaved:
                                  null, // No input allowed, so no onSaved needed
                              validator: null, // No validation needed
                              enabled: false,
                              screenWidth: screenWidth,
                            ),
                            _buildTextField(
                              label: 'Department:',
                              initialValue: department,
                              onSaved:
                                  null, // No input allowed, so no onSaved needed
                              validator: null, // No validation needed
                              enabled: false,
                              screenWidth: screenWidth,
                            ),
                            _buildTextField(
                              label: 'USN:',
                              initialValue:
                                  usn, // Pre-populate the field with current 'usn' value
                              onSaved:
                                  (value) =>
                                      usn =
                                          value!
                                              .toUpperCase(), // Save the value as uppercase
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Please enter your USN'
                                          : null,
                              enabled: true,
                              screenWidth: screenWidth,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[A-Z0-9]'),
                                ), // Only uppercase letters and numbers
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              'Reason to meet counselor:',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.brown,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(16),
                              ),
                              maxLines: 6, // Large text area
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Please enter a reason'
                                          : null,
                              onSaved: (value) => reason = value!,
                            ),
                            SizedBox(height: screenHeight * 0.04),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    _bookAppointment();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.02,
                                    horizontal: screenWidth * 0.12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                ),
                                child: Text(
                                  'Book Appointment',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.04),
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required void Function(String?)? onSaved,
    required String? Function(String?)? validator,
    required bool enabled,
    required double screenWidth,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          enabled: enabled,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.brown, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Appointment Booked Successfully!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'We will contact you shortly. Kindly check your email for appointment details.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text('OK', style: TextStyle(color: Colors.brown)),
              ),
            ],
          ),
    );
  }
}
