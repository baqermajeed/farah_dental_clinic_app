import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
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
      backgroundColor: Colors.grey[100],
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5BA0D4),
              ),
            );
          }

          return Stack(
            children: [
              // الشريط العلوي الأزرق
              Positioned(
                left: 40,
                top: 30,
                right: 309,
                child: Container(
                  width: 1091,
                  height: 92,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 30, 84, 120),
                        Color.fromARGB(255, 30, 84, 120)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'الصفحة الرئيسية',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ),

              // العمود الأيمن - الملف الشخصي
              Positioned(
                top: 30,
                right: 30,
                bottom: 30,
                child: Container(
                  width: 256,
                  height: 986,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 30, 84, 120),
                        Color.fromARGB(255, 0, 0, 0)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // صورة الملف الشخصي
                      const SizedBox(height: 50),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/new-farah.png", // مسار الصورة داخل مجلد assets
                            fit: BoxFit.cover, // تخلي الصورة تغطي الدائرة كاملة
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      // النص
                      Consumer<AppProvider>(
                        builder: (context, appProvider, child) {
                          return const Column(
                            children: [
                              Text(
                                'عيادة فرح لطب',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                'الاسنان',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      // أيقونة الإعدادات
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60.0),
                        child: Consumer<AppProvider>(
                          builder: (context, appProvider, child) {
                            return PopupMenuButton<String>(
                              icon: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (value) async {
                                if (value == 'logout') {
                                  await appProvider.logout();
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'user_info',
                                  enabled: false,
                                  child: Text(
                                      'مرحباً ${appProvider.currentUser ?? 'المستخدم'}'),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem<String>(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, size: 18),
                                      SizedBox(width: 8),
                                      Text('تسجيل الخروج'),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // العمود الأوسط - كروت الإحصائيات
              Positioned(
                left: 621, // من اليسار + عرض عمود الأزرار + المسافة بينهما
                top: 150, // من الأعلى + المسافة عن الشريط العلوي
                child: SizedBox(
                  width: 455,
                  height: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                        'إجمالي الكمبيالات',
                        appProvider.totalAmount.toStringAsFixed(0),
                        Icons.account_balance_wallet,
                        const Color(0xFF5BA0D4),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildStatCard(
                        'المبالغ المسددة',
                        appProvider.paidAmount.toStringAsFixed(0),
                        Icons.savings,
                        const Color(0xFF5BA0D4),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildStatCard(
                        'المبالغ المتبقية',
                        appProvider.remainingAmount.toStringAsFixed(0),
                        Icons.water_drop,
                        const Color(0xFF5BA0D4),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildStatCard(
                        'الكمبيالات المتبقية',
                        '${appProvider.remainingBillsCount}',
                        Icons.receipt_long,
                        const Color(0xFF5BA0D4),
                      ),
                    ],
                  ),
                ),
              ),

              // العمود الأيسر - الأزرار
              Positioned(
                left: 69,
                top: 175, // من الأعلى + المسافة عن الشريط العلوي
                child: SizedBox(
                  width: 413,
                  height: 517,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSidebarButton(
                        'تسجيل مريض جديد',
                        Icons.person_add_outlined,
                        () => showDialog(
                          context: context,
                          builder: (context) => const AddPatientDialog(),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildSidebarButton(
                        'تسديد كمبيالة',
                        Icons.account_balance_wallet_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentScreen()),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildSidebarButton(
                        'التسديدات المتأخرة',
                        Icons.refresh_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const OverduePaymentsScreen()),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      _buildSidebarButton(
                        'طباعة استمارة',
                        Icons.print_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InvoiceFormScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // بناء أزرار الشريط الجانبي
  Widget _buildSidebarButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      width: 412,
      height: 100,
      margin: const EdgeInsets.only(bottom: 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 30, 84, 120),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 196, 9, 9).withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء كارت الإحصائيات
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 500,
      height: 130, // زيادة الارتفاع من 130 إلى 150
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(141, 61, 187, 229).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // زيادة الـ padding من 5 إلى 12
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center, // توسيط النص
              style: const TextStyle(
                fontSize: 22, // تقليل قليلاً من 24 إلى 22
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 0, 0, 0),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8), // زيادة من 5 إلى 8
            Icon(
              icon,
              color: color,
              size: 28, // تقليل قليلاً من 30 إلى 28
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center, // توسيط النص
              style: TextStyle(
                fontSize: 22, // تقليل قليلاً من 24 إلى 22
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
