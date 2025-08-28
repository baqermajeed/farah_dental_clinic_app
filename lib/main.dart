import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'providers/app_provider.dart';

// 👇 مضافة حتى يدعم Windows/Linux
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات إذا كان النظام Windows أو Linux
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const DentalClinicApp());
}

class DentalClinicApp extends StatelessWidget {
  const DentalClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'عيادة فرح لطب الأسنان',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // الألوان الرئيسية
          primarySwatch: const MaterialColor(0xFF649FCC, {
            50: Color(0xFFE3F2FD),
            100: Color(0xFFBBDEFB),
            200: Color(0xFF90CAF9),
            300: Color(0xFF64B5F6),
            400: Color(0xFF42A5F5),
            500: Color(0xFF649FCC),
            600: Color(0xFF1E88E5),
            700: Color(0xFF1976D2),
            800: Color(0xFF1565C0),
            900: Color(0xFF0D47A1),
          }),

          // الألوان المخصصة
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF649FCC),
            primary: const Color(0xFF649FCC),
            secondary: const Color(0xFFD0EBFF),
            surface: const Color(0xFFF2EDE9),
            background: const Color(0xFFF2EDE9),
          ),

          // الخطوط
          fontFamily: 'Cairo',
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF34495E),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF34495E),
            ),
          ),

          // تصميم الأزرار
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF649FCC),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: const Color(0xFF649FCC).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),

          // تصميم حقول الإدخال
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF649FCC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFD0EBFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF649FCC), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),

          // تصميم البطاقات
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: const Color(0xFF649FCC).withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
          ),

          // شريط التطبيق
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF649FCC),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // التحقق من حالة تسجيل الدخول عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // إذا كان التطبيق يتحقق من حالة تسجيل الدخول
        if (appProvider.isLoading) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF649FCC),
                    Color(0xFFD0EBFF),
                    Color(0xFFF2EDE9),
                  ],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'جاري تحميل التطبيق...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // إذا كان المستخدم مسجل الدخول
        if (appProvider.isLoggedIn) {
          return const DashboardScreen();
        }

        // إذا لم يكن مسجل الدخول
        return const LoginScreen();
      },
    );
  }
}
