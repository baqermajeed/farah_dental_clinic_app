import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../models/payment.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  // حالة تسجيل الدخول
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _currentUser;
  String? _errorMessage;
  bool _isApiConnected = false;
  bool _isFetching = false; // قفل لمنع تكرار التحميل

  List<Patient> _patients = [];
  List<Payment> _payments = [];
  Statistics? _statistics;

  // Getters
  List<Patient> get patients => _patients;
  List<Payment> get payments => _payments;
  Statistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isApiConnected => _isApiConnected;

  // إحصائيات محلية (كبديل إذا فشل API)
  double get totalAmount {
    return _statistics?.totalAmount ?? 
           _patients.fold(0.0, (sum, patient) => sum + patient.totalAmount);
  }

  double get paidAmount {
    return _statistics?.paidAmount ?? 
           _patients.fold(0.0, (sum, patient) => sum + patient.paidAmount);
  }

  double get remainingAmount {
    return _statistics?.remainingAmount ?? (totalAmount - paidAmount);
  }

  int get remainingBillsCount {
    return _patients.where((patient) => patient.remainingAmount > 0).length;
  }

  int get overdueCount {
    return _statistics?.overduePatients ?? 
           _patients.where((patient) => patient.isOverdue).length;
  }

  // تسجيل الدخول
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 1));

      // التحقق من بيانات تسجيل الدخول
      if (username == 'farah' && password == 'farah12345') {
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

  // اختبار الاتصال بـ API
  Future<void> checkApiConnection() async {
    try {
      final connected = await ApiService.testConnection();
      if (connected != _isApiConnected) {
        _isApiConnected = connected;
        notifyListeners();
      } else {
        _isApiConnected = connected;
      }
    } catch (e) {
      _isApiConnected = false;
      debugPrint('خطأ في اختبار API: $e');
    }
  }

  // تحميل البيانات من API
  Future<void> loadData() async {
    if (_isFetching) return; // تجاهل إذا كان هناك تحميل جارٍ
    _isFetching = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // اختبار الاتصال أولاً
      await checkApiConnection();
      
      if (_isApiConnected) {
        // تحميل من API
        _patients = await ApiService.getAllPatients();
        _payments = await ApiService.getAllPayments();
        _statistics = await ApiService.getStatistics();
      } else {
        throw Exception('لا يمكن الاتصال بالخادم');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    _isFetching = false;
    notifyListeners();
  }

  // إضافة مريض جديد
  Future<bool> addPatient(Patient patient) async {
    try {
      if (_isApiConnected) {
        final ok = await ApiService.addPatient(patient);
        // تحديث متفائل: أضف محلياً ليظهر فوراً
        _patients = List<Patient>.from(_patients)..add(ok);
        notifyListeners();
      } else {
        // إضافة محلية إذا لم يكن هناك اتصال
        _patients.add(patient);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'خطأ في إضافة المريض: ${e.toString()}';
      debugPrint('Error adding patient: $e');
      notifyListeners();
      return false;
    }
  }

  // تحديث بيانات مريض
  Future<bool> updatePatient(Patient patient) async {
    if (patient.id == null) return false;
    
    try {
      await ApiService.updatePatient(patient.id!, patient);
      await loadData(); // إعادة تحميل البيانات
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating patient: $e');
      notifyListeners();
      return false;
    }
  }

  // حذف مريض
  Future<bool> deletePatient(String patientId) async {
    try {
      await ApiService.deletePatient(patientId);
      await loadData(); // إعادة تحميل البيانات
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error deleting patient: $e');
      notifyListeners();
      return false;
    }
  }

  // إضافة دفعة جديدة
  Future<bool> addPayment(Payment payment) async {
    try {
      await ApiService.addPayment(payment);
      await loadData(); // إعادة تحميل البيانات
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error adding payment: $e');
      notifyListeners();
      return false;
    }
  }

  // الحصول على المرضى المتأخرين
  Future<List<Patient>> getOverduePatients() async {
    try {
      return await ApiService.getOverduePatients();
    } catch (e) {
      debugPrint('Error getting overdue patients: $e');
      // استخدام البيانات المحلية كبديل
      return _patients.where((patient) => patient.isOverdue).toList();
    }
  }

  // الحصول على المرضى الذين لديهم مبالغ متبقية للدفع
  Future<List<Patient>> getPatientsWithPendingPayments() async {
    try {
      return await ApiService.getPatientsWithPendingPayments();
    } catch (e) {
      debugPrint('Error getting patients with pending payments: $e');
      // استخدام البيانات المحلية كبديل
      return _patients.where((patient) => patient.remainingAmount > 0).toList();
    }
  }

  // البحث عن مريض بالاسم
  Future<Patient?> searchPatientByName(String name) async {
    try {
      return await ApiService.searchPatientByName(name);
    } catch (e) {
      debugPrint('Error searching for patient: $e');
      // استخدام البيانات المحلية كبديل
      try {
        return _patients.firstWhere(
          (patient) => patient.name.toLowerCase().contains(name.toLowerCase()),
        );
      } catch (e) {
        return null;
      }
    }
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
