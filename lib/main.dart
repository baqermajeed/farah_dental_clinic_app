import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/app_provider.dart';

void main() {
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
          primarySwatch: MaterialColor(0xFF649FCC, {
            50: const Color(0xFFE3F2FD),
            100: const Color(0xFFBBDEFB),
            200: const Color(0xFF90CAF9),
            300: const Color(0xFF64B5F6),
            400: const Color(0xFF42A5F5),
            500: const Color(0xFF649FCC),
            600: const Color(0xFF1E88E5),
            700: const Color(0xFF1976D2),
            800: const Color(0xFF1565C0),
            900: const Color(0xFF0D47A1),
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
        home: const LoginScreen(),
      ),
    );
  }
}
