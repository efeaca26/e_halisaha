import 'dart:async';
import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../modeller/oyuncu_modeli.dart'; // <--- YENİ MODEL
import '../../ekranlar/odeme/odeme_ekrani.dart';
import 'oyuncu_secim_ekrani.dart'; // <--- SEÇİM EKRANI

class SahaDetayEkrani extends StatefulWidget {
  final SahaModeli saha;
  const SahaDetayEkrani({super.key, required this.saha});

  @override
  State<SahaDetayEkrani> createState() => _SahaDetayEkraniState();
}

class _SahaDetayEkraniState extends State<SahaDetayEkrani> {
  bool _yukleniyor = false;
  DateTime _seciliTarih = DateTime.now(); 
  int? _seciliSaatIndex;
  Timer? _zamanlayici;
  int _kalanSure = 300; 
  List<Map<String, dynamic>> _guncelSaatler = [];

  // --- YENİ: SEÇİLEN OYUNCULAR ---
  List<OyuncuModeli> _eklenenOyuncular = [];

  @override
  void initState() {
    super.initState();
    _saatleriYenile(); 
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  // --- FİYAT HESAPLAMA ---
  double _toplamFiyatiHesapla() {
    double sahaUcreti = widget.saha.fiyat;
    double oyuncuUcretleri = 0;

    // Eklenen her oyuncunun kendi ücretini topla
    for (var oyuncu in _eklenenOyuncular) {
      oyuncuUcretleri += oyuncu.ucret;
    }

    return sahaUcreti + oyuncuUcretleri;
  }

  // --- OYUNCU SEÇİM EKRANINI AÇ ---
  void _oyuncuSecimEkraniniAc() async {
    // Seçim ekranına git ve dönen sonucu bekle (await)
    final sonuc = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OyuncuSecimEkrani(suankiSecimler: _eklenenOyuncular),
      ),
    );

    // Eğer geri dönüldüğünde bir liste geldiyse güncelle
    if (sonuc != null && sonuc is List<OyuncuModeli>) {
      setState(() {
        _eklenenOyuncular = sonuc;
      });
    }
  }

  // ... (Saat Yenileme vb. standart kodlar) ...
  void _saatleriYenile() {
    _guncelSaatler = [
      {"saat": "19:00", "durum": "bos"},
      {"saat": "20:00", "durum": "bos"},
      {"saat": "21:00", "durum": "dolu"},
      {"saat": "22:00", "durum": "bos"},
    ];
    setState(() {});
  }
  
  void _sayaciBaslat() { /* Timer logic here */ }

  void _odemeEkraninaGit() {
    if (_seciliSaatIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir saat seçiniz!"), backgroundColor: Colors.red));
      return;
    }

    String secilenSaat = _guncelSaatler[_seciliSaatIndex!]['saat'];
    double sonFiyat = _toplamFiyatiHesapla(); 

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OdemeEkrani(
          saha: widget.saha,
          tarih: _seciliTarih,
          saat: secilenSaat,
          sonTutar: sonFiyat, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200, pinned: true, backgroundColor: const Color(0xFF22C55E),
            flexibleSpace: FlexibleSpaceBar(background: Image.asset(widget.saha.resimYolu, fit: BoxFit.cover)),
            leading: Container(
            margin: const EdgeInsets.all(8),
            // Geri Tuşu Arkaplanı
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Yarı saydam siyah (Her resimde görünür)
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white), // İkon beyaz
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.saha.isim, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("📍 ${widget.saha.tamKonum}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),

                  // --- SAAT SEÇİMİ (Basitleştirilmiş) ---
                  const Text("Saat Seçimi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: List.generate(_guncelSaatler.length, (index) {
                      bool secili = _seciliSaatIndex == index;
                      return ChoiceChip(
                        label: Text(_guncelSaatler[index]['saat']),
                        selected: secili,
                        onSelected: (val) => setState(() => _seciliSaatIndex = val ? index : null),
                        selectedColor: const Color(0xFF22C55E),
                        labelStyle: TextStyle(color: secili ? Colors.white : Colors.black),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // --- KADRO TAMAMLAMA (TOPLULUK) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Eksik Oyuncu Tamamla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Topluluktan oyuncu davet et", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      // EKLEME BUTONU
                      ElevatedButton.icon(
                        onPressed: _oyuncuSecimEkraniniAc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                        ),
                        icon: const Icon(Icons.group_add, color: Colors.white, size: 18),
                        label: const Text("Oyuncu Bul", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 15),

                  // --- SEÇİLEN OYUNCULAR LİSTESİ ---
                  if (_eklenenOyuncular.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: const Center(child: Text("Henüz oyuncu eklenmedi.", style: TextStyle(color: Colors.grey))),
                    )
                  else
                    Column(
                      children: _eklenenOyuncular.map((oyuncu) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundImage: NetworkImage(oyuncu.resimUrl), radius: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(oyuncu.isim, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(oyuncu.mevkii, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text("+${oyuncu.ucret.toStringAsFixed(0)}₺", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _eklenenOyuncular.remove(oyuncu);
                                  });
                                },
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // --- ALT BAR ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Toplam Tutar", style: TextStyle(color: Colors.grey)),
                Text(
                  "${_toplamFiyatiHesapla().toStringAsFixed(0)}₺",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
                if (_eklenenOyuncular.isNotEmpty)
                  Text("(${_eklenenOyuncular.length} Kiralık Oyuncu)", style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _seciliSaatIndex != null ? const Color(0xFF22C55E) : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _seciliSaatIndex != null ? _odemeEkraninaGit : null,
                  child: const Text("Devam Et", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}