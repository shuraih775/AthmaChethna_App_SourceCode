import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/storage_service.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final StorageService _storageService = StorageService();

  String name = "";
  String username = "";
  String email = "";
  //String usn = "";
  String semester = "";
  String department = "";
  String phone = "";
  //String password = "••••••••";
  //bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ Load user details from the backend using userId
  Future<void> _loadUserData() async {
    try {
      String? userId = await _storageService.getUserId();

      if (userId == null) {
        print("Error: User ID not found in secure storage.");
        return;
      }

      final String apiUrl = "http://192.168.0.111:5000/api/user/$userId";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = responseData['user'];

        print("Fetched User Data: $user"); // For debugging

        setState(() {
          name = user['name'] ?? "N/A";
          username = user['username'] ?? "N/A";
          email = user['email'] ?? "N/A";
          semester = user['semester'] ?? "N/A";
          department = user['department'] ?? "N/A";
          phone = user['phone'] ?? "N/A";
          //password = user['password'] ?? "••••••••";
        });
      } else {
        print("Failed to fetch user data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2EDE5),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.brown[900]!, Colors.brown[500]!],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                top: 60,
                left: MediaQuery.of(context).size.width / 2 - 80,
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: MediaQuery.of(context).size.width / 2 - 50,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFF2EDE5),
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.0),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : 'U', // First letter of name
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 60),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildListTile(
                  icon: Icons.person,
                  title: 'Name',
                  subtitle: name,
                ),
                _buildListTile(
                  icon: Icons.account_circle,
                  title: 'Username',
                  subtitle: username,
                ),
                _buildListTile(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: email,
                ),
                //_buildListTile(icon: Icons.badge, title: 'USN', subtitle: usn),
                _buildListTile(
                  icon: Icons.book,
                  title: 'Semester',
                  subtitle: semester,
                ),
                _buildListTile(
                  icon: Icons.school,
                  title: 'Department',
                  subtitle: department,
                ),
                _buildListTile(
                  icon: Icons.phone,
                  title: 'Phone',
                  subtitle: phone,
                ),
                //_buildPasswordTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown[500]),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        subtitle.isNotEmpty ? subtitle : "N/A", // Ensure subtitle is not empty
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  //Widget _buildPasswordTile() {
  //return _buildListTile(
  //icon: Icons.lock,
  //title: 'Password',
  //subtitle: _isPasswordVisible ? password : '••••••••',
  //);
  //}
}

// ✅ WaveClipper class remains unchanged
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height - 30,
    );
    path.quadraticBezierTo(
      3 * size.width / 4,
      size.height - 60,
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
