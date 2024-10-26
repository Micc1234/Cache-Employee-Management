import 'package:flutter/material.dart';
import 'package:cache_employee_management/databases/database_helper.dart';

class HistoryAdministrator extends StatefulWidget {
  @override
  _HistoryAdministratorState createState() => _HistoryAdministratorState();
}

class _HistoryAdministratorState extends State<HistoryAdministrator> {
  DatabaseHelper1 dbHelper = DatabaseHelper1();
  List<Map<String, dynamic>> absensiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    await dbHelper.checkDatabase();
    await Future.delayed(Duration(seconds: 1));
    fetchAbsensi();
  }

  Future<void> fetchAbsensi() async {
    final data = await dbHelper.fetchAbsensiLengkap();
    setState(() {
      absensiList = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Absensi Karyawan',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : absensiList.isEmpty
              ? Center(child: Text('Tidak ada riwayat absensi'))
              : ListView.builder(
                  itemCount: absensiList.length,
                  itemBuilder: (context, index) {
                    final absensi = absensiList[absensiList.length - 1 - index];

                    return ListTile(
                      leading: Icon(
                        absensi['jenis'] == 'Check In'
                            ? Icons.login
                            : Icons.logout,
                        color: Colors.teal,
                      ),
                      title: Text(
                        absensi['nama'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(absensi['jenis']),
                          Text(absensi['datetime']),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
