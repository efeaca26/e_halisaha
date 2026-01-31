import 'package:flutter/material.dart';
import '../../modeller/takim_modeli.dart';

class RakipBulEkrani extends StatefulWidget {
  const RakipBulEkrani({super.key});

  @override
  State<RakipBulEkrani> createState() => _RakipBulEkraniState();
}

class _RakipBulEkraniState extends State<RakipBulEkrani> {
  // SAHTE RAKİP LİSTESİ
  final List<TakimModeli> _rakipler = [
    TakimModeli(isim: "Gebze Gücü", kaptan: "Ahmet K.", seviye: 4.5, logoUrl: "https://ui-avatars.com/api/?name=G+G&background=red&color=fff", oyuncuSayisi: 7),
    TakimModeli(isim: "Yıldızlar FC", kaptan: "Mehmet Y.", seviye: 3.8, logoUrl: "https://ui-avatars.com/api/?name=Y+F&background=0D8ABC&color=fff", oyuncuSayisi: 7),
    TakimModeli(isim: "Demir Kramponlar", kaptan: "Ali V.", seviye: 5.0, logoUrl: "https://ui-avatars.com/api/?name=D+K&background=333&color=fff", oyuncuSayisi: 11),
    TakimModeli(isim: "Genç Yetenekler", kaptan: "Sinan O.", seviye: 2.5, logoUrl: "https://ui-avatars.com/api/?name=G+Y&background=orange&color=fff", oyuncuSayisi: 7),
    TakimModeli(isim: "Mahallenin Abileri", kaptan: "Kemal T.", seviye: 4.2, logoUrl: "https://ui-avatars.com/api/?name=M+A&background=purple&color=fff", oyuncuSayisi: 11),
  ];

  void _davetGonder(String takimAdi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$takimAdi takımına maç teklifi gönderildi! ⚔️"),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Rakip Bul", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- FİLTRE KISMI ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Takım ara...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.filter_list, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // --- LİSTE ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rakipler.length,
              itemBuilder: (context, index) {
                final takim = _rakipler[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // LOGO
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(takim.logoUrl),
                        ),
                        const SizedBox(width: 16),
                        // BİLGİLER
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(takim.isim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("Kaptan: ${takim.kaptan}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  // Seviye Yıldızı
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, size: 12, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text("${takim.seviye}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Oyuncu Sayısı
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                    child: Text("${takim.oyuncuSayisi} vs ${takim.oyuncuSayisi}", style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        // DAVET BUTONU
                        ElevatedButton(
                          onPressed: () => _davetGonder(takim.isim),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                          ),
                          child: const Text("Davet Et", style: TextStyle(color: Colors.white, fontSize: 12)),
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
}