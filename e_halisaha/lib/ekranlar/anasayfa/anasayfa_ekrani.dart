import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../modeller/saha_modeli.dart';
import '../harita/harita_ekrani.dart';
import '../profil/profil_ekrani.dart';
import '../rakip_bul/rakip_bul_ekrani.dart';
import '../saha_detay/saha_detay_ekrani.dart';

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
    const RakipBulEkrani(),
    const ProfilEkrani(),
  ];

  @override
  Widget build(BuildContext context) {
    // "koyuMod" değişkeni kullanılmadığı için kaldırıldı.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _sayfalar[_seciliIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _seciliIndex,
        onTap: (index) => setState(() => _seciliIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF22C55E),
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Anasayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Harita"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Rakip Bul"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
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
  final ApiServisi _apiServisi = ApiServisi();
  List<SahaModeli> tumSahalar = [];
  List<SahaModeli> goruntulenenSahalar = [];
  bool _yukleniyor = true;
  
  // DÜZELTME: Controller 'final' yapıldı.
  final TextEditingController _aramaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sahalariGetir();
  }

  void _sahalariGetir() async {
    try {
      var sahalarJson = await _apiServisi.tumSahalariGetir();
      
      // API 'name' döndürüyor ama Model 'pitchName' bekliyorsa eşliyoruz
      List<SahaModeli> geciciListe = sahalarJson.map((e) {
        if (e['pitchName'] == null && e['name'] != null) {
          e['pitchName'] = e['name']; // İsim eşleştirmesi
        }
        return SahaModeli.fromJson(e);
      }).toList();

      if (mounted) {
        setState(() {
          tumSahalar = geciciListe;
          goruntulenenSahalar = geciciListe;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      // DÜZELTME: print yerine debugPrint kullanıldı
      debugPrint("Saha Çekme Hatası: $e");
      if(mounted) setState(() => _yukleniyor = false);
    }
  }

  void _ara(String kelime) {
    setState(() {
      goruntulenenSahalar = tumSahalar.where((saha) => 
        saha.isim.toLowerCase().contains(kelime.toLowerCase()) || 
        saha.ilce.toLowerCase().contains(kelime.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool koyuMod = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Üst Başlık ve Arama
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DÜZELTME: const eklendi
                        const Text("Merhaba, Efe 👋", style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text("Maç Yapacak Saha Bul", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: koyuMod ? Colors.white : Colors.black)),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: Color(0xFF22C55E),
                      child: Icon(Icons.notifications, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                // Arama Çubuğu
                TextField(
                  controller: _aramaController,
                  onChanged: _ara,
                  decoration: InputDecoration(
                    hintText: "Saha adı veya ilçe ara...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: koyuMod ? Colors.grey[800] : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _yukleniyor 
              ? const Center(child: CircularProgressIndicator())
              : goruntulenenSahalar.isEmpty 
                ? const Center(child: Text("Saha bulunamadı."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: goruntulenenSahalar.length,
                    itemBuilder: (context, index) {
                      final saha = goruntulenenSahalar[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha))),
                        child: Card(
                          color: koyuMod ? Colors.grey[900] : Colors.white,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.asset(saha.resimYolu, height: 150, width: double.infinity, fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(saha.isim, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: koyuMod ? Colors.white : Colors.black)),
                                  const SizedBox(height: 5),
                                  Text("📍 ${saha.tamKonum}", style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${saha.fiyat.toStringAsFixed(0)}₺ / Saat", style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 16)),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                                    ],
                                  )
                                ]),
                              ),
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
}