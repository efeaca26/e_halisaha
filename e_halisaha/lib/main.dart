import 'package:flutter/material.dart';
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
      theme: ThemeData(
        // Dokümandaki #22c55e (Tailwind Green-500) rengi
        primaryColor: const Color(0xFF22C55E),
        
        // Arka plan rengi (Gradient kullanacağız ama varsayılan beyaz kalsın)
        scaffoldBackgroundColor: const Color(0xFFF0FDF4), // green-50 tonu
        
        // Renk şeması
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22C55E),
          primary: const Color(0xFF22C55E), // Ana Yeşil
          secondary: const Color(0xFF3B82F6), // Mavi
          error: const Color(0xFFEF4444), // Kırmızı
          surface: Colors.white,
        ),
        
        useMaterial3: true,
        fontFamily: 'Roboto',
        
        // Input dekorasyonu (Dokümandaki gri border stili)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)), // Gray-300
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2), // Focus Green
          ),
        ),
      ),
      home: const GirisEkrani(),
    );
  }
}