import 'package:cache_employee_management/databases/database_helper.dart';
import 'package:cache_employee_management/screens/administrator/administator_home_screen.dart';
import 'package:cache_employee_management/screens/karyawan/karyawan_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DatabaseHelper1 dbHelper = DatabaseHelper1();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Admin',
      'username': 'adminadmin',
      'password': 'admin123',
      'role': 'Administrator',
    },
    {
      'name': 'Karyawan',
      'username': 'karyawankaryawan',
      'password': 'karyawan123',
      'role': 'Staff',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  Future<void> _checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    String? name = prefs.getString('name');

    if (role != null && name != null) {
      if (role == 'Administrator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdministratorHome(name: name, role: role),
          ),
        );
      } else if (role == 'Staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => KaryawanHome(name: name, role: role),
          ),
        );
      }
    }
  }

  void _login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username == 'adminadmin' && password == 'admin123') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', 'Admin');
      await prefs.setString('role', 'Administrator');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AdministratorHome(name: 'Admin', role: 'Administrator'),
        ),
      );
      return;
    }

    Map<String, dynamic>? user = await dbHelper.fetchByUsername(username);

    if (user != null && user['password'] == password) {
      String name = user['nama'];
      String role = user['jabatan'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('role', role);

      if (role == 'Administrator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdministratorHome(name: name, role: role),
          ),
        );
      } else if (role == 'Staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => KaryawanHome(name: name, role: role),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Cache",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _login,
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
