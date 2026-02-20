import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cekirdek/servisler/kimlik_servisi.dart';
import 'ekranlar/anasayfa/anasayfa_ekrani.dart';
import 'ekranlar/giris/giris_ekrani.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'ekranlar/web/web_giris_ekrani.dart';

// Global Tema Yöneticisi
final ValueNotifier<ThemeMode> temaYoneticisi = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Kayıtlı Temayı Yükle
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool('isDark') ?? false;
  temaYoneticisi.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // 2. Oturum Kontrolü (Beni Hatırla)
  bool oturumVar = await KimlikServisi.oturumKontrol();

  runApp(EHalisahaUygulamasi(
    baslangicEkrani: oturumVar ? const AnasayfaEkrani() : const GirisEkrani(),
  ));
}

class EHalisahaUygulamasi extends StatelessWidget {
  final Widget baslangicEkrani;
  const EHalisahaUygulamasi({super.key, required this.baslangicEkrani});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'E-HalıSaha',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          
          // DÜZELTME: Sadece bir tane 'home' parametresi olmalı.
          // Web ise özel web girişini, mobil ise oturum durumuna göre belirlenen ekranı açar.
          home: kIsWeb ? const WebGirisEkrani() : baslangicEkrani,

          // AÇIK TEMA
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF22C55E),
            scaffoldBackgroundColor: const Color(0xFFF0FDF4),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            chipTheme: const ChipThemeData(
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),

          // KOYU TEMA
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF22C55E),
            scaffoldBackgroundColor: const Color(0xFF111827),
            cardColor: const Color(0xFF1F2937),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1F2937),
              selectedItemColor: Color(0xFF22C55E),
              unselectedItemColor: Colors.grey,
            ),
            chipTheme: const ChipThemeData(
              labelStyle: TextStyle(color: Colors.white),
              backgroundColor: Color(0xFF374151),
            ),
          ),

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr', 'TR')],
          // DİKKAT: Buradaki ikinci 'home' satırı silindi.
        );
      },
    );
  }
}