import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/add_patient_dialog.dart';
import 'payment_screen.dart';
import 'overdue_payments_screen.dart';
import 'invoice_form_screen.dart';
import 'notifications_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// نوع الكارد - دائري أو شريطي
enum CardType { circular, bar }

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
              // صف علوي يحتوي الأزرار الثلاثة بشكل أفقي
              Positioned(
                left: 350,
                top: 20,
                right: 180, // اترك مساحة للعمود الأيمن بعد تصغيره
                child: SizedBox(
                  height: 70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      textDirection:
                          TextDirection.rtl, // 🔹 ترتيب من اليمين لليسار
                      children: [
                        SizedBox(
                          width: 320,
                          height: 60,
                          child: _buildTopButton(
                            'تسجيل مريض جديد',
                            Icons.person_add_outlined,
                            () => showDialog(
                              context: context,
                              builder: (context) => const AddPatientDialog(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 320,
                          height: 60,
                          child: _buildTopButton(
                            'تسديد كمبيالة',
                            Icons.payment,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PaymentScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 320,
                          height: 60,
                          child: _buildTopButton(
                            'التسديدات المتأخرة',
                            Icons.refresh_outlined,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const OverduePaymentsScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // شريط البحث أسفل الأزرار بمسافة 70، يبعد 170 عن الحافة اليمنى
              Positioned(
                top: 30 + 70 + 30,
                right: 185,
                child: SizedBox(
                  width: 600,
                  height: 50,
                  child: _buildSearchBar(),
                ),
              ),

              // نص عنوان التنبيهات
              Positioned(
                top: 30 + 70 + 50 + 50, // فوق كونتينر الإشعارات بمسافة 20
                right: 185, // نفس مسافة شريط البحث من الحافة اليمنى
                child: SizedBox(
                  width: 970,
                  child: Text(
                    'التنبيــهـــات الهـامـة و الفــوريـة',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 30, 84, 120),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),

              // كونتينر الإشعارات أسفل شريط البحث بمسافة 50
              Positioned(
                top: 30 + 70 + 50 + 50 + 60, // أسفل شريط البحث بمسافة 50
                right: 185, // نفس مسافة شريط البحث من الحافة اليمنى
                child: SizedBox(
                  width: 1000,
                  height: 85,
                  child: _buildNotificationsContainer(),
                ),
              ),

              // زر طباعة استمارة بمحاذاة شريط البحث مع مسافة 20 بينهما
              Positioned(
                top: 30 + 70 + 30,
                right: 170 + 600 + 40, // 170 + عرض شريط البحث + 20 مسافة
                child: SizedBox(
                  width: 290,
                  height: 50,
                  child: _buildSlimButton(
                    'طباعة استمارة',
                    Icons.print_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InvoiceFormScreen()),
                    ),
                  ),
                ),
              ),

              // العمود الأيمن - الملف الشخصي
              Positioned(
                top: 10,
                right: 30,
                bottom: 10,
                child: Container(
                  width: 130,
                  height: 986,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 30, 84, 120),
                        Color.fromARGB(255, 30, 84, 120),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // صورة الملف الشخصي
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/new-farah.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // النص
                      Consumer<AppProvider>(
                        builder: (context, appProvider, child) {
                          return Column(
                            children: [
                              Text(
                                'عيادة فرح',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      // زر تسجيل الخروج
                      Consumer<AppProvider>(
                        builder: (context, appProvider, child) {
                          return PopupMenuButton<String>(
                            child: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 20, // حجم الأيقونة
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
                      const SizedBox(height: 30), // المسافة من القاع
                    ],
                  ),
                ),
              ),

              // زر الإشعارات في العمود الأيمن يبعد 350 عن الحافة السفلية
              Positioned(
                right: 65,
                bottom: 350,
                child: Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            // الشارة بعدد الإشعارات
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Consumer<AppProvider>(
                                builder: (context, app, _) {
                                  final count = app.notificationPatients.length;
                                  if (count == 0)
                                    return const SizedBox.shrink();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // العمود الأيسر - كروت الإحصائيات المحدثة
              Positioned(
                top: 10,
                left: 30,
                bottom: 10,
                child: Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 30, 84, 120),
                        Color.fromARGB(255, 0, 0, 0)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // أبقي باقي المحتويات كما هي
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        // العنوان فقط بمحاذاة اليمين
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'إحصائيات العيادة',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),

                        // الإحصائيات الدائرية العلوية
                        _buildStatCardForColumn(
                          'إجمالي الكمبيالات',
                          appProvider.totalAmount.toStringAsFixed(0),
                          Icons.account_balance_wallet,
                          Color.fromARGB(255, 30, 84, 120),
                          cardType: CardType.circular,
                          subtitle: 'المبلغ الكلي للكمبيالات',
                        ),
                        const SizedBox(height: 26),

                        _buildStatCardForColumn(
                          'المبالغ المسددة',
                          appProvider.paidAmount.toStringAsFixed(0),
                          Icons.savings,
                          const Color(0xFF0E9EC8),
                          cardType: CardType.circular,
                          subtitle: 'المبالغ المسددة من الكمبيالات',
                        ),

                        SizedBox(
                          height: 40,
                        ), // الإحصائيات الشريطية السفلية
                        _buildStatCardForColumn(
                          'المبالغ المتبقية',
                          appProvider.remainingAmount.toStringAsFixed(0),
                          Icons.water_drop,
                          const Color.fromARGB(255, 95, 101, 113),
                          cardType: CardType.bar,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        _buildStatCardForColumn(
                          'الكمبيالات المتبقية',
                          '${appProvider.remainingBillsCount}',
                          Icons.receipt_long,
                          const Color.fromARGB(255, 108, 42, 42),
                          cardType: CardType.bar,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ويدجت مخصص لعرض إحصائيات بتصميمات مختلفة مطابقة للتصميم المرفق
  Widget _buildStatCardForColumn(
    String title,
    String value,
    IconData icon,
    Color color, {
    CardType cardType = CardType.circular,
    String? subtitle,
  }) {
    if (cardType == CardType.circular) {
      return _buildCircularCard(title, value, icon, color, subtitle);
    } else {
      return _buildBarCard(title, value, icon, color);
    }
  }

  /// كارد دائري مع دائرة كبيرة في المنتصف (للإحصائيات الرئيسية)
  Widget _buildCircularCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String? subtitle,
  ) {
    return Container(
      width: 260,
      height: 120,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF236B8C).withOpacity(0.66), // اللون الجديد للمربع
        borderRadius: BorderRadius.circular(12),
        // ✅ تمت إزالة الـ Border (stroke)
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // الدائرة الكبيرة في أعلى المربع
          Positioned(
            top: -35,
            left: (200 / 2) - 10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF14A3C9), // اللون الأول
                    Color(0xFF145566), // اللون الثاني
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14A3C9).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _formatValue(value),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // النصوص في منتصف المربع
          Positioned.fill(
            top: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // العنوان الرئيسي
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 170, 205, 228),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // العنوان الفرعي
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// كارد شريطي أفقي (للإحصائيات الثانوية)
  Widget _buildBarCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // الشريط الأساسي
        Container(
          width: 260, // ✅ نفس عرض الكارد الدائري حتى يصيروا بمحاذاة واحدة
          height: 50,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              colors: [
                Color(0xFF0E9EC8),
                Color(0xFF0E9EC8),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF26C6DA).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_shouldShowValueInCircle(value))
                  Text(
                    _formatValue(value),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // الدائرة خارج الشريط من الجهة اليسرى
        Positioned(
          left: -15,
          top: -5,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: _shouldShowValueInCircle(value)
                  ? Text(
                      value,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: 26,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// دالة مساعدة لتحديد ما إذا كانت القيمة يجب أن تظهر في الدائرة الصغيرة
  bool _shouldShowValueInCircle(String value) {
    // إذا كانت القيمة رقم صغير (أقل من 100) أو نص قصير
    final numValue = double.tryParse(value);
    return (numValue != null && numValue < 100) || value.length <= 3;
  }

  /// دالة مساعدة لتنسيق القيم الكبيرة
  String _formatValue(String value) {
    final numValue = double.tryParse(value);
    if (numValue != null && numValue >= 1000000) {
      return '${(numValue / 1000000).toStringAsFixed(1)}M';
    } else if (numValue != null && numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(1)}K';
    }
    return value;
  }

  // زر علوي مدمج للاستخدام ضمن صف الأزرار
  Widget _buildTopButton(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 30, 84, 120), // لون الزر أزرق غامق
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color:
                      const Color.fromARGB(255, 255, 255, 255), // أيقونة بيضاء
                  size: 24,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      color:
                          const Color.fromARGB(255, 255, 255, 255), // أزرق فاتح
                      fontWeight: FontWeight.w700, // يمكن تعديل الوزن إذا تريد
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // زر رفيع للطباعة
  Widget _buildSlimButton(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
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
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // شريط البحث عن المرضى مع أيقونة وظل ونص Cairo Bold أسود
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // زوايا الشريط
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 45, 44, 44)
                .withOpacity(0.1), // ظل خفيف
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        textAlignVertical: TextAlignVertical.center, // النص بالسنتر عمودياً
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w200, // Bold
          color: Colors.black, // لون النص أسود
          fontSize: 10,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن مريض',
          hintTextDirection: TextDirection.rtl,
          hintStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black54, // لون النص المساعد شوي فاتح
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white, // خلفية الشريط
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),

          // الأيقونة داخل كونتينر أزرق 50x50 مع بوردر ريديوس
          prefixIcon: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 59, 155, 157),
              borderRadius: BorderRadius.circular(12), // زوايا الأيقونة
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 50,
            minHeight: 50,
          ),

          // إزالة الحدود
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (query) {
          // يمكن لاحقاً ربطه ببحث فعلي من المزود
        },
      ),
    );
  }

  // كونتينر الإشعارات
  Widget _buildNotificationsContainer() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final hasNotifications = appProvider.notificationPatients.isNotEmpty;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          child: Container(
            width: 910,
            height: 75,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 45, 44, 44)
                      .withOpacity(0.1), // ظل خفيف
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              color: const Color(0xFFFEFEEA), // لون كريمي فاتح
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  // سهم التنقل
                  const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF5BA0D4),
                    size: 16,
                  ),
                  const SizedBox(width: 15),
                  // النص
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hasNotifications
                              ? 'لديك إشعارات جديدة اضغط لعرضها'
                              : 'لا توجد إشعارات',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w800, // نفس الوزن السابق
                            color: const Color.fromARGB(
                                255, 30, 84, 120), // أزرق داكن
                          ),
                        ),
                        if (!hasNotifications) ...[
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'سيتم اعلامك بالجديد',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: const Color.fromARGB(
                                      255, 30, 31, 31), // أزرق فاتح
                                  fontWeight: FontWeight
                                      .normal, // يمكن تعديل الوزن إذا تريد
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.bolt,
                                color: Color(0xFFFF9800),
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
        );
      },
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
}
