import 'package:flutter/material.dart';
import 'ekranlar/anasayfa/anasayfa_ekrani.dart';
import 'ekranlar/giris/giris_ekrani.dart';
import 'cekirdek/servisler/kimlik_servisi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Uygulama açılırken giriş yapılıp yapılmadığını kontrol et
  bool girisYapildi = await KimlikServisi.girisYapildiMi();
  
  runApp(MyApp(baslangicEkrani: girisYapildi ? const AnasayfaEkrani() : const GirisEkrani()));
}

class MyApp extends StatelessWidget {
  final Widget baslangicEkrani;
  const MyApp({super.key, required this.baslangicEkrani});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-HalıSaha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Web'deki bg-gray-50
      ),
      // Uygulama açıldığında hangi ekranın geleceğini buradan belirliyoruz
      home: baslangicEkrani,
      routes: {
        '/login': (context) => const GirisEkrani(),
        '/home': (context) => const AnasayfaEkrani(),
      },
    );
  }
}