import 'package:flutter/material.dart';
import 'ekranlar/anasayfa/anasayfa_ekrani.dart';

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
        primarySwatch: Colors.green, 
        useMaterial3: true,
      ),
      home: const AnasayfaEkrani(),
    );
  }
}