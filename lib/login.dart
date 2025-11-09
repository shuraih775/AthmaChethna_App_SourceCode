import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'forgetpassword.dart';
import 'homescreen.dart';
import 'services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  final String apiUrl = "http://192.168.0.111:5000/api/auth/login";
  final Map<String, dynamic> loginData = {
    "email": emailController.text.trim(),
    "password": passwordController.text.trim(),
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(loginData),
    );

    print("Response Status Code: ${response.statusCode}");
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      Fluttertoast.showToast(msg: "Logged in successfully!");

      // ✅ FIXED: Get user data correctly
      final user = responseData['data']?['user'];
      final token = responseData['data']?['token'];

      if (user == null) {
        Fluttertoast.showToast(msg: "Error: User data missing in response.");
        return;
      }

      // ✅ Save user details in secure storage
      StorageService storageService = StorageService();
      await storageService.saveLoginDetails(
        userId: user['id'] ?? '',
        username: user['name'] ?? '',
        email: user['email'] ?? '',
        password: passwordController.text.trim(),
      );

      print("User ID Stored: ${user['id']}");
      print("Token: $token");

      // Navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      print("Error Message: ${responseData['message']}");
      Fluttertoast.showToast(msg: responseData['message'] ?? "Login failed");
    }
  } catch (error) {
    print("Exception: $error");
    Fluttertoast.showToast(msg: "Error: Unable to connect to server.");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEBCB),
      resizeToAvoidBottomInset: true, // ✅ fixes keyboard issue
      body: Stack(
        children: [
          _buildBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 70,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTabBar(),
                _buildSlider(),
                const SizedBox(height: 30),
                _buildMotivationalText(),
                const SizedBox(height: 30),
                _buildForm(),
                const SizedBox(height: 10),
                _buildForgotPasswordButton(),
                const SizedBox(height: 25),
                _isLoading
                    ? const CircularProgressIndicator()
                    : _buildLoginButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 105, 76, 67),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: _login,
      child: const Text(
        "Login",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildBackground() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bkg1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 105, 76, 67),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Login",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signup');
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      child: Container(
        height: 4,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.brown,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildMotivationalText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "There is hope, even when your brain tells you there isn't.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            emailController,
            "Email",
            TextInputType.emailAddress,
            "Enter your email",
            emailValidation: true,
          ),
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType inputType,
    String hint, {
    bool emailValidation = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          if (emailValidation && !value.endsWith("@bmsce.ac.in")) {
            return "Only @bmsce.ac.in emails allowed";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.black),
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: passwordController,
        obscureText: !_isPasswordVisible,
        validator:
            (value) => value == null || value.isEmpty ? "Password is required" : null,
        decoration: InputDecoration(
          labelText: "Password",
          labelStyle: const TextStyle(color: Colors.black),
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
          );
        },
        child: const Text(
          "Forgot Password?",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
