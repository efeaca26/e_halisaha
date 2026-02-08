import 'package:flutter/material.dart';
import '../../modeller/takim_modeli.dart'; // Model dosyasını içeri aldık

class RakipBulEkrani extends StatefulWidget {
  const RakipBulEkrani({super.key});

  @override
  State<RakipBulEkrani> createState() => _RakipBulEkraniState();
}

class _RakipBulEkraniState extends State<RakipBulEkrani> {
  // Örnek veriler (Hata veren kısım burasıydı, şimdi düzeldi)
  final List<TakimModeli> takimlar = [
    TakimModeli(
      id: "1",
      isim: "Yıldırım Spor",
      seviye: "Dişli",
      yildiz: 4.5,
      kaptanId: "101",
    ),
    TakimModeli(
      id: "2",
      isim: "Kuzey Gücü",
      seviye: "Amatör",
      yildiz: 3.0,
      kaptanId: "102",
    ),
    TakimModeli(
      id: "3",
      isim: "Atalanta FC",
      seviye: "Pro",
      yildiz: 5.0,
      kaptanId: "103",
    ),
    TakimModeli(
      id: "4",
      isim: "Mahalle Gençlik",
      seviye: "Amatör",
      yildiz: 2.5,
      kaptanId: "104",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rakip Bul", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF22C55E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Müsait Rakipler",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: takimlar.length,
                itemBuilder: (context, index) {
                  final takim = takimlar[index];
                  return _takimKarti(takim);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _takimKarti(TakimModeli takim) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green.shade100,
          child: Text(
            takim.isim[0], // Takım isminin baş harfi
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        title: Text(
          takim.isim,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.shield, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 5),
                Text("Seviye: ${takim.seviye}", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 5),
                Text(takim.yildiz.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${takim.isim} takımına maç teklifi gönderildi!")),
            );
          },
          child: const Text("Maç Yap", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}