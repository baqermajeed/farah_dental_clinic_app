import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/payment.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dental_clinic.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // إنشاء جدول المرضى
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        totalMonths INTEGER NOT NULL,
        phoneNumber TEXT NOT NULL,
        registrationDate INTEGER NOT NULL,
        paidAmount REAL DEFAULT 0.0
      )
    ''');

    // إنشاء جدول المدفوعات
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientName TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentDate INTEGER NOT NULL
      )
    ''');
  }

  // إدراج مريض جديد
  Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  // الحصول على جميع المرضى
  Future<List<Patient>> getPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patients');

    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }

  // تحديث بيانات مريض
  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  // إدراج دفعة جديدة
  Future<int> insertPayment(Payment payment) async {
    final db = await database;

    // إدراج الدفعة
    final paymentId = await db.insert('payments', payment.toMap());

    // تحديث المبلغ المدفوع للمريض
    await _updatePatientPaidAmount(payment.patientName);

    return paymentId;
  }

  // الحصول على جميع المدفوعات
  Future<List<Payment>> getPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  // تحديث المبلغ المدفوع للمريض
  Future<void> _updatePatientPaidAmount(String patientName) async {
    final db = await database;

    // حساب إجمالي المبلغ المدفوع
    final result = await db.rawQuery('''
      SELECT SUM(amount) as totalPaid 
      FROM payments 
      WHERE patientName = ?
    ''', [patientName]);

    final totalPaid = result.first['totalPaid'] as double? ?? 0.0;

    // تحديث المريض
    await db.update(
      'patients',
      {'paidAmount': totalPaid},
      where: 'name = ?',
      whereArgs: [patientName],
    );
  }

  // الحصول على مدفوعات مريض معين
  Future<List<Payment>> getPatientPayments(String patientName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'patientName = ?',
      whereArgs: [patientName],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }
}
