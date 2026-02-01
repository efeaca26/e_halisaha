import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ekranlar/giris/giris_ekrani.dart';

// TEMA YÖNETİCİSİ (Global Değişken)
ValueNotifier<ThemeMode> temaYoneticisi = ValueNotifier(ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EHalisahaUygulamasi());
}

class EHalisahaUygulamasi extends StatelessWidget {
  const EHalisahaUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'E-HalıSaha',
          debugShowCheckedModeBanner: false,
          
          // --- TEMA AYARLARI ---
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF22C55E),
            scaffoldBackgroundColor: const Color(0xFFF0FDF4),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white, 
              foregroundColor: Colors.black,
              elevation: 0
            ),
            // Diğer light tema ayarları...
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF22C55E),
            scaffoldBackgroundColor: const Color(0xFF111827), // Koyu gri
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0
            ),
            // Diğer dark tema ayarları...
          ),
          
          // --- DİL AYARLARI ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr', 'TR'),
          ],
          home: const GirisEkrani(),
        );
      },
    );
  }
}