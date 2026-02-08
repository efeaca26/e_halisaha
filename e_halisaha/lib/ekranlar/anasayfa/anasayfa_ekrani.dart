import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart'; // Yeni API Servisi
import '../../modeller/saha_modeli.dart'; // Az önce güncellediğimiz model
import '../harita/harita_ekrani.dart';
import '../profil/profil_ekrani.dart';
import '../rakip_bul/rakip_bul_ekrani.dart';
import '../saha_detay/saha_detay_ekrani.dart';
// import '../admin/kullanici_yonetimi_ekrani.dart'; // Hata verirse yorum satırına al
// import '../../cekirdek/servisler/kimlik_servisi.dart'; // Token yapısı tamamsa aç

class AnasayfaEkrani extends StatefulWidget {
  const AnasayfaEkrani({super.key});

  @override
  State<AnasayfaEkrani> createState() => _AnasayfaEkraniState();
}

class _AnasayfaEkraniState extends State<AnasayfaEkrani> {
  int _seciliIndex = 0;

  final List<Widget> _sayfalar = [
    const AnasayfaIcerik(),
    const HaritaEkrani(), // Bu dosyaların projemde olduğundan emin ol
    const ProfilEkrani(), 
  ];

  @override
  Widget build(BuildContext context) {
    // Şimdilik admin kontrolünü basit tutuyoruz
    bool isAdmin = false; 

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: (_seciliIndex == 0 && isAdmin) 
        ? AppBar(
            title: const Text("Yönetici Paneli", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.people, color: Colors.black),
                tooltip: "Kullanıcıları Yönet",
                onPressed: () {
                   // Navigator.push(context, MaterialPageRoute(builder: (context) => const KullaniciYonetimiEkrani()));
                },
              ),
            ],
          ) 
        : null,
      
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
  final ApiServisi _apiServisi = ApiServisi(); // API Servisini Çağırdık

  List<SahaModeli> _tumSahalar = [];        
  List<SahaModeli> _gosterilenSahalar = []; 
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  // --- ARTIK VERİLER BACKEND'DEN GELİYOR ---
  void _verileriYukle() async {
    // API'den JSON Listesi Gelir: [{pitchName: "Merkez", ...}, {...}]
    List<dynamic> gelenJsonListesi = await _apiServisi.sahalariGetir();

    if (mounted) {
      setState(() {
        // Gelen JSON'u senin tasarımına uygun "SahaModeli"ne çeviriyoruz
        _tumSahalar = gelenJsonListesi.map((json) => SahaModeli.fromJson(json)).toList();
        _gosterilenSahalar = List.from(_tumSahalar);
        _yukleniyor = false;
      });
    }
  }

  // --- ARAMA FONKSİYONU (Aynı Kaldı) ---
  void _aramaYap(String arananKelime) {
    setState(() {
      if (arananKelime.isEmpty) {
        _gosterilenSahalar = List.from(_tumSahalar);
      } else {
        _gosterilenSahalar = _tumSahalar.where((saha) {
          final isim = saha.isim.toLowerCase();
          final ilce = saha.ilce.toLowerCase();
          final aranan = arananKelime.toLowerCase();
          return isim.contains(aranan) || ilce.contains(aranan);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rolleri şimdilik basit tutalım
    bool isYetkili = false; 
    bool isIsletme = false;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        
        // İşletme Ekle Butonu (Sadece yetkiliye)
        floatingActionButton: isIsletme 
          ? FloatingActionButton.extended(
              onPressed: () {}, // _sahaEkleDialog buraya gelecek
              backgroundColor: const Color(0xFF22C55E),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Saha Ekle", style: TextStyle(color: Colors.white)),
            )
          : null,

        body: _yukleniyor 
          ? const Center(child: CircularProgressIndicator()) // Yüklenirken dönen tekerlek
          : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // ÜST BAŞLIK (SENİN TASARIMIN)
                if (!isYetkili)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Merhaba, Kaptan! 👋", style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text("Maç Yapmaya Hazır mısın?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      CircleAvatar(radius: 25, backgroundColor: const Color(0xFF22C55E), child: const Icon(Icons.sports_soccer, color: Colors.white))
                    ],
                  ),

                const SizedBox(height: 20),

                // --- ARAMA KUTUSU ---
                TextField(
                  onChanged: _aramaYap,
                  decoration: InputDecoration(
                    hintText: isYetkili ? "Sahalarınızda arayın..." : "Saha, ilçe veya takım ara...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    filled: true, fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // RAKİP BUL BUTONU (SENİN TASARIMIN)
                if (!isYetkili) ...[
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RakipBulEkrani())),
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
                            child: const Icon(Icons.groups, color: Colors.white, size: 30)
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Rakip mi Arıyorsun?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), 
                              Text("Seviyene uygun takımları bul!", style: TextStyle(color: Colors.white70, fontSize: 12))
                            ])
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const Text("Saha Listesi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // --- LİSTELEME ---
                _gosterilenSahalar.isEmpty 
                  ? Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      child: const Text("Aradığınız kriterde saha yok.", style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _gosterilenSahalar.length,
                      itemBuilder: (context, index) {
                        final saha = _gosterilenSahalar[index];
                        return GestureDetector(
                          // Buraya dikkat: SahaDetayEkrani'na modeli gönderiyoruz
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha))),
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      // Resim internetten gelmediği için assets kullanıyoruz
                                      child: Image.asset(saha.resimYolu, height: 150, width: double.infinity, fit: BoxFit.cover),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(saha.isim, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text("📍 ${saha.tamKonum}", style: const TextStyle(color: Colors.grey)),
                                        const SizedBox(height: 8),
                                        Text("${saha.fiyat.toStringAsFixed(0)}₺ / Saat", style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
      ),
    );
  }
}