import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // حالة تسجيل الدخول
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _currentUser;

  List<Patient> _patients = [];
  List<Payment> _payments = [];

  // Getters
  List<Patient> get patients => _patients;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;

  // إحصائيات عامة
  double get totalAmount {
    return _patients.fold(0.0, (sum, patient) => sum + patient.totalAmount);
  }

  double get paidAmount {
    return _payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double get remainingAmount {
    return totalAmount - paidAmount;
  }

  int get remainingBillsCount {
    return _patients.where((patient) => patient.remainingAmount > 0).length;
  }

  // تسجيل الدخول
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 1));

      // التحقق من بيانات تسجيل الدخول
      if (username == 'admin' && password == 'farah123') {
        _isLoggedIn = true;
        _currentUser = username;

        // حفظ حالة تسجيل الدخول
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUser', username);

        // تحميل البيانات
        await loadData();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _patients.clear();
    _payments.clear();

    // حذف حالة تسجيل الدخول
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('currentUser');

    notifyListeners();
  }

  // التحقق من حالة تسجيل الدخول المحفوظة
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final currentUser = prefs.getString('currentUser');

      if (isLoggedIn && currentUser != null) {
        _isLoggedIn = true;
        _currentUser = currentUser;
        await loadData();
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من حالة تسجيل الدخول: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // تحميل البيانات
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _databaseService.getPatients();
      _payments = await _databaseService.getPayments();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // إضافة مريض جديد
  Future<bool> addPatient(Patient patient) async {
    try {
      await _databaseService.insertPatient(patient);
      await loadData(); // إعادة تحميل البيانات
      return true;
    } catch (e) {
      debugPrint('Error adding patient: $e');
      return false;
    }
  }

  // إضافة دفعة جديدة
  Future<bool> addPayment(Payment payment) async {
    try {
      await _databaseService.insertPayment(payment);
      await loadData(); // إعادة تحميل البيانات
      return true;
    } catch (e) {
      debugPrint('Error adding payment: $e');
      return false;
    }
  }

  // الحصول على المرضى الذين لديهم تسديدات متأخرة
  List<Patient> getOverduePatients() {
    final now = DateTime.now();
    return _patients.where((patient) {
      if (patient.remainingAmount <= 0) return false;

      // حساب تاريخ التسديد القادم
      final nextPaymentDate = patient.registrationDate.add(Duration(
          days: 30 * (patient.totalMonths - patient.remainingMonths + 1)));

      return now.isAfter(nextPaymentDate);
    }).toList();
  }

  // الحصول على مدفوعات مريض معين
  List<Payment> getPatientPayments(String patientName) {
    return _payments
        .where((payment) => payment.patientName == patientName)
        .toList();
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    if (_isLoggedIn) {
      await loadData();
    }
  }
}
