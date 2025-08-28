import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/patient.dart';
import '../models/payment.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _searchController = TextEditingController();

  Patient? _selectedPatient;
  Patient? _selectedPatientForInfo;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<Payment> _filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _patientNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // حساب المعلومات المالية للمريض
  Map<String, dynamic> _calculatePatientFinancials(
      Patient patient, List<Payment> payments) {
    final patientPayments =
        payments.where((p) => p.patientName == patient.name).toList();
    final totalPaid =
        patientPayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final remaining = patient.totalAmount - totalPaid;
    final monthlyPayment = patient.totalAmount / patient.totalMonths;

    // حساب تاريخ التسديد القادم
    DateTime nextPaymentDate = DateTime(
        patient.registrationDate.year,
        patient.registrationDate.month + patientPayments.length + 1,
        patient.registrationDate.day);

    return {
      'totalPaid': totalPaid,
      'remaining': remaining,
      'monthlyPayment': monthlyPayment,
      'nextPaymentDate': nextPaymentDate,
      'paymentsCount': patientPayments.length,
    };
  }

  Future<void> _addPayment() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('يرجى إدخال جميع البيانات المطلوبة');
      return;
    }

    if (_selectedPatient == null) {
      _showErrorSnackBar('يرجى اختيار مريض');
      return;
    }

    // التحقق من أن المبلغ لا يتجاوز المبلغ المتبقي
    final appProvider = context.read<AppProvider>();
    final financials =
        _calculatePatientFinancials(_selectedPatient!, appProvider.payments);
    final paymentAmount = double.parse(_amountController.text);

    if (paymentAmount > financials['remaining']) {
      _showErrorSnackBar(
          'مبلغ التسديد أكبر من المبلغ المتبقي (${financials['remaining'].toStringAsFixed(0)} دينار)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final payment = Payment(
        patientName: _selectedPatient!.name,
        amount: paymentAmount,
        paymentDate: _selectedDate,
        notes:
            'تسديد كمبيالة - ${DateFormat('yyyy/MM/dd').format(_selectedDate)}',
      );

      final success = await appProvider.addPayment(payment);

      if (mounted) {
        if (success) {
          _showSuccessDialog();
          _clearForm();
          // تحديث المعلومات المعروضة
          if (_selectedPatientForInfo?.name == _selectedPatient!.name) {
            setState(() {
              _selectedPatientForInfo = _selectedPatient;
              _filteredPayments = appProvider.payments
                  .where((payment) =>
                      payment.patientName == _selectedPatient!.name)
                  .toList();
            });
          }
        } else {
          _showErrorSnackBar('حدث خطأ أثناء إضافة الدفعة');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('حدث خطأ غير متوقع: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
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
                'تم تسجيل الدفعة بنجاح',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'تم تحديث سجل المدفوعات والإحصائيات',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _clearForm() {
    _amountController.clear();
    _patientNameController.clear();
    setState(() {
      _selectedPatient = null;
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF649FCC),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onPatientSelected(Patient? patient) {
    setState(() {
      _selectedPatientForInfo = patient;
      if (patient != null) {
        final appProvider = context.read<AppProvider>();
        _filteredPayments = appProvider.payments
            .where((payment) => payment.patientName == patient.name)
            .toList();
      } else {
        _filteredPayments = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE9),
      appBar: AppBar(
        title: const Text(
          'صفحة تسديد الكمبيالة',
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // قسم إدخال البيانات العلوي
                _buildTopInputSection(appProvider.patients),

                const SizedBox(height: 24),

                // الجدولين
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الجدول الأول - معلومات المراجع
                    Expanded(
                      flex: 1,
                      child: _buildPatientInfoTable(
                          appProvider.patients, appProvider.payments),
                    ),

                    const SizedBox(width: 16),

                    // الجدول الثاني - سجل التسديدات
                    Expanded(
                      flex: 1,
                      child: _buildPaymentsHistoryTable(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopInputSection(List<Patient> patients) {
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
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            // حقل التاريخ
            Expanded(
              flex: 2,
              child: _buildDateField(),
            ),

            const SizedBox(width: 12),

            // حقل اسم المريض
            Expanded(
              flex: 3,
              child: _buildPatientDropdown(patients),
            ),

            const SizedBox(width: 12),

            // حقل المبلغ
            Expanded(
              flex: 2,
              child: _buildAmountField(),
            ),

            const SizedBox(width: 12),

            // زر التسديد
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حقل التاريخ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF649FCC),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EDE9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF649FCC).withOpacity(0.3)),
          ),
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.calendar,
                    size: 16,
                    color: const Color(0xFF649FCC),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy/MM/dd').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDropdown(List<Patient> patients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حقل ادخال الاسم',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF649FCC),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EDE9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF649FCC).withOpacity(0.3)),
          ),
          child: DropdownButtonFormField<Patient>(
            value: _selectedPatient,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              hintText: 'اختر المريض',
              hintStyle: TextStyle(fontSize: 14),
            ),
            items: patients.map((Patient patient) {
              return DropdownMenuItem<Patient>(
                value: patient,
                child: Text(
                  patient.name,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (Patient? newValue) {
              setState(() {
                _selectedPatient = newValue;
                _patientNameController.text = newValue?.name ?? '';
              });
            },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار مريض';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حقل ادخال المبلغ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF649FCC),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EDE9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF649FCC).withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              hintText: 'المبلغ',
              hintStyle: TextStyle(fontSize: 14),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال المبلغ';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'يرجى إدخال مبلغ صحيح';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'تسديد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildPatientInfoTable(
      List<Patient> patients, List<Payment> payments) {
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
                  FontAwesomeIcons.search,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'البحث عن معلومات مراجع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // حقل البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2EDE9),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF649FCC).withOpacity(0.3)),
              ),
              child: DropdownButtonFormField<Patient>(
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                  hintText: 'اختر المريض لعرض معلوماته',
                  hintStyle: TextStyle(fontSize: 14),
                ),
                items: patients.map((Patient patient) {
                  return DropdownMenuItem<Patient>(
                    value: patient,
                    child: Text(
                      patient.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: _onPatientSelected,
              ),
            ),
          ),

          // عرض المعلومات
          if (_selectedPatientForInfo != null)
            _buildPatientInfoContent(_selectedPatientForInfo!, payments),
        ],
      ),
    );
  }

  Widget _buildPatientInfoContent(Patient patient, List<Payment> payments) {
    final financials = _calculatePatientFinancials(patient, payments);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow('رقم الموبايل', patient.phoneNumber),
          _buildInfoRow('المبلغ الكلي للكمبيالة',
              '${patient.totalAmount.toStringAsFixed(0)} دينار'),
          _buildInfoRow('المبلغ الذي تم تسديده',
              '${financials['totalPaid'].toStringAsFixed(0)} دينار'),
          _buildInfoRow(
              'المتبقي', '${financials['remaining'].toStringAsFixed(0)} دينار',
              isHighlighted: financials['remaining'] > 0),
          _buildInfoRow('تاريخ التسجيل',
              DateFormat('yyyy/MM/dd').format(patient.registrationDate)),
          _buildInfoRow('مبلغ التسديد الشهري',
              '${financials['monthlyPayment'].toStringAsFixed(0)} دينار'),
          _buildInfoRow('عدد الأشهر', '${patient.totalMonths} شهر'),
          _buildInfoRow('تاريخ التسديد القادم',
              DateFormat('yyyy/MM/dd').format(financials['nextPaymentDate'])),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.red.withOpacity(0.1)
            : const Color(0xFFF2EDE9),
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: Colors.red.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isHighlighted ? Colors.red[700] : const Color(0xFF649FCC),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isHighlighted ? Colors.red[700] : Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsHistoryTable() {
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
                  FontAwesomeIcons.list,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'معلومات تسديدات المراجع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // رؤوس الأعمدة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD0EBFF),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ التسديد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF649FCC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'اسم المراجع',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF649FCC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'مبلغ التسديد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF649FCC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // بيانات الجدول
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                children: _filteredPayments.map((payment) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('yyyy/MM/dd')
                                .format(payment.paymentDate),
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            payment.patientName,
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${payment.amount.toStringAsFixed(0)} دينار',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // رسالة في حالة عدم وجود بيانات
          if (_filteredPayments.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    FontAwesomeIcons.fileInvoice,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تسديدات لعرضها',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر مريض من الجدول الأيسر لعرض تسديداته',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
