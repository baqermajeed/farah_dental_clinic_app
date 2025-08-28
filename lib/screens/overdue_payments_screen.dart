import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/patient.dart';
import '../models/payment.dart';

class OverduePaymentsScreen extends StatefulWidget {
  const OverduePaymentsScreen({super.key});

  @override
  State<OverduePaymentsScreen> createState() => _OverduePaymentsScreenState();
}

class _OverduePaymentsScreenState extends State<OverduePaymentsScreen> {
  Map<String, TextEditingController> _notesControllers = {};
  Map<String, String> _savedNotes = {}; // لحفظ الملاحظات

  @override
  void dispose() {
    for (var controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // حفظ الملاحظة
  void _saveNote(String patientName, String note) {
    setState(() {
      _savedNotes[patientName] = note;
    });
    // هنا يمكن إضافة كود لحفظ الملاحظة في قاعدة البيانات
  }

  // حساب عدد الأيام المتأخرة
  int _calculateOverdueDays(Patient patient, List<Payment> payments) {
    final patientPayments =
        payments.where((p) => p.patientName == patient.name).toList();
    patientPayments.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    // حساب عدد الأشهر المنقضية منذ التسجيل
    final monthsSinceRegistration =
        DateTime.now().difference(patient.registrationDate).inDays ~/ 30;

    // عدد الدفعات المطلوبة حتى الآن
    final expectedPayments = monthsSinceRegistration;

    // عدد الدفعات الفعلية
    final actualPayments = patientPayments.length;

    if (actualPayments < expectedPayments && expectedPayments > 0) {
      // حساب تاريخ آخر دفعة مطلوبة
      final lastExpectedPaymentDate = DateTime(
        patient.registrationDate.year,
        patient.registrationDate.month + expectedPayments,
        patient.registrationDate.day,
      );

      // إذا كان التاريخ الحالي بعد تاريخ الدفعة المطلوبة
      if (DateTime.now().isAfter(lastExpectedPaymentDate)) {
        return DateTime.now().difference(lastExpectedPaymentDate).inDays;
      }
    }

    return 0;
  }

  // الحصول على المرضى المتأخرين
  List<Patient> _getOverduePatients(
      List<Patient> patients, List<Payment> payments) {
    return patients.where((patient) {
      final overdueDays = _calculateOverdueDays(patient, payments);
      return overdueDays > 0;
    }).toList();
  }

  // حساب المبلغ المتبقي للمريض
  double _getRemainingAmount(Patient patient, List<Payment> payments) {
    final patientPayments =
        payments.where((p) => p.patientName == patient.name).toList();
    final totalPaid =
        patientPayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    return patient.totalAmount - totalPaid;
  }

  // حساب المبلغ الشهري
  double _getMonthlyAmount(Patient patient) {
    return patient.totalAmount / patient.installmentMonths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE9),
      appBar: AppBar(
        title: const Text(
          'التسديدات المتأخرة للمراجعين',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF649FCC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final overduePatients =
              _getOverduePatients(appProvider.patients, appProvider.payments);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // الجدول الرئيسي
                _buildOverdueTable(overduePatients, appProvider.payments),

                const SizedBox(height: 24),

                // كارتات الإحصائيات
                _buildStatisticsCards(overduePatients, appProvider.payments),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverdueTable(
      List<Patient> overduePatients, List<Payment> payments) {
    if (overduePatients.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // عنوان الجدول
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF649FCC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'المراجعين المتأخرين في التسديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${overduePatients.length} مريض',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // رؤوس الأعمدة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD0EBFF),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5), // اسم المراجع
                1: FlexColumnWidth(2), // تاريخ التسجيل
                2: FlexColumnWidth(1.5), // عدد الأيام المتأخرة
                3: FlexColumnWidth(2), // المبلغ المتبقي
                4: FlexColumnWidth(2), // القسط المستحق
                5: FlexColumnWidth(2), // رقم الهاتف
                6: FlexColumnWidth(3), // الملاحظات
              },
              children: [
                TableRow(
                  children: [
                    _buildTableHeader('اسم المراجع'),
                    _buildTableHeader('تاريخ تسجيل\nالاستمارة'),
                    _buildTableHeader('عدد الأيام\nالمتأخرة'),
                    _buildTableHeader('المبلغ المتبقي'),
                    _buildTableHeader('القسط المستحق'),
                    _buildTableHeader('رقم الهاتف'),
                    _buildTableHeader('الملاحظة'),
                  ],
                ),
              ],
            ),
          ),

          // بيانات الجدول
          ...overduePatients.asMap().entries.map((entry) {
            final index = entry.key;
            final patient = entry.value;
            return _buildTableRow(patient, payments, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF649FCC),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(Patient patient, List<Payment> payments, int index) {
    final overdueDays = _calculateOverdueDays(patient, payments);
    final remainingAmount = _getRemainingAmount(patient, payments);
    final monthlyAmount = _getMonthlyAmount(patient);

    // إنشاء controller للملاحظات إذا لم يكن موجوداً
    if (!_notesControllers.containsKey(patient.name)) {
      _notesControllers[patient.name] = TextEditingController();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
          5: FlexColumnWidth(2),
          6: FlexColumnWidth(3),
        },
        children: [
          TableRow(
            children: [
              _buildTableCell(patient.name, isName: true),
              _buildTableCell(
                  DateFormat('yyyy/MM/dd').format(patient.registrationDate)),
              _buildOverdueDaysCell(overdueDays),
              _buildAmountCell(remainingAmount, isRemaining: true),
              _buildAmountCell(monthlyAmount),
              _buildTableCell(patient.phoneNumber),
              _buildNotesCell(patient.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isName = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isName ? FontWeight.w600 : FontWeight.normal,
          color: isName ? const Color(0xFF649FCC) : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOverdueDaysCell(int days) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          '$days يوم',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAmountCell(double amount, {bool isRemaining = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        '${amount.toStringAsFixed(0)} دينار',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isRemaining ? Colors.red : const Color(0xFF649FCC),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNotesCell(String patientName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFF2EDE9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF649FCC).withOpacity(0.3)),
        ),
        child: TextField(
          controller: _notesControllers[patientName],
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: InputBorder.none,
            hintText: 'ملاحظة...',
            hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 11),
          maxLines: 1,
          onChanged: (value) {
            _saveNote(patientName, value);
          },
          onSubmitted: (value) {
            _saveNote(patientName, value);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.circleCheck,
              color: Colors.green,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد تسديدات متأخرة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'جميع المرضى ملتزمون بمواعيد التسديد',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(
      List<Patient> overduePatients, List<Payment> payments) {
    double totalRemainingAmount = 0;
    double totalMonthlyAmount = 0;

    for (var patient in overduePatients) {
      totalRemainingAmount += _getRemainingAmount(patient, payments);
      totalMonthlyAmount += _getMonthlyAmount(patient);
    }

    return Row(
      children: [
        // كارت المبلغ المتبقي الكلي
        Expanded(
          child: _buildStatisticsCard(
            title: 'المبلغ المتبقي الكلي',
            amount: totalRemainingAmount,
            icon: FontAwesomeIcons.triangleExclamation,
            color: Colors.red,
            backgroundColor: Colors.red.withOpacity(0.1),
          ),
        ),

        const SizedBox(width: 16),

        // كارت مجموع التسديد الشهري
        Expanded(
          child: _buildStatisticsCard(
            title: 'مجموع التسديد الشهري',
            amount: totalMonthlyAmount,
            icon: FontAwesomeIcons.coins,
            color: const Color(0xFF649FCC),
            backgroundColor: const Color(0xFF649FCC).withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(0)} دينار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
