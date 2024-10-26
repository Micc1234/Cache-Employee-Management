import 'package:cache_employee_management/screens/administrator/history_administrator_screen.dart';
import 'package:cache_employee_management/screens/login.dart';
import 'package:cache_employee_management/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rekap_absensi_screen.dart';
import 'manage_karyawan_screen.dart';

class AdministratorHome extends StatefulWidget {
  final String name;
  final String role;

  AdministratorHome({required this.name, required this.role});

  @override
  State<AdministratorHome> createState() => _AdministratorHomeState();
}

class _AdministratorHomeState extends State<AdministratorHome> {
  // Function to perform the logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Method to fetch users
  Future<List<User>> _fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (response.statusCode == 200) {
      final List<dynamic> userData = json.decode(response.body);
      return userData.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cache Employee Management',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BFAE), Color(0xFF1DE9B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00BFAE), Color(0xFF1DE9B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
            _buildDrawerItem(Icons.help_outline, 'Bantuan'),
            _buildDrawerItem(Icons.settings, 'Pengaturan'),
            _buildDrawerItem(Icons.announcement, 'Pengumuman'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 167, 231, 167),
              Color.fromARGB(255, 107, 243, 209),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.teal[600]!, width: 1),
                  ),
                  shadowColor:
                      const Color.fromARGB(255, 57, 61, 61).withOpacity(0.5),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.name}',
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                            Text(
                              '${widget.role}',
                              style: TextStyle(
                                color: const Color.fromARGB(202, 96, 125, 139),
                                fontFamily: 'RobotoMono',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: EdgeInsets.all(15),
                children: [
                  _buildGridItem(Icons.today_rounded, 'Rekap Absensi', context,
                      () async {
                    List<User> users = await _fetchUsers(); // Fetch users
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RekapAbsensiScreen(users: users)),
                    );
                  }),
                  _buildGridItem(
                      Icons.manage_accounts, 'Manajemen Karyawan', context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageKaryawan()),
                    );
                  }),
                  _buildGridItem(Icons.mail, 'Inbox Cuti/Izin', context, () {
                    //
                  }),
                  _buildGridItem(Icons.feedback, 'Inbox Feedback', context, () {
                    //
                  }),
                  _buildGridItem(Icons.history, 'History Absensi', context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryAdministrator()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 1, 88, 78)),
      title: Text(label,
          style: TextStyle(fontFamily: 'RobotoMono', color: Colors.teal)),
      onTap: () {},
    );
  }

  Widget _buildGridItem(
      IconData icon, String label, BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
          side: BorderSide(color: Colors.teal[600]!, width: 1.2),
        ),
        shadowColor: const Color.fromARGB(255, 57, 61, 61).withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 65, color: Colors.teal[600]),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                    fontSize: 16, fontFamily: 'RobotoMono', color: Colors.teal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
