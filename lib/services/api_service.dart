import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/patient.dart';
import '../models/payment.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static Map<String, String> get headers {
    if (_token != null) {
      return {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $_token',
      };
    }
    return ApiConfig.defaultHeaders;
  }

  static String? _token;
  static const String _tokenKey = 'auth_token';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // حفظ/استرجاع/مسح التوكن
  static Future<void> saveToken(String token) async {
    _token = token;
    try {
      // احفظ في التخزين الآمن أولاً
      await _secureStorage.write(key: _tokenKey, value: token);
      // كنسخ احتياطي للأجهزة غير المدعومة فقط
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {
      // تجاهل أخطاء التخزين المحلي
    }
  }

  static Future<void> loadToken() async {
    try {
      // حاول من التخزين الآمن أولاً
      _token = await _secureStorage.read(key: _tokenKey);
      if (_token == null || _token!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString(_tokenKey);
      }
    } catch (_) {
      _token = null;
    }
  }

  static Future<void> clearToken() async {
    _token = null;
    try {
      await _secureStorage.delete(key: _tokenKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {
      // تجاهل
    }
  }

  static bool get hasToken => _token != null && _token!.isNotEmpty;

  // تسجيل الدخول وجلب التوكن
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({'username': username, 'password': password}),
      );
      final data = _handleResponse(response);
      if (data != null && data['access_token'] != null) {
        await saveToken(data['access_token']);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final bodyString = utf8.decode(response.bodyBytes);
      if (bodyString.isEmpty) return null;
      return json.decode(bodyString);
    } else {
      // التعامل الموحّد مع 401/403
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw HttpException(
          'UNAUTHORIZED: ${response.statusCode}: ${response.body}',
          uri: response.request?.url,
        );
      }
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.body}',
        uri: response.request?.url,
      );
    }
  }

  // اختبار اتصال API
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // جلب رسالة الترحيب
  static Future<String> getWelcomeMessage() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      final data = _handleResponse(response);
      if (data is Map<String, dynamic>) {
        return data['message'] ?? 'API Ready';
      }
      return 'API Ready';
    } catch (e) {
      throw Exception('فشل في الاتصال بالخادم: $e');
    }
  }

  // جلب جميع البيانات دفعة واحدة (bootstrap)
  static Future<BootstrapData> getBootstrapData() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/bootstrap'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      final dynamic data = _handleResponse(response);
      return BootstrapData.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في جلب بيانات النظام: $e');
    }
  }

  // البحث عن مريض بالاسم
  static Future<Patient?> searchPatientByName(String name) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/patients/search/${Uri.encodeComponent(name)}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        return null;
      }
      final dynamic responseData = _handleResponse(response);
      if (responseData == null) return null;
      return Patient.fromJson(responseData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في البحث عن المريض: $e');
    }
  }

  // إضافة دفعة جديدة
  static Future<Map<String, dynamic>> addPayment(Payment payment) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/payments/'),
            headers: headers,
            body: json.encode(payment.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل في إضافة الدفعة: $e');
    }
  }

  // إضافة مريض جديد
  static Future<Patient> addPatient(Patient patient) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/patients/'),
            headers: headers,
            body: json.encode(patient.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      final data = _handleResponse(response);
      return Patient.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('فشل في إضافة المريض: $e');
    }
  }

  // تحديث بيانات مريض
  static Future<void> updatePatient(String patientId, Patient patient) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/patients/$patientId'),
            headers: headers,
            body: json.encode(patient.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      _handleResponse(response);
    } catch (e) {
      throw Exception('فشل في تحديث بيانات المريض: $e');
    }
  }

  // حذف مريض
  static Future<void> deletePatient(String patientId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/patients/$patientId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      _handleResponse(response);
    } catch (e) {
      throw Exception('فشل في حذف المريض: $e');
    }
  }

  // تحميل تقرير PDF لمريض
  static Future<List<int>> getPatientReport(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/form/$patientId'),
        headers: {'Accept': 'application/pdf', ...headers},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.body}',
          uri: response.request?.url,
        );
      }
    } catch (e) {
      throw Exception('فشل في تحميل التقرير: $e');
    }
  }

  // جلب المرضى المتأخرين
  static Future<List<Patient>> getOverduePatients() async {
    try {
      // محاولة استدعاء نقطة نهاية مخصصة إذا كانت متاحة على الخادم
      final response = await http
          .get(
            Uri.parse('$baseUrl/patients/overdue'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final dynamic data = _handleResponse(response);
      if (data is List) {
        return data
            .map((e) => Patient.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // إذا لم تكن الاستجابة بالشكل المتوقع، انتقل لحساب محلي عبر bootstrap
      throw const FormatException('Unexpected response format');
    } catch (_) {
      // فallback: استخدام bootstrap ثم التصفية محلياً
      final bootstrap = await getBootstrapData();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final List<Patient> overdue = bootstrap.patients.where((p) {
        if (p.remainingAmount <= 0) return false;
        final DateTime nextDate =
            p.nextPaymentDate ?? p.calculatedNextPaymentDate;
        return !nextDate.isAfter(today);
      }).toList()
        ..sort((a, b) {
          final int cmpDays = b.daysOverdue.compareTo(a.daysOverdue);
          if (cmpDays != 0) return cmpDays;
          return b.remainingAmount.compareTo(a.remainingAmount);
        });
      return overdue;
    }
  }

  // جلب المرضى الذين لديهم مبالغ متبقية للدفع
  static Future<List<Patient>> getPatientsWithPendingPayments() async {
    try {
      // إذا كانت نقطة النهاية متاحة على الخادم
      final response = await http
          .get(
            Uri.parse('$baseUrl/patients/pending-payments'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final dynamic data = _handleResponse(response);
      if (data is List) {
        return data
            .map((e) => Patient.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // استمرار إلى الفallback إذا كان الشكل غير متوقع
      throw const FormatException('Unexpected response format');
    } catch (_) {
      // فallback: جلب bootstrap والتصفية محلياً
      final bootstrap = await getBootstrapData();
      final List<Patient> pending = bootstrap.patients
          .where((p) => p.remainingAmount > 0)
          .toList()
        ..sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
      return pending;
    }
  }
}

// نموذج للإحصائيات
class Statistics {
  final int totalPatients;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final int overduePatients;

  Statistics({
    required this.totalPatients,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.overduePatients,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalPatients: json['total_patients'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      overduePatients: json['overdue_patients'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_patients': totalPatients,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'remaining_amount': remainingAmount,
        'overdue_patients': overduePatients,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}

// نموذج بيانات bootstrap
class BootstrapData {
  final List<Patient> patients;
  final List<Payment> payments;
  final Statistics statistics;

  BootstrapData({
    required this.patients,
    required this.payments,
    required this.statistics,
  });

  factory BootstrapData.fromJson(Map<String, dynamic> json) {
    return BootstrapData(
      patients: (json['patients'] as List<dynamic>)
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
      statistics:
          Statistics.fromJson(json['statistics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'patients': patients.map((p) => p.toJson()).toList(),
        'payments': payments.map((p) => p.toJson()).toList(),
        'statistics': statistics.toJson(),
      };
}
