import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/dashboard_button.dart';
import '../widgets/add_patient_dialog.dart';
import 'payment_screen.dart';
import 'overdue_payments_screen.dart';
import 'invoice_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              if (appProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // شعار العيادة والعنوان
                    _buildHeader(),

                    const SizedBox(height: 30),

                    // المحتوى الرئيسي
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الأزرار الجانبية (الجهة اليسرى)
                        Expanded(
                          flex: 1,
                          child: _buildNavigationButtons(context),
                        ),

                        const SizedBox(width: 20),

                        // الإحصائيات (الجهة اليمنى)
                        Expanded(
                          flex: 1,
                          child: _buildStatistics(appProvider),
                        ),
                      ],
                    ),
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
            // شعار العيادة
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF649FCC).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.tooth,
                size: 40,
                color: Color(0xFF649FCC),
              ),
            ),

            const SizedBox(width: 20),

            // معلومات العيادة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عيادة فرح لطب الأسنان',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF649FCC),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'نظام إدارة الكمبيالات والتسديدات',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        Text(
          'الأقسام الرئيسية',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF649FCC),
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 20),

        // زر تسجيل مريض
        DashboardButton(
          title: 'تسجيل مريض',
          subtitle: 'إضافة مريض جديد للنظام',
          icon: FontAwesomeIcons.userPlus,
          color: const Color(0xFF27AE60),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddPatientDialog(),
            );
          },
        ),

        const SizedBox(height: 16),

        // زر تسديد كمبيالة
        DashboardButton(
          title: 'تسديد كمبيالة',
          subtitle: 'تسجيل تسديد وعرض السجلات',
          icon: FontAwesomeIcons.creditCard,
          color: const Color(0xFF3498DB),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PaymentScreen()),
            );
          },
        ),

        const SizedBox(height: 16),

        // زر التسديدات المتأخرة
        DashboardButton(
          title: 'التسديدات المتأخرة',
          subtitle: 'عرض المراجعين المتأخرين',
          icon: FontAwesomeIcons.clockRotateLeft,
          color: const Color(0xFFE74C3C),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const OverduePaymentsScreen()),
            );
          },
        ),

        const SizedBox(height: 16),

        // زر الاستمارة
        DashboardButton(
          title: 'استمارة',
          subtitle: 'إنشاء وطباعة استمارة الكمبيالة',
          icon: FontAwesomeIcons.filePdf,
          color: const Color(0xFF9B59B6),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const InvoiceFormScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatistics(AppProvider appProvider) {
    return Column(
      children: [
        Text(
          'الإحصائيات العامة',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF649FCC),
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 20),

        // المبلغ الكلي للكمبيالات
        StatsCard(
          title: 'المبلغ الكلي للكمبيالات',
          value: '${appProvider.totalAmount.toStringAsFixed(0)} د.ع',
          icon: FontAwesomeIcons.coins,
          color: const Color(0xFF3498DB),
        ),

        const SizedBox(height: 16),

        // المبالغ المسددة
        StatsCard(
          title: 'المبالغ المسددة',
          value: '${appProvider.paidAmount.toStringAsFixed(0)} د.ع',
          icon: FontAwesomeIcons.circleCheck,
          color: const Color(0xFF27AE60),
        ),

        const SizedBox(height: 16),

        // المبالغ المتبقية
        StatsCard(
          title: 'المبالغ المتبقية',
          value: '${appProvider.remainingAmount.toStringAsFixed(0)} د.ع',
          icon: FontAwesomeIcons.hourglassHalf,
          color: const Color(0xFFF39C12),
        ),

        const SizedBox(height: 16),

        // عدد الكمبيالات المتبقية
        StatsCard(
          title: 'عدد الكمبيالات المتبقية',
          value: '${appProvider.remainingBillsCount}',
          icon: FontAwesomeIcons.fileInvoice,
          color: const Color(0xFFE74C3C),
        ),
      ],
    );
  }
}
