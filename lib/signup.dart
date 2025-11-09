import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'signupverify.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEBCB),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/bkg1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildTabBar(),
                  _buildSlider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Start Your Journey",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Cursive",
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildForm(screenWidth),
                  const SizedBox(height: 20),
                  _buildContinueButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.underline,
                decorationThickness: 2,
              ),
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

  Widget _buildForm(double screenWidth) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            nameController,
            "Full Name",
            TextInputType.name,
            (value) {
              if (value == null || value.isEmpty) return "Name is required";
              if (!RegExp(r"^[A-Za-z ]+$").hasMatch(value)) return "Enter a valid name";
              return null;
            },
          ),
          _buildTextField(
            emailController,
            "College Email",
            TextInputType.emailAddress,
            (value) {
              if (value == null || value.isEmpty) return "Email is required";
              if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) return "Enter a valid email";
              return null;
            },
          ),
          _buildPasswordField(),
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
    String? Function(String?)? validator,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: passwordController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: !_isPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) return "Password is required";
          if (value.length < 6) return "Password must be at least 6 characters";
          return null;
        },
        decoration: InputDecoration(
          labelText: "Password",
          labelStyle: const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: const Color.fromARGB(255, 51, 51, 51),
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

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: confirmPasswordController,
        keyboardType: TextInputType.visiblePassword,
        obscureText: !_isConfirmPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) return "Please confirm your password";
          if (value != passwordController.text) return "Passwords do not match";
          return null;
        },
        decoration: InputDecoration(
          labelText: "Confirm Password",
          labelStyle: const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: const Color.fromARGB(255, 51, 51, 51),
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 102, 76, 68),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          bool success = await _signupUser();
          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmailVerificationPage(email: emailController.text),
              ),
            );
          }
        }
      },
      child: const Text(
        "Continue",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 43, 42, 42),
        ),
      ),
    );
  }

  Future<bool> _signupUser() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.111:5000/api/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Signup successful! Redirecting to OTP verification...");
        return true;
      } else {
        _showSnackBar("Signup failed. Try again.");
        return false;
      }
    } catch (e) {
      _showSnackBar("Signup Error: $e");
      return false;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
