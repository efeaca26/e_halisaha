import 'package:flutter/material.dart';

// Ortak bir şablon sayfa yapıyoruz, hepsi bunu kullanacak
class GenelAltSayfa extends StatelessWidget {
  final String baslik;
  final IconData ikon;

  const GenelAltSayfa({super.key, required this.baslik, required this.ikon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0FDF4),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text("$baslik Burada Olacak", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Bu özellik geliştirme aşamasındadır.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 1. Hesap Bilgileri Sayfası
class HesapBilgileriEkrani extends StatelessWidget {
  const HesapBilgileriEkrani({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hesap Bilgileri")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _bilgiSatiri("Ad Soyad", "Efe A."),
            _bilgiSatiri("E-Posta", "oyuncu@mail.com"),
            _bilgiSatiri("Telefon", "+90 555 000 00 00"),
            _bilgiSatiri("Doğum Tarihi", "01.01.2000"),
          ],
        ),
      ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey)),
          Text(deger, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}