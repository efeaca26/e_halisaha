import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <--- BU PAKETİ EKLEDİK
import 'ekranlar/giris/giris_ekrani.dart';

void main() {
  runApp(const EHalisahaUygulamasi());
}

class EHalisahaUygulamasi extends StatelessWidget {
  const EHalisahaUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-HalıSaha',
      debugShowCheckedModeBanner: false,
      
      // --- İŞTE EKSİK OLAN KISIM BURASIYDI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // Türkçe
        Locale('en', 'US'), // İngilizce (Yedek)
      ],
      // ----------------------------------------

      theme: ThemeData(
        primaryColor: const Color(0xFF22C55E),
        scaffoldBackgroundColor: const Color(0xFFF0FDF4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E),
          primary: const Color(0xFF22C55E),
          secondary: const Color(0xFF3B82F6),
          error: const Color(0xFFEF4444),
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
          ),
        ),
      ),
      home: const GirisEkrani(),
    );
  }
}