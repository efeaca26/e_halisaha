import 'package:flutter/material.dart';
import '../harita/harita_ekrani.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/ornek_veri.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart'; // Admin kontrolü için
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
  List<SahaModeli> _sahalar = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    setState(() {
      _sahalar = SahteVeriServisi.sahalariGetir();
    });
  }

  // --- ADMİN: DÜZENLEME PENCERESİ ---
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
              // Güncelleme İşlemi
              SahteVeriServisi.sahaGuncelle(
                saha, 
                isimController.text, 
                double.tryParse(fiyatController.text) ?? saha.fiyat
              );
              _verileriYukle(); // Ekranı yenile
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saha güncellendi! ✅"), backgroundColor: Colors.green));
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  // --- ADMİN: SİLME İŞLEMİ ---
  void _silDialog(SahaModeli saha) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sahayı Sil?"),
        content: Text("${saha.isim} silinecek. Emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              SahteVeriServisi.sahaSil(saha);
              _verileriYukle(); // Ekranı yenile
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saha silindi! 🗑️"), backgroundColor: Colors.red));
            },
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = KimlikServisi.isAdmin; // Admin mi kontrolü

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST BAŞLIK
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isAdmin ? "Yönetici Paneli 🛠️" : "Merhaba, Kaptan! 👋", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(isAdmin ? "Sahaları Yönet" : "Maç Yapmaya Hazır mısın?", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isAdmin ? Colors.redAccent : const Color(0xFF22C55E),
                  child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.sports_soccer, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Arama ve Rakip Bul (Sadece normal kullanıcıda veya her ikisinde kalsın)
            if (!isAdmin) ...[
              TextField(
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
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.groups, color: Colors.white, size: 30)),
                      const SizedBox(width: 15),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Rakip mi Arıyorsun?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text("Seviyene uygun takımları bul!", style: TextStyle(color: Colors.white70, fontSize: 12))])),
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
              ? const Center(child: Text("Kayıtlı saha bulunamadı."))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sahalar.length,
                  itemBuilder: (context, index) {
                    final saha = _sahalar[index];
                    return GestureDetector(
                      onTap: () {
                        // Admin ise detaya gitmesin, direkt düzenlesin mi? 
                        // Hayır, admin de detayı görsün ama düzenleme butonları kartın üstünde olsun.
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha)));
                      },
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(saha.isim, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.star, size: 14, color: Color(0xFF15803D)), const SizedBox(width: 4), Text("${saha.puan}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)))])),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text("📍 ${saha.tamKonum}", style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 8),
                                      Text("${saha.fiyat.toStringAsFixed(0)}₺ / Saat", style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // --- ADMIN BUTONLARI ---
                          if (isAdmin) 
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Row(
                                children: [
                                  // Düzenle Butonu
                                  GestureDetector(
                                    onTap: () => _duzenleDialog(saha),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Sil Butonu
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
    );
  }
}