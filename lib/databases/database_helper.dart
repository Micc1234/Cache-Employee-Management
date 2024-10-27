import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DatabaseHelper1 {
  Database? database;
  String DATABASE_NAME = "DB KARYAWAN";
  int databaseVersion = 1;

  DatabaseHelper1() {
    checkDatabase();
  }

  Future<Database> checkDatabase() async {
    if (database != null) {
      database = database!;
    } else {
      database = await initDatabase();
    }
    return database!;
  }

  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(join(path, DATABASE_NAME),
        version: databaseVersion, onCreate: createDatabase);
  }

  Future<void> createDatabase(Database database, int version) async {
    await database.execute(
        'CREATE TABLE Karyawan (id INTEGER PRIMARY KEY, nama TEXT , jabatan TEXT , username TEXT, password TEXT)');
    await database.execute(
        ' CREATE TABLE Absensi (id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, jenis TEXT, datetime TEXT)');
  }

  Future<Map<String, dynamic>?> fetchByUsername(String username) async {
    final List<Map<String, dynamic>> results = await database!.query(
      "Karyawan",
      where: "username = ?",
      whereArgs: [username],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchKaryawan() async {
    List<Map<String, dynamic>> karyawan = await database!.query("Karyawan");
    String jsonData = jsonEncode(karyawan);

    const String jsonBinUrl = 'https://api.jsonbin.io/v3/b/671da842ad19ca34f8bf1faf'; // JSONBin endpoint
    const String jsonBinApiKey = '\$2a\$10\$goSXcOsCFquYNwo0bQDbeuqAisNKLxu4BVMeiG3z8gCDfgFeFTzbi'; // Your JSONBin API key

    try {
      final response = await http.put(
        Uri.parse(jsonBinUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': jsonBinApiKey,
        },
        body: jsonData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Data uploaded successfully: ${response.body}');
      } else {
        print('Failed to upload data. Status code: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }

    return karyawan;
  }

  Future<int> insertKaryawan(Map<String, dynamic> karyawan) async {
    int idKaryawan = await database!.insert("Karyawan", karyawan);
    return idKaryawan;
  }

  Future<int> updateKaryawan(Map<String, dynamic> karyawan, int id) async {
    int row = await database!.update(
      "Karyawan",
      karyawan,
      where: "id = ?",
      whereArgs: [id],
    );
    return row;
  }

  Future<int> deleteKaryawan(int id) async {
    int row = await database!.delete(
      "Karyawan",
      where: "id = ?",
      whereArgs: [id],
    );
    return row;
  }

  Future<List<Map<String, dynamic>>> fetchAbsensiLengkap() async {
    List<Map<String, dynamic>> absensi = await database!.query("Absensi");
    return absensi;
  }

  //Untuk halaman karyawan
  Future<List<Map<String, dynamic>>> fetchAbsensiKaryawan(String nama) async {
    List<Map<String, dynamic>> absensi = await database!.query(
      "Absensi",
      where: "nama = ?",
      whereArgs: [nama],
    );
    return absensi;
  }

  Future<int> insertAbsensi(Map<String, dynamic> absensi) async {
    int idAbsensi = await database!.insert("Absensi", absensi);
    return idAbsensi;
  }

  Future<int> deleteAbsensi(int id) async {
    int row = await database!.delete(
      "Absensi",
      where: "id = ?",
      whereArgs: [id],
    );
    return row;
  }
}
