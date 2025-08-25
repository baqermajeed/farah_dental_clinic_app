import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_provider.dart';
import '../models/patient.dart';

class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _monthsController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _monthsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final patient = Patient(
      name: _nameController.text.trim(),
      totalAmount: double.parse(_amountController.text),
      totalMonths: int.parse(_monthsController.text),
      phoneNumber: _phoneController.text.trim(),
      registrationDate: _selectedDate,
    );

    final success = await context.read<AppProvider>().addPatient(patient);

    if (mounted) {
      if (success) {
        _showSuccessDialog();
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('حدث خطأ أثناء إضافة المريض'),
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
                'تم إضافة الحالة بنجاح',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF27AE60),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'تم حفظ بيانات المريض في النظام',
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
                Navigator.of(context).pop(); // غلق رسالة النجاح
                Navigator.of(context).pop(); // غلق الفورم نفسه
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _amountController.clear();
    _monthsController.clear();
    _phoneController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // التاريخ
              _buildDateField(),
              const SizedBox(height: 20),

              // اسم المريض
              _buildTextField(
                controller: _nameController,
                label: 'اسم المريض',
                icon: FontAwesomeIcons.user,
                hint: 'أدخل اسم المريض الكامل',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم المريض';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // مبلغ الكمبيالة
              _buildTextField(
                controller: _amountController,
                label: 'مبلغ الكمبيالة (د.ع)',
                icon: FontAwesomeIcons.coins,
                hint: 'أدخل المبلغ الإجمالي',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال مبلغ الكمبيالة';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // عدد الأشهر
              _buildTextField(
                controller: _monthsController,
                label: 'عدد الأشهر',
                icon: FontAwesomeIcons.calendar,
                hint: 'أدخل عدد أشهر التقسيط',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال عدد الأشهر';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'يرجى إدخال عدد أشهر صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // رقم الهاتف
              _buildTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                icon: FontAwesomeIcons.phone,
                hint: 'أدخل رقم الهاتف',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // زر الإضافة
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(FontAwesomeIcons.plus),
                            SizedBox(width: 12),
                            Text(
                              'إضافة المريض',
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
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD0EBFF).withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF649FCC).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                FontAwesomeIcons.calendarDays,
                color: Color(0xFF649FCC),
              ),
              const SizedBox(width: 12),
              Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF2C3E50),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              Text(
                '(تلقائي)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
