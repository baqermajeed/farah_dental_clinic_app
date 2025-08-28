import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
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
    String dbPath = path.join(await getDatabasesPath(), 'dental_clinic.db');

    return await openDatabase(
      dbPath,
      version: 4, // نسخة جديدة تشمل كل الأعمدة
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // جدول المرضى
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        totalMonths INTEGER NOT NULL,
        phoneNumber TEXT NOT NULL,
        address TEXT,
        treatmentType TEXT,
        registrationDate INTEGER NOT NULL,
        paidAmount REAL DEFAULT 0.0,
        paymentDayOfMonth INTEGER,
        notes TEXT
      )
    ''');

    // جدول المدفوعات
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientName TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentDate INTEGER NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE patients ADD COLUMN address TEXT;");
      await db.execute("ALTER TABLE patients ADD COLUMN treatmentType TEXT;");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE payments ADD COLUMN notes TEXT;");
    }
    if (oldVersion < 4) {
      await db.execute(
          "ALTER TABLE patients ADD COLUMN paymentDayOfMonth INTEGER;");
      await db.execute("ALTER TABLE patients ADD COLUMN notes TEXT;");
    }
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

    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
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
    return await db.transaction((txn) async {
      final paymentId = await txn.insert('payments', payment.toMap());
      await _updatePatientPaidAmountInTransaction(txn, payment.patientName);
      return paymentId;
    });
  }

  // الحصول على جميع المدفوعات
  Future<List<Payment>> getPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('payments', orderBy: 'paymentDate DESC');
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  // تحديث المبلغ المدفوع للمريض
  Future<void> _updatePatientPaidAmount(String patientName) async {
    final db = await database;
    await _updatePatientPaidAmountInTransaction(db, patientName);
  }

  Future<void> _updatePatientPaidAmountInTransaction(
      DatabaseExecutor db, String patientName) async {
    final result = await db.rawQuery('''
      SELECT SUM(amount) as totalPaid
      FROM payments
      WHERE patientName = ?
    ''', [patientName]);

    final totalPaid = result.first['totalPaid'] as double? ?? 0.0;

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
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }
}
