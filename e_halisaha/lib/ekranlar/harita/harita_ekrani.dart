import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // <--- GPS Paketi
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
  List<SahaModeli> goruntulenenSahalar = [];
  
  SahaModeli? _seciliSaha;
  final MapController _mapController = MapController();
  final TextEditingController _aramaController = TextEditingController();

  // Varsayılan Konum (Gebze)
  LatLng _merkezKonum = const LatLng(40.8028, 29.4307);

  final List<String> _aktifFiltreler = [];
  final List<String> _tumOzellikler = ["Kapalı Saha", "Duş", "Otopark", "Kafe", "Servis"];

  @override
  void initState() {
    super.initState();
    tumSahalar = SahteVeriServisi.sahalariGetir();
    goruntulenenSahalar = tumSahalar;
  }

  // --- GPS: KONUMA GİT ---
  Future<void> _konumaGit() async {
    bool servisAcikMi;
    LocationPermission izin;

    // 1. GPS Açık mı?
    servisAcikMi = await Geolocator.isLocationServiceEnabled();
    if (!servisAcikMi) {
      if (mounted) _hataGoster("Lütfen telefonunuzun konum servisini açın.");
      return;
    }

    // 2. İzin Kontrolü
    izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
      if (izin == LocationPermission.denied) {
        if (mounted) _hataGoster("Konum izni reddedildi.");
        return;
      }
    }

    if (izin == LocationPermission.deniedForever) {
      if (mounted) _hataGoster("Konum izni kalıcı olarak reddedildi. Ayarlardan açmanız lazım.");
      return;
    }

    // 3. Konumu Al ve Haritayı Kaydır
    try {
      Position konum = await Geolocator.getCurrentPosition();
      
      // Haritayı hareket ettir
      _mapController.move(LatLng(konum.latitude, konum.longitude), 15);
      
      // Merkez konumu güncelle (Belki ileride lazım olur)
      setState(() {
        _merkezKonum = LatLng(konum.latitude, konum.longitude);
      });

    } catch (e) {
      if (mounted) _hataGoster("Konum alınamadı.");
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: Colors.red));
  }

  void _filtrele() {
    String aramaMetni = _aramaController.text.toLowerCase();

    setState(() {
      goruntulenenSahalar = tumSahalar.where((saha) {
        bool isimUyumu = saha.isim.toLowerCase().contains(aramaMetni) || 
                         saha.ilce.toLowerCase().contains(aramaMetni);
        bool ozellikUyumu = _aktifFiltreler.isEmpty || 
                            _aktifFiltreler.every((ozellik) => saha.ozellikler.contains(ozellik));
        return isimUyumu && ozellikUyumu;
      }).toList();

      if (goruntulenenSahalar.isNotEmpty && goruntulenenSahalar.length == 1) {
        _seciliSaha = goruntulenenSahalar.first;
      }
    });
  }

  void _filtrePenceresiniAc() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Özelliklere Göre Filtrele", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _tumOzellikler.map((ozellik) {
                      bool secili = _aktifFiltreler.contains(ozellik);
                      return FilterChip(
                        label: Text(ozellik),
                        selected: secili,
                        selectedColor: const Color(0xFFDCFCE7),
                        checkmarkColor: const Color(0xFF15803D),
                        labelStyle: TextStyle(color: secili ? const Color(0xFF15803D) : Colors.black),
                        onSelected: (bool value) {
                          setModalState(() {
                            if (value) {
                              _aktifFiltreler.add(ozellik);
                            } else {
                              _aktifFiltreler.remove(ozellik);
                            }
                          });
                          _filtrele();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Uygula"),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  LatLng _koordinatUret(int index) {
    if (index == 0) return const LatLng(40.8050, 29.4350);
    if (index == 1) return const LatLng(40.7990, 29.4280);
    return const LatLng(40.8010, 29.4400);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      
      // --- YENİ: KONUM BUTONU (SAĞ ALT) ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100), // Kartın altında kalmasın diye yukarı ittik
        child: FloatingActionButton(
          onPressed: _konumaGit,
          backgroundColor: Colors.white,
          child: const Icon(Icons.my_location, color: Color(0xFF22C55E)),
        ),
      ),
      
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _merkezKonum,
              initialZoom: 13.5,
              onTap: (_, __) {
                FocusScope.of(context).unfocus();
                setState(() => _seciliSaha = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.e_halisaha',
              ),
              MarkerLayer(
                markers: List.generate(goruntulenenSahalar.length, (index) {
                  final saha = goruntulenenSahalar[index];
                  final orijinalIndex = tumSahalar.indexOf(saha);
                  final konum = _koordinatUret(orijinalIndex); 
                  final seciliMi = _seciliSaha == saha;

                  return Marker(
                    point: konum,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () => setState(() => _seciliSaha = saha),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: seciliMi ? const Color(0xFF22C55E) : Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                        ),
                        child: Icon(Icons.sports_soccer, color: Colors.white, size: seciliMi ? 35 : 25),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          // Arama Kutusu
          Positioned(
            top: 50, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)]),
              child: TextField(
                controller: _aramaController,
                onChanged: (_) => _filtrele(),
                decoration: InputDecoration(
                  hintText: "Haritada ara...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _aktifFiltreler.isNotEmpty ? const Color(0xFFDCFCE7) : Colors.grey[100], shape: BoxShape.circle),
                      child: Icon(Icons.filter_list, color: _aktifFiltreler.isNotEmpty ? const Color(0xFF15803D) : Colors.black, size: 20),
                    ),
                    onPressed: _filtrePenceresiniAc,
                  ),
                ),
              ),
            ),
          ),

          // Bilgi Kartı
          if (_seciliSaha != null)
            Positioned(
              bottom: 30, left: 20, right: 20,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: _seciliSaha!))),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)]),
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset(_seciliSaha!.resimYolu, width: 80, height: 80, fit: BoxFit.cover)),
                      const SizedBox(width: 15),
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
                      const CircleAvatar(backgroundColor: Color(0xFF22C55E), child: Icon(Icons.arrow_forward, color: Colors.white))
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