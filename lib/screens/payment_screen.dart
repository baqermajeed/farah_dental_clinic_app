import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final _notesController = TextEditingController();

  Patient? _selectedPatient;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addPayment() async {
    if (!_formKey.currentState!.validate() || _selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى اختيار مريض وإدخال جميع البيانات المطلوبة'),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final payment = Payment(
      patientName: _selectedPatient!.name,
      amount: double.parse(_amountController.text),
      paymentDate: _selectedDate,
      notes: _notesController.text.trim(),
    );

    final success = await context.read<AppProvider>().addPayment(payment);

    if (mounted) {
      if (success) {
        _showSuccessDialog();
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('حدث خطأ أثناء إضافة الدفعة'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
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
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FontAwesomeIcons.circleCheck,
                  color: Color(0xFF27AE60),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تم تسجيل الدفعة بنجاح',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF27AE60),
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

  void _clearForm() {
    _amountController.clear();
    _notesController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسديد كمبيالة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF649FCC).withOpacity(0.1),
              const Color(0xFFF2EDE9),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // شعار الصفحة
                    Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3498DB).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                FontAwesomeIcons.creditCard,
                                size: 30,
                                color: Color(0xFF3498DB),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تسديد كمبيالة',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: const Color(0xFF3498DB),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'تسجيل دفعة جديدة لمريض',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // نموذج إدخال البيانات
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اختيار المريض
                              _buildPatientSelector(appProvider.patients),

                              const SizedBox(height: 20),

                              // حقل التاريخ
                              _buildDateField(),

                              const SizedBox(height: 20),

                              // حقل المبلغ
                              _buildTextField(
                                controller: _amountController,
                                label: 'مبلغ الدفعة (د.ع)',
                                icon: FontAwesomeIcons.coins,
                                hint: 'أدخل مبلغ الدفعة',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'يرجى إدخال مبلغ الدفعة';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'يرجى إدخال مبلغ صحيح';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // حقل الملاحظات
                              _buildTextField(
                                controller: _notesController,
                                label: 'ملاحظات (اختياري)',
                                icon: FontAwesomeIcons.noteSticky,
                                hint: 'أدخل أي ملاحظات إضافية',
                                maxLines: 3,
                              ),

                              const SizedBox(height: 32),

                              // زر التسديد
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _addPayment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3498DB),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(FontAwesomeIcons.plus),
                                            SizedBox(width: 12),
                                            Text(
                                              'تسجيل الدفعة',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // عرض آخر المدفوعات
                    if (appProvider.payments.isNotEmpty)
                      _buildRecentPayments(appProvider.payments),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPatientSelector(List<Patient> patients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختيار المريض',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF649FCC).withOpacity(0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Patient>(
              value: _selectedPatient,
              hint: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.user,
                    color: Color(0xFF649FCC),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'اختر المريض',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              items: patients.map((Patient patient) {
                return DropdownMenuItem<Patient>(
                  value: patient,
                  child: Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.user,
                        color: Color(0xFF649FCC),
                        size: 16,
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
                              ),
                            ),
                            Text(
                              'المبلغ الإجمالي: ${patient.totalAmount.toStringAsFixed(0)} د.ع',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Patient? newValue) {
                setState(() {
                  _selectedPatient = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ الدفعة',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF649FCC).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.calendar,
                  color: Color(0xFF649FCC),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildRecentPayments(List<Payment> payments) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'آخر المدفوعات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF3498DB),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...payments.take(5).map((payment) => ListTile(
                  leading: const Icon(FontAwesomeIcons.coins,
                      color: Color(0xFF3498DB)),
                  title: Text(payment.patientName),
                  subtitle: Text(
                    'المبلغ: ${payment.amount.toStringAsFixed(0)} د.ع\n'
                    'التاريخ: ${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}-${payment.paymentDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: payment.notes.isNotEmpty
                      ? IconButton(
                          icon: Icon(FontAwesomeIcons.noteSticky,
                              color: Colors.grey[600], size: 18),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('ملاحظة الدفعة'),
                                content: Text(payment.notes),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('إغلاق'),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : null,
                )),
          ],
        ),
      ),
    );
  }
}
