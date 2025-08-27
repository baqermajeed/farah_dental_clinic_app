import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_provider.dart';
import '../models/patient.dart';
import '../models/payment.dart';

class OverduePaymentsScreen extends StatefulWidget {
  const OverduePaymentsScreen({super.key});

  @override
  State<OverduePaymentsScreen> createState() => _OverduePaymentsScreenState();
}

class _OverduePaymentsScreenState extends State<OverduePaymentsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التسديدات المتأخرة'),
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
              final overduePatients = appProvider.getOverduePatients();
              final filteredPatients = _filterPatients(overduePatients);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // شعار الصفحة
                    _buildHeader(overduePatients.length),

                    const SizedBox(height: 24),

                    // شريط البحث
                    _buildSearchBar(),

                    const SizedBox(height: 24),

                    // قائمة المرضى المتأخرين
                    if (filteredPatients.isEmpty)
                      _buildEmptyState()
                    else
                      _buildPatientsList(filteredPatients, appProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int overdueCount) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.triangleExclamation,
                size: 30,
                color: Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التسديدات المتأخرة',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFE74C3C),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$overdueCount مريض لديه تسديدات متأخرة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$overdueCount',
                style: const TextStyle(
                  color: Color(0xFFE74C3C),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'البحث عن مريض...',
            prefixIcon: Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: Color(0xFF649FCC),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
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
                size: 40,
                color: Color(0xFF27AE60),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isEmpty
                  ? 'لا توجد تسديدات متأخرة'
                  : 'لا توجد نتائج للبحث',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF27AE60),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isEmpty
                  ? 'جميع المرضى ملتزمون بمواعيد التسديد'
                  : 'جرب البحث بكلمات مختلفة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsList(List<Patient> patients, AppProvider appProvider) {
    return Column(
      children: patients
          .map((patient) => _buildPatientCard(patient, appProvider))
          .toList(),
    );
  }

  Widget _buildPatientCard(Patient patient, AppProvider appProvider) {
    final patientPayments = appProvider.getPatientPayments(patient.name);
    final totalPaid =
        patientPayments.fold(0.0, (sum, payment) => sum + payment.amount);
    final remainingAmount = patient.totalAmount - totalPaid;
    final overdueMonths = _calculateOverdueMonths(patient);

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE74C3C).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المريض الأساسية
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.user,
                      color: Color(0xFFE74C3C),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم الهاتف: ${patient.phoneNumber}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$overdueMonths شهر متأخر',
                      style: const TextStyle(
                        color: Color(0xFFE74C3C),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // تفاصيل مالية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildFinancialRow(
                      'المبلغ الإجمالي',
                      '${patient.totalAmount.toStringAsFixed(0)} د.ع',
                      FontAwesomeIcons.coins,
                      const Color(0xFF3498DB),
                    ),
                    const SizedBox(height: 8),
                    _buildFinancialRow(
                      'المبلغ المدفوع',
                      '${totalPaid.toStringAsFixed(0)} د.ع',
                      FontAwesomeIcons.circleCheck,
                      const Color(0xFF27AE60),
                    ),
                    const SizedBox(height: 8),
                    _buildFinancialRow(
                      'المبلغ المتبقي',
                      '${remainingAmount.toStringAsFixed(0)} د.ع',
                      FontAwesomeIcons.triangleExclamation,
                      const Color(0xFFE74C3C),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // معلومات التقسيط
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'إجمالي الأشهر',
                      '${patient.totalMonths}',
                      FontAwesomeIcons.calendar,
                      const Color(0xFF9B59B6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      'الأشهر المتبقية',
                      '${patient.remainingMonths}',
                      FontAwesomeIcons.clockRotateLeft,
                      const Color(0xFFE67E22),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // أزرار العمليات
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPaymentDialog(patient),
                      icon: const Icon(FontAwesomeIcons.plus, size: 16),
                      label: const Text('تسديد دفعة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showPaymentHistory(patient, patientPayments),
                      icon: const Icon(FontAwesomeIcons.clockRotateLeft,
                          size: 16),
                      label: const Text('سجل المدفوعات'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF649FCC),
                        side: const BorderSide(color: Color(0xFF649FCC)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Patient patient) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.creditCard,
                    color: Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تسديد دفعة - ${patient.name}',
                      style: const TextStyle(
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ الدفعة (د.ع)',
                        prefixIcon: Icon(FontAwesomeIcons.coins),
                        hintText: 'أدخل مبلغ الدفعة',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        prefixIcon: Icon(FontAwesomeIcons.noteSticky),
                        hintText: 'أدخل أي ملاحظات إضافية',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF649FCC).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(FontAwesomeIcons.calendar,
                                color: Color(0xFF649FCC), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('يرجى إدخال مبلغ صحيح'),
                          backgroundColor: Colors.red[400],
                        ),
                      );
                      return;
                    }
                    final payment = Payment(
                      patientName: patient.name,
                      amount: amount,
                      paymentDate: selectedDate,
                      notes: notesController.text.trim(),
                    );
                    final success =
                        await Provider.of<AppProvider>(context, listen: false)
                            .addPayment(payment);
                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('تم تسجيل الدفعة بنجاح'),
                          backgroundColor: Colors.green[400],
                        ),
                      );
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('حدث خطأ أثناء إضافة الدفعة'),
                          backgroundColor: Colors.red[400],
                        ),
                      );
                    }
                  },
                  child: const Text('تسجيل الدفعة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentHistory(Patient patient, List<Payment> payments) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('سجل المدفوعات - ${patient.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: payments.isEmpty
              ? const Text('لا توجد مدفوعات لهذا المريض.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return ListTile(
                      leading: const Icon(FontAwesomeIcons.coins,
                          color: Color(0xFF3498DB)),
                      title: Text('${payment.amount.toStringAsFixed(0)} د.ع'),
                      subtitle: Text(
                        '${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}-${payment.paymentDate.day.toString().padLeft(2, '0')}'
                        '${payment.notes.isNotEmpty ? '\nملاحظة: ${payment.notes}' : ''}',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  int _calculateOverdueMonths(Patient patient) {
    // يمكنك تعديل المنطق حسب الحاجة
    return patient.remainingMonths;
  }

  List<Patient> _filterPatients(List<Patient> patients) {
    if (_searchQuery.isEmpty) return patients;
    return patients.where((p) => p.name.contains(_searchQuery)).toList();
  }
}
