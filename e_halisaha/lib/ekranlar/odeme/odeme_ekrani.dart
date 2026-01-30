import 'package:flutter/material.dart';
import 'dart:async';
import '../../modeller/saha_modeli.dart';

class OdemeEkrani extends StatefulWidget {
  final SahaModeli saha;
  final String saat;

  const OdemeEkrani({super.key, required this.saha, required this.saat});

  @override
  State<OdemeEkrani> createState() => _OdemeEkraniState();
}

class _OdemeEkraniState extends State<OdemeEkrani> {
  int kalanSaniye = 300; // [cite: 130] 5 dakika = 300 saniye
  Timer? timer;

  @override
  void initState() {
    super.initState();
    baslatSayac();
  }

  //  Geri sayım sayacı
  void baslatSayac() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (kalanSaniye > 0) {
        setState(() {
          kalanSaniye--;
        });
      } else {
        // Süre bitti, ana sayfaya at (Simülasyon)
        timer.cancel();
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Süre doldu! Slot serbest bırakıldı.")),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String sureFormatla(int saniye) {
    int dk = saniye ~/ 60;
    int sn = saniye % 60;
    return "$dk:${sn.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ödeme Onayı")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sarı Uyarı Alanı
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Bu saati sizin için ayırdık. İşlemi tamamlamak için kalan süreniz: ${sureFormatla(kalanSaniye)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Özet Bilgiler [cite: 107]
            _bilgiSatiri("Tesis", widget.saha.isim),
            _bilgiSatiri("Tarih", "30 Ocak 2026"),
            _bilgiSatiri("Saat", widget.saat),
            const Divider(),
            _bilgiSatiri("Toplam Ücret", "${widget.saha.fiyat} TL"),
            _bilgiSatiri("Ödenecek Kapora", "${widget.saha.kapora} TL", renk: Colors.green),
            
            const Spacer(),
            
            // Ödeme Butonu [cite: 23]
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Başarılı Ödeme Simülasyonu
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
                    content: const Text("Rezervasyonunuz Başarıyla Oluşturuldu!\nSaha sahibine bildirim gönderildi."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // En başa dön
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        child: const Text("Tamam"),
                      )
                    ],
                  ),
                );
              },
              child: const Text("KAPORAYI ÖDE VE BİTİR", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger, {Color renk = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(deger, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: renk)),
        ],
      ),
    );
  }
}