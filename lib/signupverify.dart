import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'congo.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  String otpCode = "";
  bool _isVerifying = false;
  bool _isResending = false;

  Future<void> _promptAutoReadPermission() async {
    bool granted = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Auto-Read OTP'),
            content: const Text('Allow the app to read OTP automatically?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  var status = await Permission.sms.request();
                  Navigator.pop(context, status.isGranted);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    if (granted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Auto-read enabled')));
    }
  }

  Future<void> _verifyOTP() async {
    if (otpCode.length != 4) {
      Fluttertoast.showToast(msg: "Please enter a valid 4-digit OTP.");
      return;
    }

    setState(() => _isVerifying = true);

    final String apiUrl = "http://192.168.0.111:5000/api/auth/verify-otp";
    final Map<String, dynamic> otpData = {
      "email": widget.email,
      "otp": otpCode,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(otpData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "OTP Verified! Account created successfully.",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CongoScreen()),
        );
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "Invalid OTP. Try again.",
        );
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Error: Unable to verify OTP.");
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);

    final String apiUrl = "http://192.168.0.111:5000/api/auth/resend-otp";
    final Map<String, dynamic> requestData = {"email": widget.email};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "New OTP sent to your email!");
        setState(() => otpCode = ""); // Clear the entered OTP after resending
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "Failed to resend OTP.",
        );
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Error: Unable to resend OTP.");
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _promptAutoReadPermission();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEBCB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: screenHeight * 0.25,
                    decoration: const BoxDecoration(color: Colors.brown),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFCEBCB),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text(
                      'Email Verification',
                      style: TextStyle(
                        color: Color(0xFFFCEBCB),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.08),
            const Text(
              'Get Your Code',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Please enter the 4 digit code sent to your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            OtpTextField(
              numberOfFields: 4,
              borderColor: Colors.brown,
              showFieldAsBox: true,
              onCodeChanged: (String code) {},
              onSubmit: (String verificationCode) {
                setState(() {
                  otpCode = verificationCode;
                });
              },
            ),
            TextButton(
              onPressed: _isResending ? null : _resendOTP,
              child: Text(
                _isResending ? 'Resending...' : 'Resend',
                style: const TextStyle(color: Colors.brown),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70.0),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    _isVerifying ? 'Verifying...' : 'Verify and Proceed',
                    style: const TextStyle(
                      color: Color(0xFFFCEBCB),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for a diagonal wave curve
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 30,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height - 80,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
