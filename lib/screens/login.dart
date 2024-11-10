import 'package:cache_employee_management/databases/database_helper.dart';
import 'package:cache_employee_management/screens/administrator/administator_home_screen.dart';
import 'package:cache_employee_management/screens/karyawan/karyawan_home_screen.dart';
import 'package:cache_employee_management/screens/karyawan/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DatabaseHelper1 dbHelper = DatabaseHelper1();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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

  Future<void> _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch user details from SQLite
      Map<String, dynamic>? user = await dbHelper.fetchByEmail(email);
      if (user != null) {
        String name = user['nama'];
        String role = user['jabatan'];

        // Save to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
        await prefs.setString('role', role);

        // Navigate to the appropriate home screen
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
          SnackBar(content: Text('User not registered.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password.')),
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
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(),
                    ),
                  );
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
