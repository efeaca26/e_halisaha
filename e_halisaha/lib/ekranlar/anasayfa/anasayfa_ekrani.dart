import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/ornek_veri.dart';
import '../saha_detay/saha_detay_ekrani.dart';

class AnasayfaEkrani extends StatefulWidget {
  const AnasayfaEkrani({super.key});

  @override
  State<AnasayfaEkrani> createState() => _AnasayfaEkraniState();
}

class _AnasayfaEkraniState extends State<AnasayfaEkrani> {
  int _seciliMenuIndex = 0; // Alt menü seçimi
  List<SahaModeli> tumSahalar = [];

  @override
  void initState() {
    super.initState();
    tumSahalar = SahteVeriServisi.sahalariGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Hafif gri arka plan
      
      // ALT MENÜ (Bottom Navigation Bar)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _seciliMenuIndex,
          onTap: (index) => setState(() => _seciliMenuIndex = index),
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Ana Sayfa"),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Harita"),
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Maçlarım"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ÜST ARAMA VE KONUM BÖLÜMÜ ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.black, // Premium Siyah
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selamlama ve Konum
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tekrar Hoşgeldin 👋", style: TextStyle(color: Colors.grey, fontSize: 14)),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.green, size: 16),
                                SizedBox(width: 5),
                                Text("Kocaeli, Gebze", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
                              ],
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Arama Çubuğu
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Saha adı veya ilçe ara...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15), // Saydam beyaz
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- BÖLÜM 1: POPÜLER SAHALAR (Yatay Liste) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("🔥 Popüler Sahalar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Tümü", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              
              // Yatay Kaydırma Alanı
              SizedBox(
                height: 240, // Kart yüksekliği
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: tumSahalar.length,
                  itemBuilder: (context, index) {
                    final saha = tumSahalar[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha))),
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 15, bottom: 10), // Gölge için bottom margin şart
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Resim
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.asset(saha.resimYolu, width: double.infinity, fit: BoxFit.cover),
                              ),
                            ),
                            // Bilgiler
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(saha.isim, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text(" ${saha.puan}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        Text(" • ${saha.ilce}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                    Text("${saha.fiyat.toStringAsFixed(0)}₺ / Saat", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // --- BÖLÜM 2: YAKINDAKİLER (Dikey Liste) ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("📍 Yakınındakiler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),

              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true, // ScrollView içinde olduğu için şart
                physics: const NeverScrollableScrollPhysics(), // Ana scroll'u kullanması için
                itemCount: tumSahalar.length,
                itemBuilder: (context, index) {
                  final saha = tumSahalar[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(saha.resimYolu, width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(saha.isim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 5),
                                Text(saha.tamKonum, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 5),
                                Row(
                                  children: saha.ozellikler.take(2).map((ozellik) => 
                                    Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                                      child: Text(ozellik, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    )
                                  ).toList(),
                                )
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300])
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}