import 'package:flutter/material.dart';
import '../harita/harita_ekrani.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/ornek_veri.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../saha_detay/saha_detay_ekrani.dart';
import '../profil/profil_ekrani.dart';
import '../rakip_bul/rakip_bul_ekrani.dart';
import '../admin/kullanici_yonetimi_ekrani.dart';

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
    // Admin ise üstte yönetim paneli butonu görünsün
    bool isAdmin = KimlikServisi.isAdmin;

    return Scaffold(
      appBar: (_seciliIndex == 0 && isAdmin) 
        ? AppBar(
            title: const Text("Yönetici Paneli", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.people, color: Colors.black),
                tooltip: "Kullanıcıları Yönet",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KullaniciYonetimiEkrani())),
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
  List<SahaModeli> _sahalar = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  // Verileri role göre filtreleyip yükleyen fonksiyon
  void _verileriYukle() {
    setState(() {
      final tumSahalar = SahteVeriServisi.sahalariGetir();
      final aktifKullanici = KimlikServisi.aktifKullanici;

      if (KimlikServisi.isIsletme) {
        // İşletme sadece kendi sahalarını görür
        _sahalar = tumSahalar.where((saha) => saha.isletmeSahibiEmail == aktifKullanici?['email']).toList();
      } else {
        // Admin ve Oyuncu hepsini görür
        _sahalar = tumSahalar;
      }
    });
  }

  // --- DÜZENLEME FONKSİYONU ---
  void _duzenleDialog(SahaModeli saha) {
    TextEditingController isimController = TextEditingController(text: saha.isim);
    TextEditingController fiyatController = TextEditingController(text: saha.fiyat.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sahayı Düzenle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: isimController, decoration: const InputDecoration(labelText: "Saha İsmi")),
            const SizedBox(height: 10),
            TextField(controller: fiyatController, decoration: const InputDecoration(labelText: "Fiyat (TL)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              // Veriyi Güncelle
              SahteVeriServisi.sahaGuncelle(
                saha, 
                isimController.text, 
                double.tryParse(fiyatController.text) ?? saha.fiyat
              );
              
              // EKRANI YENİLE (Çok Önemli)
              _verileriYukle(); 
              
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saha güncellendi! ✅"), backgroundColor: Colors.green));
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  // --- SİLME FONKSİYONU ---
  void _silDialog(SahaModeli saha) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sahayı Sil?"),
        content: Text("${saha.isim} silinecek. Geri alınamaz!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Veriyi Sil
              SahteVeriServisi.sahaSil(saha);
              
              // EKRANI YENİLE
              _verileriYukle();
              
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saha silindi! 🗑️"), backgroundColor: Colors.red));
            },
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- EKLEME FONKSİYONU ---
  void _sahaEkleDialog() {
    TextEditingController adController = TextEditingController();
    TextEditingController fiyatController = TextEditingController();
    TextEditingController ilceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yeni Saha Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: adController, decoration: const InputDecoration(labelText: "Saha Adı")),
            const SizedBox(height: 10),
            TextField(controller: fiyatController, decoration: const InputDecoration(labelText: "Saatlik Fiyat"), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            TextField(controller: ilceController, decoration: const InputDecoration(labelText: "İlçe")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              if (adController.text.isNotEmpty && fiyatController.text.isNotEmpty) {
                double fiyat = double.tryParse(fiyatController.text) ?? 0;
                
                SahaModeli yeniSaha = SahaModeli(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  isim: adController.text,
                  fiyat: fiyat,
                  kapora: fiyat * 0.30,
                  ilce: ilceController.text,
                  tamKonum: "${ilceController.text}, İstanbul",
                  puan: 0.0,
                  resimYolu: "assets/resimler/saha1.png",
                  ozellikler: ["Otopark"],
                  isletmeSahibiEmail: KimlikServisi.aktifKullanici?['email'], 
                );

                SahteVeriServisi.sahaEkle(yeniSaha);
                _verileriYukle(); 
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saha Eklendi! 🎉"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Ekle"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = KimlikServisi.isAdmin;
    bool isIsletme = KimlikServisi.isIsletme;
    bool isYetkili = isAdmin || isIsletme; // Düzenleme yetkisi olanlar

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        
        // Sadece İşletme Sahipleri Ekleme Yapabilir
        floatingActionButton: isIsletme 
          ? FloatingActionButton.extended(
              onPressed: _sahaEkleDialog,
              backgroundColor: const Color(0xFF22C55E),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Saha Ekle", style: TextStyle(color: Colors.white)),
            )
          : null,

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜST BAŞLIK TASARIMI
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF22C55E),
                      child: const Icon(Icons.sports_soccer, color: Colors.white),
                    )
                  ],
                )
              else 
                // Yetkili Başlığı
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isAdmin ? "Sistem Yöneticisi" : "İşletme Paneli", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(isAdmin ? "Tüm Sahalar" : "Saha Yönetimi", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),

              const SizedBox(height: 20),

              // ARAMA VE RAKİP BUL (Sadece Oyuncular İçin)
              if (!isYetkili) ...[
                TextField(
                  // Arama fonksiyonu buraya entegre edilebilir
                  decoration: InputDecoration(
                    hintText: "Saha, ilçe veya takım ara...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    filled: true, fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
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

              // SAHA LİSTESİ
              _sahalar.isEmpty 
                ? Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: const Text("Görüntülenecek saha yok.", style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sahalar.length,
                    itemBuilder: (context, index) {
                      final saha = _sahalar[index];
                      return GestureDetector(
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
                            
                            // YETKİLİ BUTONLARI (Düzenle ve Sil)
                            if (isYetkili) 
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Row(
                                  children: [
                                    // DÜZENLE BUTONU
                                    GestureDetector(
                                      onTap: () => _duzenleDialog(saha),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // SİL BUTONU
                                    GestureDetector(
                                      onTap: () => _silDialog(saha),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.delete, color: Colors.white, size: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}