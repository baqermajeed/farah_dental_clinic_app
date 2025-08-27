import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/app_provider.dart';
import '../models/patient.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  Patient? _selectedPatient;
  String _selectedInvoiceType =
      'detailed'; // detailed, summary, payment_schedule

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استمارة الكمبيالة'),
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
                    _buildHeader(),

                    const SizedBox(height: 24),

                    // اختيار المريض
                    _buildPatientSelector(appProvider.patients),

                    const SizedBox(height: 24),

                    // اختيار نوع الاستمارة
                    _buildInvoiceTypeSelector(),

                    const SizedBox(height: 24),

                    // معاينة البيانات
                    if (_selectedPatient != null)
                      _buildPatientPreview(_selectedPatient!, appProvider),

                    const SizedBox(height: 24),

                    // أزرار العمليات
                    if (_selectedPatient != null)
                      _buildActionButtons(_selectedPatient!, appProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.fileInvoice,
                size: 30,
                color: Color(0xFF9B59B6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'استمارة الكمبيالة',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF9B59B6),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'إنشاء وطباعة استمارات المرضى',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector(List<Patient> patients) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.user,
                  color: Color(0xFF649FCC),
                ),
                const SizedBox(width: 12),
                Text(
                  'اختيار المريض',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF649FCC),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                        FontAwesomeIcons.userPlus,
                        color: Color(0xFF649FCC),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'اختر المريض لإنشاء الاستمارة',
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF649FCC).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              FontAwesomeIcons.user,
                              color: Color(0xFF649FCC),
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
        ),
      ),
    );
  }

  Widget _buildInvoiceTypeSelector() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.fileLines,
                  color: Color(0xFF9B59B6),
                ),
                const SizedBox(width: 12),
                Text(
                  'نوع الاستمارة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF9B59B6),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildInvoiceTypeOption(
                  'detailed',
                  'استمارة مفصلة',
                  'تشمل جميع تفاصيل المريض والعلاج والتقسيط',
                  FontAwesomeIcons.listCheck,
                ),
                const SizedBox(height: 12),
                _buildInvoiceTypeOption(
                  'summary',
                  'استمارة مختصرة',
                  'تشمل المعلومات الأساسية والمبلغ الإجمالي',
                  FontAwesomeIcons.fileText,
                ),
                const SizedBox(height: 12),
                _buildInvoiceTypeOption(
                  'payment_schedule',
                  'جدول التسديد',
                  'جدول مواعيد التسديد الشهرية',
                  FontAwesomeIcons.calendar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTypeOption(
      String value, String title, String description, IconData icon) {
    final isSelected = _selectedInvoiceType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedInvoiceType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF9B59B6).withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF9B59B6) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF9B59B6) : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF9B59B6)
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                FontAwesomeIcons.circleCheck,
                color: Color(0xFF9B59B6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientPreview(Patient patient, AppProvider appProvider) {
    final patientPayments = appProvider.getPatientPayments(patient.name);
    final totalPaid =
        patientPayments.fold(0.0, (sum, payment) => sum + payment.amount);
    final remainingAmount = patient.totalAmount - totalPaid;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.eye,
                  color: Color(0xFF3498DB),
                ),
                const SizedBox(width: 12),
                Text(
                  'معاينة البيانات',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF3498DB),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // معلومات المريض
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPreviewRow(
                      'اسم المريض', patient.name, FontAwesomeIcons.user),
                  const SizedBox(height: 8),
                  _buildPreviewRow('رقم الهاتف', patient.phoneNumber,
                      FontAwesomeIcons.phone),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                      'العنوان', patient.address, FontAwesomeIcons.locationDot),
                  const SizedBox(height: 8),
                  _buildPreviewRow('نوع العلاج', patient.treatmentType,
                      FontAwesomeIcons.tooth),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                      'المبلغ الإجمالي',
                      '${patient.totalAmount.toStringAsFixed(0)} د.ع',
                      FontAwesomeIcons.coins),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                      'المبلغ المدفوع',
                      '${totalPaid.toStringAsFixed(0)} د.ع',
                      FontAwesomeIcons.circleCheck),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                      'المبلغ المتبقي',
                      '${remainingAmount.toStringAsFixed(0)} د.ع',
                      FontAwesomeIcons.triangleExclamation),
                  const SizedBox(height: 8),
                  _buildPreviewRow('عدد الأشهر', '${patient.totalMonths}',
                      FontAwesomeIcons.calendar),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF649FCC), size: 16),
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
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Patient patient, AppProvider appProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.print,
                  color: Color(0xFF27AE60),
                ),
                const SizedBox(width: 12),
                Text(
                  'طباعة الاستمارة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF27AE60),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(FontAwesomeIcons.print),
                label: const Text('طباعة الاستمارة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                ),
                onPressed: () async {
                  final pdf = await _generateInvoicePdf(patient, appProvider);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdf.save(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _generateInvoicePdf(
      Patient patient, AppProvider appProvider) async {
    final patientPayments = appProvider.getPatientPayments(patient.name);
    final totalPaid =
        patientPayments.fold(0.0, (sum, payment) => sum + payment.amount);
    final remainingAmount = patient.totalAmount - totalPaid;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('استمارة الكمبيالة',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('اسم المريض: ${patient.name}',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text('رقم الهاتف: ${patient.phoneNumber}',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text('العنوان: ${patient.address}',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text('نوع العلاج: ${patient.treatmentType}',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text(
                    'المبلغ الإجمالي: ${patient.totalAmount.toStringAsFixed(0)} د.ع',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text('المبلغ المدفوع: ${totalPaid.toStringAsFixed(0)} د.ع',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text(
                    'المبلغ المتبقي: ${remainingAmount.toStringAsFixed(0)} د.ع',
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text('عدد الأشهر: ${patient.totalMonths}',
                    style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),
                if (_selectedInvoiceType == 'detailed')
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('تفاصيل المدفوعات:',
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      if (patientPayments.isEmpty)
                        pw.Text('لا توجد مدفوعات لهذا المريض.',
                            style: pw.TextStyle(fontSize: 14)),
                      ...patientPayments.map((payment) => pw.Text(
                            'تاريخ: ${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}-${payment.paymentDate.day.toString().padLeft(2, '0')} | مبلغ: ${payment.amount.toStringAsFixed(0)} د.ع${payment.notes.isNotEmpty ? " | ملاحظة: ${payment.notes}" : ""}',
                            style: pw.TextStyle(fontSize: 14),
                          )),
                    ],
                  ),
                if (_selectedInvoiceType == 'payment_schedule')
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('جدول التسديد:',
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      for (int i = 1; i <= patient.totalMonths; i++)
                        pw.Text(
                            'شهر $i: مبلغ ${((patient.totalAmount) / patient.totalMonths).toStringAsFixed(0)} د.ع',
                            style: pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                if (_selectedInvoiceType == 'summary')
                  pw.Text('استمارة مختصرة للمريض فقط.',
                      style: pw.TextStyle(fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }
}
