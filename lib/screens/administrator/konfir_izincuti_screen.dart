import 'package:flutter/material.dart';
import 'package:cache_employee_management/databases/database_helper.dart';

class KonfirIzinCutiScreen extends StatefulWidget {
  @override
  _KonfirIzinCutiScreenState createState() => _KonfirIzinCutiScreenState();
}

class _KonfirIzinCutiScreenState extends State<KonfirIzinCutiScreen> {
  final DatabaseHelper1 dbHelper = DatabaseHelper1();
  late Future<List<Map<String, dynamic>>> izinCuti;

  @override
  void initState() {
    super.initState();
    _refreshIzinCuti();
  }

  Future<void> _refreshIzinCuti() async {
    setState(() {
      izinCuti = dbHelper.fetchIzinCuti();
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    await dbHelper.updateIzinCutiStatus(
        id, status); // Method baru untuk update status
    _refreshIzinCuti(); // Refresh data setelah update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Izin Cuti',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BFAE), Color(0xFF1DE9B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: izinCuti,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final izinCutiList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: izinCutiList.length,
            itemBuilder: (context, index) {
              final izin = izinCutiList[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4, // Menambahkan efek bayangan untuk kesan 3D
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Sudut membulat
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0), // Padding untuk jarak dalam
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              izin['nama'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8), // Jarak antara nama dan jenis
                            Text(
                              'Jenis: ${izin['jenis']}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              'Tanggal: ${izin['tanggalMulai']} - ${izin['tanggalSelesai']}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16), // Jarak antara detail dan status
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            izin['status'],
                            style: TextStyle(
                              color: izin['status'] == 'Menunggu'
                                  ? Colors.orange
                                  : (izin['status'] == 'Dikonfirmasi'
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ),
                          if (izin['status'] == 'Menunggu')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () =>
                                      _updateStatus(izin['id'], 'Diterima'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () =>
                                      _updateStatus(izin['id'], 'Ditolak'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
