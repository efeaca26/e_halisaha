import 'dart:async';
import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../modeller/oyuncu_modeli.dart';
import '../anasayfa/anasayfa_ekrani.dart';
import '../../ekranlar/odeme/odeme_ekrani.dart';
import 'oyuncu_secim_ekrani.dart';

class SahaDetayEkrani extends StatefulWidget {
  final SahaModeli saha;
  const SahaDetayEkrani({super.key, required this.saha});

  @override
  State<SahaDetayEkrani> createState() => _SahaDetayEkraniState();
}

class _SahaDetayEkraniState extends State<SahaDetayEkrani> {
  DateTime _seciliTarih = DateTime.now(); 
  int? _seciliSaatIndex;
  Timer? _zamanlayici;
  List<Map<String, dynamic>> _guncelSaatler = [];
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

  double _toplamFiyatiHesapla() {
    double sahaUcreti = widget.saha.fiyat;
    double oyuncuUcretleri = 0;
    for (var oyuncu in _eklenenOyuncular) {
      oyuncuUcretleri += oyuncu.ucret;
    }
    return sahaUcreti + oyuncuUcretleri;
  }

  void _oyuncuSecimEkraniniAc() async {
    final sonuc = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OyuncuSecimEkrani(suankiSecimler: _eklenenOyuncular),
      ),
    );

    if (sonuc != null && sonuc is List<OyuncuModeli>) {
      setState(() {
        _eklenenOyuncular = sonuc;
      });
    }
  }

  void _saatleriYenile() {
    _guncelSaatler = [
      {"saat": "19:00", "durum": "bos"},
      {"saat": "20:00", "durum": "bos"},
      {"saat": "21:00", "durum": "dolu"},
      {"saat": "22:00", "durum": "bos"},
    ];
    setState(() {});
  }

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
    // Tema Kontrolleri
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color arkaplanRengi = Theme.of(context).scaffoldBackgroundColor;
    Color kartRengi = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color yaziRengi = isDark ? Colors.white : Colors.black;
    Color altYaziRengi = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: arkaplanRengi,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200, pinned: true, backgroundColor: const Color(0xFF22C55E),
            flexibleSpace: FlexibleSpaceBar(background: Image.asset(widget.saha.resimYolu, fit: BoxFit.cover)),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), 
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: kartRengi, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30))
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.saha.isim, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: yaziRengi)),
                  Text("📍 ${widget.saha.tamKonum}", style: TextStyle(color: altYaziRengi)),
                  const SizedBox(height: 24),

                  // --- SAAT SEÇİMİ ---
                  Text("Saat Seçimi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: yaziRengi)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: List.generate(_guncelSaatler.length, (index) {
                      bool secili = _seciliSaatIndex == index;
                      bool dolu = _guncelSaatler[index]['durum'] == 'dolu';
                      
                      return ChoiceChip(
                        label: Text(_guncelSaatler[index]['saat']),
                        selected: secili,
                        onSelected: dolu ? null : (val) => setState(() => _seciliSaatIndex = val ? index : null),
                        selectedColor: const Color(0xFF22C55E),
                        backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey[200],
                        labelStyle: TextStyle(
                          color: secili 
                              ? Colors.white 
                              : (dolu ? Colors.grey : yaziRengi)
                        ),
                        // Dolu ise devre dışı bırak
                        disabledColor: isDark ? Colors.black26 : Colors.grey[300],
                      );
                    }),
                  ),

                  const SizedBox(height: 30),
                  Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: 10),

                  // --- KADRO TAMAMLAMA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Eksik Oyuncu Tamamla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: yaziRengi)),
                          Text("Topluluktan oyuncu davet et", style: TextStyle(color: altYaziRengi, fontSize: 12)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _oyuncuSecimEkraniniAc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF334155) : Colors.black,
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
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.grey[50], 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey.shade200)
                      ),
                      child: Center(child: Text("Henüz oyuncu eklenmedi.", style: TextStyle(color: altYaziRengi))),
                    )
                  else
                    Column(
                      children: _eklenenOyuncular.map((oyuncu) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : Colors.white, 
                            borderRadius: BorderRadius.circular(12), 
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300)
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundImage: NetworkImage(oyuncu.resimUrl), radius: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(oyuncu.isim, style: TextStyle(fontWeight: FontWeight.bold, color: yaziRengi)),
                                    Text(oyuncu.mevkii, style: TextStyle(fontSize: 10, color: altYaziRengi)),
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
        decoration: BoxDecoration(
          color: kartRengi, 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Toplam Tutar", style: TextStyle(color: altYaziRengi)),
                Text(
                  "${_toplamFiyatiHesapla().toStringAsFixed(0)}₺",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
                if (_eklenenOyuncular.isNotEmpty)
                  Text("(${_eklenenOyuncular.length} Kiralık Oyuncu)", style: TextStyle(fontSize: 10, color: yaziRengi)),
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