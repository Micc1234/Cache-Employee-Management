import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class RekapAbsensiScreen extends StatelessWidget {
  final List<User> users;

  RekapAbsensiScreen({required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Absensi'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.nama),
            subtitle: Text(user.jabatan),
          );
        },
      ),
    );
  }
}
