import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'resetpassword.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  String otpCode = "";
  bool isLoading = false;

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

  Future<void> verifyForgotPasswordOTP() async {
    if (otpCode.isEmpty || otpCode.length != 4) {
      showToast("Please enter a valid 4-digit OTP");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse(
        'http://192.168.0.111:5000/api/auth/verify-forgot-password-otp',
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": widget.email, "otp": otpCode}),
    );

    final data = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      showToast("OTP Verified! Reset your password.");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      });
    } else {
      showToast(data["message"]);
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Please enter the 4 digit code sent to ${widget.email}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
              onPressed: () {
                showToast('Email resent');
              },
              child: const Text(
                'Resend',
                style: TextStyle(color: Colors.brown),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70.0),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyForgotPasswordOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: Color(0xFFFCEBCB),
                          )
                          : const Text(
                            'Verify and Proceed',
                            style: TextStyle(
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

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
