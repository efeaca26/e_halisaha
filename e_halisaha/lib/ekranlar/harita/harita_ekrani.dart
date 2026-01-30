import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/ornek_veri.dart';
import '../saha_detay/saha_detay_ekrani.dart';

class HaritaEkrani extends StatefulWidget {
  const HaritaEkrani({super.key});

  @override
  State<HaritaEkrani> createState() => _HaritaEkraniState();
}

class _HaritaEkraniState extends State<HaritaEkrani> {
  List<SahaModeli> tumSahalar = [];
  SahaModeli? _seciliSaha; // Haritada hangisine tıklandı?

  // Gebze Merkez Koordinatları
  final LatLng _merkezKonum = const LatLng(40.8028, 29.4307);

  @override
  void initState() {
    super.initState();
    tumSahalar = SahteVeriServisi.sahalariGetir();
  }

  // Sahalarımıza sahte koordinat atayalım (Normalde veritabanından gelir)
  LatLng _koordinatUret(int index) {
    // Gebze etrafına rastgele dağıtıyoruz
    if (index == 0) return const LatLng(40.8050, 29.4350);
    if (index == 1) return const LatLng(40.7990, 29.4280);
    return const LatLng(40.8010, 29.4400);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. HARİTA KATMANI ---
          FlutterMap(
            options: MapOptions(
              initialCenter: _merkezKonum,
              initialZoom: 13.5,
              onTap: (_, __) => setState(() => _seciliSaha = null), // Boşluğa tıklayınca kartı kapat
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.e_halisaha',
              ),
              MarkerLayer(
                markers: List.generate(tumSahalar.length, (index) {
                  final saha = tumSahalar[index];
                  final konum = _koordinatUret(index);
                  final seciliMi = _seciliSaha == saha;

                  return Marker(
                    point: konum,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _seciliSaha = saha;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: seciliMi ? const Color(0xFF22C55E) : Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)
                          ],
                        ),
                        child: Icon(
                          Icons.sports_soccer, 
                          color: Colors.white, 
                          size: seciliMi ? 35 : 25
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          // --- 2. ÜST ARAMA KUTUSU (GÖRSEL) ---
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Text("Haritada ara...", style: TextStyle(color: Colors.grey)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                    child: const Icon(Icons.filter_list, color: Colors.black),
                  )
                ],
              ),
            ),
          ),

          // --- 3. ALT BİLGİ KARTI (Pin Tıklanınca Çıkar) ---
          if (_seciliSaha != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: _seciliSaha!)));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                  ),
                  child: Row(
                    children: [
                      // Resim
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(_seciliSaha!.resimYolu, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 15),
                      // Yazılar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_seciliSaha!.isim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 5),
                            Text("📍 ${_seciliSaha!.tamKonum}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 5),
                            Text("${_seciliSaha!.fiyat.toStringAsFixed(0)}₺ / Saat", style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Ok Butonu
                      const CircleAvatar(
                        backgroundColor: Color(0xFF22C55E),
                        child: Icon(Icons.arrow_forward, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}