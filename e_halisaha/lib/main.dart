import 'package:flutter/material.dart';
import 'ekranlar/giris/giris_ekran.dart'; // Yeni giriş ekranını import ettik

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
        // Modern renk paleti
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      // ARTIK BURADAN BAŞLIYORUZ:
      home: const GirisEkrani(),
    );
  }
}