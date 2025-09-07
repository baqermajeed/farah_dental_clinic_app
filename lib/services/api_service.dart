import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
        _token = data['access_token'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // تجميع الطلبات + كاش قصير لمنع التكرار
  static Future<List<Patient>>? _patientsInFlight;
  static List<Patient>? _patientsCache;
  static DateTime? _patientsAt;

  static Future<List<Payment>>? _paymentsInFlight;
  static List<Payment>? _paymentsCache;
  static DateTime? _paymentsAt;

  static Future<Statistics>? _statsInFlight;
  static Statistics? _statsCache;
  static DateTime? _statsAt;

  static bool _isFresh(DateTime? at, int ms) {
    if (at == null) return false;
    return DateTime.now().difference(at).inMilliseconds <= ms;
  }

  // (إزالة التجميع والكاش المؤقت للعودة للسلوك السابق)

  // معالجة الاستجابة والأخطاء (تُعيد dynamic لتدعم القوائم والكائنات)
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final bodyString = utf8.decode(response.bodyBytes);
      if (bodyString.isEmpty) return null;
      return json.decode(bodyString);
    } else {
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.body}',
        uri: response.request?.url,
      );
    }
  }

  // (إزالة /bootstrap)

  // ============ عمليات المرضى ============

  // جلب جميع المرضى
  static Future<List<Patient>> getAllPatients() async {
    // إعادة من الكاش لمدة 2000ms
    if (_patientsCache != null && _isFresh(_patientsAt, 2000)) {
      return _patientsCache!;
    }
    // مشاركة نفس الطلب إذا كان جارٍ
    if (_patientsInFlight != null) return _patientsInFlight!;
    _patientsInFlight = (() async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/patients/'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 10));

        final dynamic responseData = _handleResponse(response);
        final List<dynamic> data = responseData is List ? responseData : [];
        final result = data.map((json) => Patient.fromJson(json)).toList();
        _patientsCache = result;
        _patientsAt = DateTime.now();
        return result;
      } catch (e) {
        throw Exception('فشل في جلب بيانات المرضى: $e');
      } finally {
        _patientsInFlight = null;
      }
    })();
    return _patientsInFlight!;
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
      return Patient.fromJson(data);
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

  // جلب المرضى المتأخرين
  static Future<List<Patient>> getOverduePatients() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/patients/overdue'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final dynamic responseData = _handleResponse(response);
      final List<dynamic> data = responseData is List ? responseData : [];
      return data.map((json) => Patient.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المرضى المتأخرين: $e');
    }
  }

  // جلب المرضى الذين لديهم مبالغ متبقية للدفع
  static Future<List<Patient>> getPatientsWithPendingPayments() async {
    // dedupe + tiny cache to avoid hammering endpoint
    // static in-flight future
    return _PendingPaymentsSingleton.instance.fetch(() async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/patients/pending-payments'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 10));

        final dynamic responseData = _handleResponse(response);
        final List<dynamic> data = responseData is List ? responseData : [];
        return data.map((json) => Patient.fromJson(json)).toList();
      } catch (e) {
        throw Exception('فشل في جلب المرضى الذين لديهم مبالغ متبقية: $e');
      }
    });
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
        return null; // المريض غير موجود
      }

      final dynamic responseData = _handleResponse(response);
      return Patient.fromJson(responseData);
    } catch (e) {
      throw Exception('فشل في البحث عن المريض: $e');
    }
  }

  // ============ عمليات الدفعات ============

  // جلب جميع الدفعات
  static Future<List<Payment>> getAllPayments() async {
    if (_paymentsCache != null && _isFresh(_paymentsAt, 2000)) {
      return _paymentsCache!;
    }
    if (_paymentsInFlight != null) return _paymentsInFlight!;
    _paymentsInFlight = (() async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/payments/'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 10));

        final dynamic responseData = _handleResponse(response);
        final List<dynamic> data = responseData is List ? responseData : [];
        final result = data.map((json) => Payment.fromJson(json)).toList();
        _paymentsCache = result;
        _paymentsAt = DateTime.now();
        return result;
      } catch (e) {
        throw Exception('فشل في جلب بيانات الدفعات: $e');
      } finally {
        _paymentsInFlight = null;
      }
    })();
    return _paymentsInFlight!;
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

      return _handleResponse(response);
    } catch (e) {
      throw Exception('فشل في إضافة الدفعة: $e');
    }
  }

  // جلب دفعات مريض معين
  static Future<List<Payment>> getPatientPayments(String patientName) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/payments/${Uri.encodeComponent(patientName)}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final dynamic responseData = _handleResponse(response);
      final List<dynamic> data = responseData is List ? responseData : [];
      return data.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب دفعات المريض: $e');
    }
  }

  // ============ الإحصائيات ============

  // جلب الإحصائيات العامة
  static Future<Statistics> getStatistics() async {
    if (_statsCache != null && _isFresh(_statsAt, 2000)) {
      return _statsCache!;
    }
    if (_statsInFlight != null) return _statsInFlight!;
    _statsInFlight = (() async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/statistics'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 10));

        final data = _handleResponse(response);
        final result = Statistics.fromJson(data as Map<String, dynamic>);
        _statsCache = result;
        _statsAt = DateTime.now();
        return result;
      } catch (e) {
        throw Exception('فشل في جلب الإحصائيات: $e');
      } finally {
        _statsInFlight = null;
      }
    })();
    return _statsInFlight!;
  }

  // ============ التقارير ============

  // تحميل تقرير PDF لمريض
  static Future<List<int>> getPatientReport(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/form/$patientId'),
        headers: {'Accept': 'application/pdf'},
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

  // ============ اختبار الاتصال ============

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
    } catch (e) {
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
      return data['message'] ?? 'API Ready';
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
}

class _PendingPaymentsSingleton<T> {
  static final _PendingPaymentsSingleton<List<Patient>> instance =
      _PendingPaymentsSingleton<List<Patient>>._();

  _PendingPaymentsSingleton._();

  Future<T>? _inFlight;
  T? _cache;
  DateTime? _at;

  Future<T> fetch(Future<T> Function() producer) {
    // 2s cache window
    if (_cache != null &&
        _at != null &&
        DateTime.now().difference(_at!).inMilliseconds <= 2000) {
      return Future.value(_cache as T);
    }
    if (_inFlight != null) return _inFlight!;
    _inFlight = (() async {
      try {
        final res = await producer();
        _cache = res;
        _at = DateTime.now();
        return res;
      } finally {
        _inFlight = null;
      }
    })();
    return _inFlight!;
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

  @override
  String toString() {
    return 'Statistics(patients: $totalPatients, total: $totalAmount, paid: $paidAmount)';
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
          .map((e) => Patient.fromJson(e))
          .toList(),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => Payment.fromJson(e))
          .toList(),
      statistics:
          Statistics.fromJson(json['statistics'] as Map<String, dynamic>),
    );
  }
}

// (إزالة BootstrapData)
