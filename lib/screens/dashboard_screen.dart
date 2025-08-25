import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/app_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/dashboard_button.dart';
import 'add_patient_screen.dart';
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
                    // اللوگو واسم العيادة
                    _buildHeader(),

                    const SizedBox(height: 30),

                    // باقي المحتوى (الأزرار والإحصائيات)
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
                          child: _buildStatistics(appProvider, context),
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

  // 🟢 اللوگو + اسم العيادة
  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/new-farah.png', // غير المسار حسب ملفك
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 5),
        Text(
          'عيادة فرح لطب الأسنان',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF649FCC),
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
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
              builder: (context) => const Dialog(
                child: SizedBox(
                  width: 500,
                  child: AddPatientDialog(), // منبثقة
                ),
              ),
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

  Widget _buildStatistics(AppProvider appProvider, BuildContext context) {
    final stats = [
      {
        'title': 'إجمالي الكمبيالات',
        'value': '${appProvider.totalAmount.toStringAsFixed(0)} د.ع',
        'icon': FontAwesomeIcons.coins,
        'color': const Color(0xFF3498DB),
      },
      {
        'title': 'المبالغ المسددة',
        'value': '${appProvider.paidAmount.toStringAsFixed(0)} د.ع',
        'icon': FontAwesomeIcons.circleCheck,
        'color': const Color(0xFF27AE60),
      },
      {
        'title': 'المبالغ المتبقية',
        'value': '${appProvider.remainingAmount.toStringAsFixed(0)} د.ع',
        'icon': FontAwesomeIcons.hourglassHalf,
        'color': const Color(0xFFF39C12),
      },
      {
        'title': 'عدد الكمبيالات',
        'value': '${appProvider.remainingBillsCount}',
        'icon': FontAwesomeIcons.fileInvoice,
        'color': const Color(0xFFE74C3C),
      },
    ];

    return Column(
      children: [
        Text(
          'الإحصائيات العامة',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF649FCC),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),

        // شبكة الكروت
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // صفين × عمودين
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2, // يصغر البطاقات
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final item = stats[index];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  // ظل غامق
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                  // ظل فاتح (يعطي 3D)
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // دائرة فيها أيقونة
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['value'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: item['color'] as Color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
