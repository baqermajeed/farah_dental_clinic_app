import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Patient> _patients = [];
  List<Payment> _payments = [];
  bool _isLoading = false;

  // Getters
  List<Patient> get patients => _patients;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

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
}
