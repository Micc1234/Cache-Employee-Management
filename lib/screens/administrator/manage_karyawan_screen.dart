import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cache_employee_management/databases/database_helper.dart';

class ManageKaryawan extends StatefulWidget {
  const ManageKaryawan({super.key});

  @override
  State<ManageKaryawan> createState() => _ManageKaryawanState();
}

class _ManageKaryawanState extends State<ManageKaryawan> {
  DatabaseHelper1 dbHelper = DatabaseHelper1();
  List<Map<String, dynamic>> karyawanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    await dbHelper.checkDatabase();
    await Future.delayed(Duration(seconds: 1));
    fetchKaryawan();
  }

  Future<void> fetchKaryawan() async {
    final data = await dbHelper.fetchKaryawan();
    setState(() {
      karyawanList = data;
      isLoading = false;
    });
  }

  Future<void> showAddKaryawanDialog() async {
    String nama = '';
    String email = '';
    String password = '';
    String jabatan = 'Staff';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Karyawan'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Nama'),
                    onChanged: (value) {
                      nama = value;
                    },
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: ['Staff', 'Administrator'].map((role) {
                      return ChoiceChip(
                        label: Text(role),
                        selected: jabatan == role,
                        onSelected: (selected) {
                          setState(() {
                            jabatan = selected ? role : jabatan;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: true,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nama.isNotEmpty &&
                    email.isNotEmpty &&
                    password.isNotEmpty) {
                  try {
                    // tambah ke firebase
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password);

                    // tambah ke sqflite
                    await dbHelper.insertKaryawan({
                      'nama': nama,
                      'jabatan': jabatan,
                      'email': email,
                      'password': password
                    });

                    fetchKaryawan();
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add karyawan: $e')),
                    );
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showEditKaryawanDialog(Map<String, dynamic> karyawan) async {
    String nama = karyawan['nama'];
    String email = karyawan['email'];
    String password = karyawan['password'];
    String jabatan = karyawan['jabatan'];

    User? currentUser = FirebaseAuth.instance.currentUser;
    String loggedInEmail = currentUser?.email ?? '';

    if (loggedInEmail == email && jabatan == 'Administrator') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Administrator tidak dapat mengedit data dirinya sendiri.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Karyawan'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Nama'),
                    onChanged: (value) {
                      nama = value;
                    },
                    controller: TextEditingController(text: nama),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: ['Staff', 'Administrator'].map((role) {
                      return ChoiceChip(
                        label: Text(role),
                        selected: jabatan == role,
                        onSelected: (selected) {
                          setState(() {
                            jabatan = selected ? role : jabatan;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) {
                      email = value;
                    },
                    controller: TextEditingController(text: email),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Password'),
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: true,
                    controller: TextEditingController(text: password),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nama.isNotEmpty &&
                    email.isNotEmpty &&
                    password.isNotEmpty) {
                  await dbHelper.updateKaryawan({
                    'nama': nama,
                    'jabatan': jabatan,
                    'email': email,
                    'password': password
                  }, karyawan['id']);

                  fetchKaryawan();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteConfirmationDialog(int id) async {
    Map<String, dynamic> karyawanToDelete =
        karyawanList.firstWhere((karyawan) => karyawan['id'] == id);
    String emailToDelete = karyawanToDelete['email'];
    String passwordToDelete = karyawanToDelete['password'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Karyawan'),
          content: Text('Apakah Anda yakin ingin menghapus data karyawan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailToDelete,
                    password: passwordToDelete,
                  );

                  // Hapus karyawan dari Firebase Auth
                  if (userCredential.user != null) {
                    await userCredential.user?.delete();

                    // Hapus data karyawan dari SQLite
                    await dbHelper.deleteKaryawan(id);

                    fetchKaryawan();
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus karyawan: $e')),
                  );
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDetailDialog(Map<String, dynamic> karyawan) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detail Karyawan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${karyawan['email']}'),
              Text('Password: ${karyawan['password']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
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
        title: Text('Manajemen Karyawan',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.bold,
            )),
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
          : karyawanList.isEmpty
              ? Center(child: Text('Anda belum menambahkan karyawan'))
              : ListView.builder(
                  itemCount: karyawanList.length,
                  itemBuilder: (context, index) {
                    final karyawan = karyawanList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          karyawan['nama'][0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.teal,
                      ),
                      title: Text(karyawan['nama']),
                      subtitle: Text(karyawan['jabatan']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => showEditKaryawanDialog(karyawan),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                showDeleteConfirmationDialog(karyawan['id']),
                          ),
                        ],
                      ),
                      onTap: () => showDetailDialog(karyawan),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddKaryawanDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
