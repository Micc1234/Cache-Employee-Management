import 'dart:async';
import 'package:cache_employee_management/databases/database_helper.dart';
import 'package:cache_employee_management/screens/karyawan/history_karyawan_screen.dart';
import 'package:cache_employee_management/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class KaryawanHome extends StatefulWidget {
  final String name;
  final String role;

  KaryawanHome({required this.name, required this.role});

  @override
  State<KaryawanHome> createState() => _KaryawanHomeState();
}

class _KaryawanHomeState extends State<KaryawanHome> {
  final DatabaseHelper1 dbHelper = DatabaseHelper1();
  String currentTime = '';
  bool isCheckIn = false;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateFormat('dd/MM/yyyy, HH:mm:ss').format(DateTime.now());
      });
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _checkIn() async {
    await _recordAbsensi('Check In');
  }

  Future<void> _checkOut() async {
    await _recordAbsensi('Check Out');
  }

  Future<void> _recordAbsensi(String type) async {
    setState(() {
      isChecked = true;
      isCheckIn = type == 'Check In';
    });

    await dbHelper.insertAbsensi({
      'nama': widget.name,
      'jenis': type,
      'datetime': currentTime,
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$type Success'),
          content: Text('$type untuk ${widget.name} berhasil.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isChecked = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
            onPressed: _logout,
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
            Text(
              currentTime,
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'RobotoMono',
                  color: const Color.fromARGB(255, 2, 86, 78),
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: EdgeInsets.all(15),
                children: [
                  _buildGridItem(Icons.login, 'Check In', () {
                    if (!isChecked) {
                      _checkIn();
                    }
                  }),
                  _buildGridItem(Icons.logout, 'Check Out', () {
                    if (!isChecked) {
                      _checkOut();
                    }
                  }),
                  _buildGridItem(
                      Icons.airplane_ticket, 'Pengajuan Cuti/Izin', () {}),
                  _buildGridItem(Icons.feedback, 'Feedback', () {}),
                  _buildGridItem(Icons.history, 'History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HistoryKaryawanScreen(name: widget.name),
                      ),
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

  Widget _buildGridItem(IconData icon, String label, VoidCallback onTap) {
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
