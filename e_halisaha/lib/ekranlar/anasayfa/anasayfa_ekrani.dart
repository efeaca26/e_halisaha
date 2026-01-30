import 'package:flutter/material.dart';
import '../../cekirdek/servisler/ornek_veri.dart';
import 'package:e_halisaha/modeller/saha_model.dart';
import '../saha_detay/saha_detay_ekrani.dart';

class AnasayfaEkrani extends StatefulWidget {
  const AnasayfaEkrani({super.key});

  @override
  State<AnasayfaEkrani> createState() => _AnasayfaEkraniState();
}

class _AnasayfaEkraniState extends State<AnasayfaEkrani> {
  List<SahaModeli> tumSahalar = [];
  List<SahaModeli> filtrelenmisSahalar = [];
  String secilenFiltre = 'Tümü';

  @override
  void initState() {
    super.initState();
    tumSahalar = SahteVeriServisi.sahalariGetir();
    filtrelenmisSahalar = tumSahalar;
  }

  void filtrele(String ozellik) {
    setState(() {
      secilenFiltre = ozellik;
      if (ozellik == 'Tümü') {
        filtrelenmisSahalar = tumSahalar;
      } else {
        filtrelenmisSahalar = tumSahalar
            .where((saha) => saha.ozellikler.contains(ozellik))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("E-Halı Saha", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Konum: Kocaeli, Gebze", style: TextStyle(fontSize: 12)), // 
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.map))],
      ),
      body: Column(
        children: [
          // Arama Çubuğu [cite: 90]
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Saha adı veya ilçe ara...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          
          // Filtreler (Yatay Liste) 
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _filtreCip("Tümü"),
                _filtreCip("Kapalı Saha"),
                _filtreCip("Duş"),
                _filtreCip("Otopark"),
              ],
            ),
          ),

          // Saha Listesi [cite: 94]
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtrelenmisSahalar.length,
              itemBuilder: (context, index) {
                final saha = filtrelenmisSahalar[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SahaDetayEkrani(saha: saha),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saha Resmi
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.asset(saha.resimYolu, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(saha.isim, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                                    child: Text("${saha.puan}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text("📍 ${saha.tamKonum}", style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${saha.fiyat.toStringAsFixed(0)} TL / Saat", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text("Detaylar >", style: TextStyle(color: Colors.green)),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtreCip(String baslik) {
    bool secili = secilenFiltre == baslik;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(baslik),
        selected: secili,
        selectedColor: Colors.green[100],
        checkmarkColor: Colors.green,
        onSelected: (val) => filtrele(baslik),
      ),
    );
  }
}