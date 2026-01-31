import 'package:flutter/material.dart';
import '../../cekirdek/servisler/rezervasyon_servisi.dart';
import '../../modeller/saha_modeli.dart';

class GecmisRezervasyonlarEkrani extends StatelessWidget {
  const GecmisRezervasyonlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final liste = RezervasyonServisi.rezervasyonlar;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text("Geçmiş Rezervasyonlar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: liste.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // DÜZELTME 1: Olmayan ikon yerine bunu kullandık
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Henüz rezervasyonunuz yok.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: liste.length,
              itemBuilder: (context, index) {
                final kayit = liste[index];
                final SahaModeli saha = kayit['saha'];
                final DateTime tarih = kayit['tarih'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      // Üst Kısım: Resim ve Durum
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(saha.resimYolu, height: 120, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                kayit['durum'],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Alt Kısım: Bilgiler
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarih Kutusu
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDCFCE7)),
                              ),
                              child: Column(
                                children: [
                                  Text("${tarih.day}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                                  Text(_ayAdi(tarih.month), style: const TextStyle(fontSize: 12, color: Color(0xFF15803D))),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Detaylar
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(saha.isim, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text("${kayit['saat']} - ${kayit['ucret'].toStringAsFixed(0)}₺", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // DÜZELTME 2: 'il' değişkeni modelde yoktu, sildik.
                                  Text("📍 ${saha.ilce}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _ayAdi(int ayNo) {
    const aylar = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    return aylar[ayNo];
  }
}