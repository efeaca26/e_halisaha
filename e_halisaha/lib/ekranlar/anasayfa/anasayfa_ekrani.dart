import 'package:flutter/material.dart';
import '../harita/harita_ekrani.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/ornek_veri.dart';
import '../saha_detay/saha_detay_ekrani.dart';
import '../profil/profil_ekrani.dart';
import '../rakip_bul/rakip_bul_ekrani.dart';

class AnasayfaEkrani extends StatefulWidget {
  const AnasayfaEkrani({super.key});

  @override
  State<AnasayfaEkrani> createState() => _AnasayfaEkraniState();
}

class _AnasayfaEkraniState extends State<AnasayfaEkrani> {
  int _seciliIndex = 0;

  final List<Widget> _sayfalar = [
    const AnasayfaIcerik(),
    const HaritaEkrani(),
    const ProfilEkrani(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sayfalar[_seciliIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seciliIndex,
        onDestinationSelected: (index) => setState(() => _seciliIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Harita'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class AnasayfaIcerik extends StatefulWidget {
  const AnasayfaIcerik({super.key});

  @override
  State<AnasayfaIcerik> createState() => _AnasayfaIcerikState();
}

class _AnasayfaIcerikState extends State<AnasayfaIcerik> {
  final List<SahaModeli> tumSahalar = SahteVeriServisi.sahalariGetir();
  List<SahaModeli> goruntulenenSahalar = [];

  @override
  void initState() {
    super.initState();
    goruntulenenSahalar = tumSahalar;
  }

  void _saharaAra(String aramaMetni) {
    setState(() {
      goruntulenenSahalar = tumSahalar.where((saha) {
        final isim = saha.isim.toLowerCase();
        final ilce = saha.ilce.toLowerCase();
        final aranan = aramaMetni.toLowerCase();
        return isim.contains(aranan) || ilce.contains(aranan);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Merhaba, Kaptan! 👋", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text("Maç Yapmaya Hazır mısın?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF22C55E),
                  child: Icon(Icons.sports_soccer, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              onChanged: _saharaAra,
              decoration: InputDecoration(
                hintText: "Saha, ilçe veya takım ara...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white, // Basit renk (Hata vermemesi için)
              ),
            ),
            
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RakipBulEkrani()));
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.groups, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Rakip mi Arıyorsun?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Seviyene uygun takımları bul ve davet et!", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text("Popüler Sahalar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            goruntulenenSahalar.isEmpty 
              ? const Center(child: Text("Aradığınız kriterde saha bulunamadı."))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goruntulenenSahalar.length,
                  itemBuilder: (context, index) {
                    final saha = goruntulenenSahalar[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.asset(saha.resimYolu, height: 150, width: double.infinity, fit: BoxFit.cover)),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(saha.isim, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text("📍 ${saha.tamKonum}", style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Text("${saha.fiyat.toStringAsFixed(0)}₺ / Saat", style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}