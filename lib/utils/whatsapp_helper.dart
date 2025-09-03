import 'package:url_launcher/url_launcher.dart';
import '../models/patient.dart';
import 'package:intl/intl.dart';

class WhatsAppHelper {
  // إرسال رسالة تذكير بالتسديد المتأخر
  static Future<bool> sendOverduePaymentReminder({
    required Patient patient,
    required double remainingAmount,
    required double monthlyAmount,
    required int overdueDays,
  }) async {
    final message = _createOverduePaymentMessage(
      patientName: patient.name,
      remainingAmount: remainingAmount,
      monthlyAmount: monthlyAmount,
      overdueDays: overdueDays,
    );
    
    return await _sendWhatsAppMessage(patient.phoneNumber, message);
  }

  // إرسال رسالة تذكير بموعد
  static Future<bool> sendAppointmentReminder({
    required Patient patient,
    required DateTime appointmentDate,
    String? additionalNotes,
  }) async {
    final message = _createAppointmentMessage(
      patientName: patient.name,
      appointmentDate: appointmentDate,
      additionalNotes: additionalNotes,
    );
    
    return await _sendWhatsAppMessage(patient.phoneNumber, message);
  }

  // إرسال رسالة عامة للمريض
  static Future<bool> sendGeneralMessage({
    required Patient patient,
    required String message,
  }) async {
    return await _sendWhatsAppMessage(patient.phoneNumber, message);
  }

  // إنشاء رسالة التذكير بالتسديد المتأخر
  static String _createOverduePaymentMessage({
    required String patientName,
    required double remainingAmount,
    required double monthlyAmount,
    required int overdueDays,
  }) {
    return '''
السلام عليكم ورحمة الله وبركاته

الأستاذ/ة المحترم/ة $patientName

نحيطكم علماً بأن لديكم تأخير في التسديد الشهري لعيادة فرح لطب الأسنان.

📅 عدد الأيام المتأخرة: $overdueDays يوم
💰 القسط الشهري المستحق: ${monthlyAmount.toStringAsFixed(0)} دينار
💳 المبلغ المتبقي الإجمالي: ${remainingAmount.toStringAsFixed(0)} دينار

نرجو منكم التواصل معنا لتسوية المبلغ المستحق في أقرب وقت ممكن.

شكراً لتفهمكم وتعاونكم
عيادة فرح لطب الأسنان
    '''.trim();
  }

  // إنشاء رسالة تذكير بالموعد
  static String _createAppointmentMessage({
    required String patientName,
    required DateTime appointmentDate,
    String? additionalNotes,
  }) {
    final formattedDate = DateFormat('yyyy/MM/dd').format(appointmentDate);
    final formattedTime = DateFormat('HH:mm').format(appointmentDate);
    
    String message = '''
السلام عليكم ورحمة الله وبركاته

الأستاذ/ة المحترم/ة $patientName

نذكركم بموعدكم في عيادة فرح لطب الأسنان:

📅 التاريخ: $formattedDate
🕐 الوقت: $formattedTime

نرجو الحضور في الوقت المحدد، وفي حالة عدم التمكن من الحضور يرجى إبلاغنا مسبقاً.
    '''.trim();

    if (additionalNotes != null && additionalNotes.isNotEmpty) {
      message += '\n\n📝 ملاحظات إضافية:\n$additionalNotes';
    }

    message += '\n\nشكراً لتفهمكم\nعيادة فرح لطب الأسنان';
    
    return message;
  }

  // إرسال رسالة الواتساب
  static Future<bool> _sendWhatsAppMessage(String phoneNumber, String message) async {
    try {
      // تنسيق رقم الهاتف (إزالة المسافات والأحرف غير المرغوبة)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // إذا كان الرقم لا يبدأ بـ +، نضيف كود العراق +964
      if (!cleanPhone.startsWith('+')) {
        if (cleanPhone.startsWith('0')) {
          cleanPhone = '+964${cleanPhone.substring(1)}';
        } else if (!cleanPhone.startsWith('964')) {
          cleanPhone = '+964$cleanPhone';
        } else {
          cleanPhone = '+$cleanPhone';
        }
      }

      // ترميز الرسالة للURL
      final encodedMessage = Uri.encodeComponent(message);
      
      // إنشاء رابط الواتساب
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';
      
      // فتح الواتساب
      final Uri uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('لا يمكن فتح الواتساب للرقم: $phoneNumber');
        return false;
      }
    } catch (e) {
      print('خطأ في إرسال رسالة الواتساب: $e');
      return false;
    }
  }

  // التحقق من صحة رقم الهاتف
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  // تنسيق رقم الهاتف للعرض
  static String formatPhoneNumber(String phoneNumber) {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleanPhone.startsWith('+964')) {
      // تنسيق الأرقام العراقية
      final number = cleanPhone.substring(4);
      if (number.length == 10) {
        return '+964 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
      }
    }
    
    return phoneNumber;
  }
}
