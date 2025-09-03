import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final _infoSearchController = TextEditingController();

  Patient? _selectedPatient;
  Patient? _selectedPatientForInfo;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<Payment> _filteredPayments = [];

  // متغيرات للبحث الذكي
  List<Patient> _filteredPatientsForPayment = [];
  List<Patient> _filteredPatientsForInfo = [];
  bool _showDropdownForPayment = false;
  bool _showDropdownForInfo = false;

  // متغيرات للـ Overlay
  OverlayEntry? _overlayEntryForPayment;
  OverlayEntry? _overlayEntryForInfo;
  final LayerLink _layerLinkForPayment = LayerLink();
  final LayerLink _layerLinkForInfo = LayerLink();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // تحديث البيانات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshData();
    });
  }

  @override
  void dispose() {
    _removeOverlayForPayment();
    _removeOverlayForInfo();
    _amountController.dispose();
    _patientNameController.dispose();
    _searchController.dispose();
    _infoSearchController.dispose();
    super.dispose();
  }

  void _removeOverlayForPayment() {
    _overlayEntryForPayment?.remove();
    _overlayEntryForPayment = null;
  }

  void _removeOverlayForInfo() {
    _overlayEntryForInfo?.remove();
    _overlayEntryForInfo = null;
  }

  void _showOverlayForPayment(List<Patient> patients) {
    _removeOverlayForPayment();
    _filteredPatientsForPayment = _filteredPatientsForPayment.isEmpty
        ? patients
        : _filteredPatientsForPayment;

    if (_filteredPatientsForPayment.isEmpty) return;

    _overlayEntryForPayment = OverlayEntry(
      builder: (context) => Positioned(
        width: 300, // عرض القائمة
        child: CompositedTransformFollower(
          link: _layerLinkForPayment,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 52.0), // أسفل الحقل مباشرة
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredPatientsForPayment.length,
                itemBuilder: (context, index) {
                  final patient = _filteredPatientsForPayment[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPatient = patient;
                        _patientNameController.text = patient.name;
                        _showDropdownForPayment = false;
                      });
                      _removeOverlayForPayment();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: index < _filteredPatientsForPayment.length - 1
                            ? Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 30, 84, 120)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 30, 84, 120),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'المبلغ: ${patient.totalAmount.toStringAsFixed(0)} د.ع',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color.fromARGB(255, 30, 84, 120),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryForPayment!);
    setState(() {
      _showDropdownForPayment = true;
    });
  }

  void _showOverlayForInfo(List<Patient> patients) {
    _removeOverlayForInfo();
    _filteredPatientsForInfo =
        _filteredPatientsForInfo.isEmpty ? patients : _filteredPatientsForInfo;

    if (_filteredPatientsForInfo.isEmpty) return;

    _overlayEntryForInfo = OverlayEntry(
      builder: (context) => Positioned(
        width: 400, // عرض القائمة
        child: CompositedTransformFollower(
          link: _layerLinkForInfo,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 52.0), // أسفل الحقل مباشرة
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EDE9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredPatientsForInfo.length,
                itemBuilder: (context, index) {
                  final patient = _filteredPatientsForInfo[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPatientForInfo = patient;
                        _infoSearchController.text = patient.name;
                        _showDropdownForInfo = false;
                        final appProvider = context.read<AppProvider>();
                        _filteredPayments = appProvider.payments
                            .where((payment) =>
                                payment.patientName == patient.name)
                            .toList();
                      });
                      _removeOverlayForInfo();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: index < _filteredPatientsForInfo.length - 1
                            ? Border(
                                bottom: BorderSide(
                                  color: const Color.fromARGB(255, 30, 84, 120)
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 30, 84, 120)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 30, 84, 120),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'الهاتف: ${patient.phoneNumber}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0xFF649FCC),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntryForInfo!);
    setState(() {
      _showDropdownForInfo = true;
    });
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
    final registrationDate = patient.registrationDate ?? DateTime.now();
    DateTime nextPaymentDate = DateTime(
        registrationDate.year,
        registrationDate.month + patientPayments.length + 1,
        registrationDate.day);

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
                  Icons.check_circle,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // ← ارتفاع AppBar = 80
        child: AppBar(
          title: const Text(
            'صفحة تسديد الكمبيالة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "Cairo",
              fontSize: 24,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 30, 84, 120),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                // تحديث البيانات
                context.read<AppProvider>().refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري تحديث البيانات...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return GestureDetector(
            onTap: () {
              // إخفاء القائمة عند الضغط خارجها
              _removeOverlayForPayment();
              _removeOverlayForInfo();
              setState(() {
                _showDropdownForPayment = false;
                _showDropdownForInfo = false;
              });
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
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
                          appProvider.patients,
                          appProvider.payments,
                        ),
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
        color: const Color.fromARGB(255, 30, 84, 120),
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
          crossAxisAlignment: CrossAxisAlignment.end, // ← الزر بمحاذاة الحقول
          children: [
            // حقل التاريخ
            Expanded(flex: 2, child: _buildDateField()),

            const SizedBox(width: 12),

            // حقل اسم المريض - استخدام FutureBuilder لجلب المرضى مع المبالغ المتبقية
            Expanded(flex: 3, child: _buildPatientDropdownWithFuture()),

            const SizedBox(width: 12),

            // حقل المبلغ
            Expanded(flex: 2, child: _buildAmountField()),

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          textAlign: TextAlign.center,
          'حقل التاريخ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3), // لون أفتح ليظهر أنه معطل
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('yyyy/MM/dd').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Text(
                  '(غير قابل للتعديل)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDropdownWithFuture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          textAlign: TextAlign.center,
          'حقل ادخال الاسم',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Patient>>(
          future: context.read<AppProvider>().getPatientsWithPendingPayments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 30, 84, 120),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            final patientsWithPending = snapshot.data ?? [];

            return CompositedTransformTarget(
              link: _layerLinkForPayment,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _patientNameController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن المريض للتسديد...',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_search,
                      color: Color.fromARGB(255, 30, 84, 120),
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showDropdownForPayment
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color.fromARGB(255, 30, 84, 120),
                      ),
                      onPressed: () {
                        if (_showDropdownForPayment) {
                          _removeOverlayForPayment();
                          setState(() {
                            _showDropdownForPayment = false;
                          });
                        } else {
                          _showOverlayForPayment(patientsWithPending);
                        }
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                  onChanged: (value) {
                    _filteredPatientsForPayment = patientsWithPending
                        .where((patient) => patient.name
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                    // إعادة تعيين المريض إذا تطابق الاسم
                    try {
                      final exactMatch = patientsWithPending.firstWhere(
                        (patient) =>
                            patient.name.toLowerCase() == value.toLowerCase(),
                      );
                      _selectedPatient = exactMatch;
                    } catch (e) {
                      _selectedPatient = null;
                    }
                    if (value.isNotEmpty) {
                      _showOverlayForPayment(patientsWithPending);
                    } else {
                      _removeOverlayForPayment();
                    }
                  },
                  onTap: () {
                    _showOverlayForPayment(patientsWithPending);
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          textAlign: TextAlign.center,
          'حقل ادخال المبلغ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              hintText: 'المبلغ',
              hintStyle: TextStyle(fontSize: 20),
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
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addPayment,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.green.shade700;
            }
            if (states.contains(WidgetState.disabled)) {
              return Colors.green.withOpacity(0.5);
            }
            return Colors.green;
          }),
          shadowColor: WidgetStateProperty.all(Colors.green.withOpacity(0.5)),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) return 8;
            return 4;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'تسديد',
                style: TextStyle(
                  fontSize: 20,
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
              color: Color.fromARGB(255, 30, 84, 120),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Center(
                    // ← يجعل النص في منتصف الجدول
                    child: Text(
                      'البحث عن معلومات مراجع',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'cairo',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 28), // إضافة مسافة لتوازن الأيقونة على اليسار
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
              child: Column(
                children: [
                  CompositedTransformTarget(
                    link: _layerLinkForInfo,
                    child: Container(
                      child: TextField(
                        controller: _infoSearchController,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن مريض لعرض معلوماته...',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_search,
                            color: Color(0xFF649FCC),
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showDropdownForInfo
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF649FCC),
                            ),
                            onPressed: () {
                              if (_showDropdownForInfo) {
                                _removeOverlayForInfo();
                                setState(() {
                                  _showDropdownForInfo = false;
                                });
                              } else {
                                _showOverlayForInfo(patients);
                              }
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (value) {
                          _filteredPatientsForInfo = patients
                              .where((patient) => patient.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                          // إعادة تعيين المريض إذا تطابق الاسم
                          final exactMatch = patients.firstWhere(
                            (patient) =>
                                patient.name.toLowerCase() ==
                                value.toLowerCase(),
                            orElse: () => patients.first,
                          );
                          if (exactMatch.name.toLowerCase() ==
                              value.toLowerCase()) {
                            setState(() {
                              _selectedPatientForInfo = exactMatch;
                              _filteredPayments = context
                                  .read<AppProvider>()
                                  .payments
                                  .where((payment) =>
                                      payment.patientName == exactMatch.name)
                                  .toList();
                            });
                          } else if (value.isEmpty) {
                            setState(() {
                              _selectedPatientForInfo = null;
                              _filteredPayments = [];
                            });
                          }
                          if (value.isNotEmpty) {
                            _showOverlayForInfo(patients);
                          } else {
                            _removeOverlayForInfo();
                          }
                        },
                        onTap: () {
                          _showOverlayForInfo(patients);
                        },
                      ),
                    ),
                  ),
                ],
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
          _buildInfoRow(
              'تاريخ التسجيل',
              DateFormat('yyyy/MM/dd')
                  .format(patient.registrationDate ?? DateTime.now())),
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
                fontSize: 20,
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
                fontSize: 20,
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
              color: Color.fromARGB(255, 30, 84, 120),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Colors.white,
                  size: 30, // ← حجم الأيقونة
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      'معلومات تسديدات المراجع',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20, // ← حجم النص
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: 38), // توازن الأيقونة على اليسار
              ],
            ),
          ),

          // رؤوس الأعمدة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD0EBFF),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'تاريخ التسديد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF649FCC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'اسم المراجع',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF649FCC),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'مبلغ التسديد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF649FCC),
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
                                .format(payment.paymentDate ?? DateTime.now()),
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            payment.patientName,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${payment.amount.toStringAsFixed(0)} دينار',
                            style: const TextStyle(
                              fontSize: 20,
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
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تسديدات لعرضها',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر مريض من الجدول الأيسر لعرض تسديداته',
                    style: TextStyle(
                      fontSize: 18,
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
