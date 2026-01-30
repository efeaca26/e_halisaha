import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/ornek_veri.dart';
import '../saha_detay/saha_detay_ekrani.dart';
import '../harita/harita_ekrani.dart';
import '../profil/profil_ekrani.dart';

class AnasayfaEkrani extends StatefulWidget {
  const AnasayfaEkrani({super.key});

  @override
  State<AnasayfaEkrani> createState() => _AnasayfaEkraniState();
}

class _AnasayfaEkraniState extends State<AnasayfaEkrani> {
  // --- STATE (DURUM) DEĞİŞKENLERİ ---
  int _seciliMenuIndex = 0; // Hangi sayfa açık? (0: Ana Sayfa, 1: Harita...)
  
  // Veri Yönetimi
  List<SahaModeli> _tumSahalar = []; // Orijinal tam liste
  List<SahaModeli> _goruntulenenSahalar = []; // Ekranda süzülüp gösterilen liste
  
  // Arama ve Filtre Durumları
  String _aramaMetni = "";
  String _seciliFiltre = "Tümü"; // "Kapalı Saha", "Otopark" vb.

  @override
  void initState() {
    super.initState();
    // Başlangıçta tüm verileri çek ve ekrana bas
    _tumSahalar = SahteVeriServisi.sahalariGetir();
    _goruntulenenSahalar = _tumSahalar;
  }

  // --- MANTIK: FİLTRELEME FONKSİYONU ---
  // Hem arama metnine hem de seçili filtreye göre listeyi süzer
  void _listeyiGuncelle() {
    setState(() {
      _goruntulenenSahalar = _tumSahalar.where((saha) {
        // 1. Kural: Arama metni ismin içinde geçiyor mu?
        bool aramaUyumu = saha.isim.toLowerCase().contains(_aramaMetni.toLowerCase()) || 
                          saha.ilce.toLowerCase().contains(_aramaMetni.toLowerCase());
        
        // 2. Kural: Filtre seçili mi? Seçiliyse sahanın özelliklerinde var mı?
        bool filtreUyumu = _seciliFiltre == "Tümü" || saha.ozellikler.contains(_seciliFiltre);

        return aramaUyumu && filtreUyumu; // İkisine de uyuyorsa göster
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- SAYFA YÖNETİMİ ---
    // Alt menüye basınca hangi widget'ın gösterileceğini seçiyoruz
    final List<Widget> sayfalar = [
      _anaSayfaIcerigi(),
      const HaritaEkrani(),
      _bosSayfa("Maçlarım"),
      const ProfilEkrani(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), 
      body: sayfalar[_seciliMenuIndex], // Seçili sayfayı göster
      
      // ALT MENÜ (FOOTER)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _seciliMenuIndex,
          onTap: (index) {
            setState(() {
              _seciliMenuIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF22C55E),
          unselectedItemColor: const Color(0xFF9CA3AF),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Harita"),
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Maçlarım"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
          ],
        ),
      ),
    );
  }

  // --- ANA SAYFA İÇERİĞİ (ESKİ BODY KISMI) ---
  Widget _anaSayfaIcerigi() {
    return Container(
       decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF4), Color(0xFFEFF6FF)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HERO SECTION (ARAMA VE BAŞLIK) ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Başlık
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hoşgeldin,", style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
                          Text("Efe A.", style: TextStyle(color: Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.notifications_outlined, color: Color(0xFF22C55E))
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // ARAMA ÇUBUĞU (AKTİF)
                  TextField(
                    onChanged: (deger) {
                      _aramaMetni = deger; // Yazılanı kaydet
                      _listeyiGuncelle();  // Listeyi yenile
                    },
                    decoration: InputDecoration(
                      hintText: "Saha adı veya ilçe ara...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // FİLTRELER (AKTİF)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filtreButonu("Tümü"),
                        _filtreButonu("Kapalı Saha"),
                        _filtreButonu("Duş"), // Örnek veri ile eşleşmesi için "Duş" yaptım
                        _filtreButonu("Otopark"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- LİSTELEME ---
            Expanded(
              child: _goruntulenenSahalar.isEmpty 
              ? const Center(child: Text("Aradığınız kriterde saha bulunamadı.")) 
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _goruntulenenSahalar.length,
                  itemBuilder: (context, index) {
                    final saha = _goruntulenenSahalar[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Resim
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.asset(saha.resimYolu, height: 160, width: double.infinity, fit: BoxFit.cover),
                            ),
                            // Bilgiler
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(saha.isim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                                        child: Text("${saha.puan}", style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text("📍 ${saha.ilce} • ${saha.tamKonum}", style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${saha.fiyat.toStringAsFixed(0)}₺ / Saat", style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 16)),
                                      const Text("İncele >", style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  // Aktif Filtre Butonu
  Widget _filtreButonu(String yazi) {
    bool aktif = _seciliFiltre == yazi;
    return GestureDetector(
      onTap: () {
        _seciliFiltre = yazi; // Seçimi güncelle
        _listeyiGuncelle();   // Listeyi tekrar süz
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: aktif ? const Color(0xFF22C55E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: aktif ? Colors.transparent : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          yazi, 
          style: TextStyle(
            color: aktif ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }

  // Geçici Boş Sayfa (Harita vb. için)
  Widget _bosSayfa(String baslik) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text("$baslik Sayfası", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Çok yakında burada olacak!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}