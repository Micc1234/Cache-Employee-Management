import 'package:flutter/material.dart';
import 'package:cache_employee_management/databases/database_helper.dart';

class PengajuanCutiScreen extends StatefulWidget {
  final String name;

  PengajuanCutiScreen({required this.name});

  @override
  _PengajuanCutiScreenState createState() => _PengajuanCutiScreenState();
}

class _PengajuanCutiScreenState extends State<PengajuanCutiScreen> {
  final DatabaseHelper1 dbHelper = DatabaseHelper1();
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalSelesaiController =
      TextEditingController();

  String? selectedJenisCuti;

  final List<String> jenisCutiOptions = [
    'Izin Sakit',
    'Cuti Harian',
    'Cuti Mingguan',
    'Cuti Bulanan',
    'Cuti Tahunan'
  ];

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if (mounted) {
        setState(() {
          controller.text = pickedDate.toLocal().toString().split(' ')[0];
        });
      }
    }
  }

  Future<void> _submitPengajuanCuti() async {
    if (selectedJenisCuti == null ||
        tanggalMulaiController.text.isEmpty ||
        tanggalSelesaiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan lengkapi semua kolom.')),
      );
      return;
    }

    await dbHelper.insertIzinCuti({
      'nama': widget.name,
      'jenis': selectedJenisCuti,
      'tanggalMulai': tanggalMulaiController.text,
      'tanggalSelesai': tanggalSelesaiController.text,
      'status': 'Menunggu',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengajuan Cuti Sedang Dikonfirmasi')),
      );

      // Clear input fields and reset state
      tanggalMulaiController.clear();
      tanggalSelesaiController.clear();
      setState(() {
        selectedJenisCuti = null; // Reset the selected type
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPengajuanCuti() async {
    return await dbHelper.fetchIzinCuti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengajuan Cuti',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFFb2ebf2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedJenisCuti,
              hint: Text('Pilih Jenis Izin Cuti'),
              items: jenisCutiOptions.map((String jenis) {
                return DropdownMenuItem<String>(
                  value: jenis,
                  child: Text(jenis),
                );
              }).toList(),
              onChanged: (newValue) {
                if (mounted) {
                  setState(() {
                    selectedJenisCuti = newValue;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Jenis Izin Cuti',
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              ),
            ),
            SizedBox(height: 16),
            _buildDateField(tanggalMulaiController, 'Tanggal Mulai'),
            SizedBox(height: 16),
            _buildDateField(tanggalSelesaiController, 'Tanggal Selesai'),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitPengajuanCuti,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: Color(0xFF00BFAE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ), // Button color
                ),
                child: Text('Ajukan Cuti', style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Daftar Pengajuan Cuti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchPengajuanCuti(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final pengajuanCutiList = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: pengajuanCutiList.length,
                      itemBuilder: (context, index) {
                        final pengajuan = pengajuanCutiList[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 8, // Add elevation for shadow effect
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text('${pengajuan['jenis']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Dari: ${pengajuan['tanggalMulai']} - Sampai: ${pengajuan['tanggalSelesai']}'),
                            trailing: Text('${pengajuan['status']}',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context, controller),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      ),
    );
  }
}
