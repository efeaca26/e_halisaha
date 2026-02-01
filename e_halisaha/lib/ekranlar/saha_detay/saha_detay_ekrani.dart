import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../modeller/oyuncu_modeli.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../../cekirdek/servisler/rezervasyon_servisi.dart';
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
  
  final List<String> _saatListesi = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00"];
  List<OyuncuModeli> _eklenenOyuncular = [];

  bool get yetkiliMi {
    if (KimlikServisi.isAdmin) return true;
    if (KimlikServisi.isIsletme && widget.saha.isletmeSahibiEmail == KimlikServisi.aktifKullanici?['email']) {
      return true;
    }
    return false;
  }

  void _manuelEkleDialog(String saat) {
    TextEditingController notController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$saat Rezervasyonu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bu saati manuel olarak kapatıyorsunuz."),
            const SizedBox(height: 15),
            TextField(
              controller: notController,
              decoration: const InputDecoration(
                labelText: "Müşteri Adı / Not (Opsiyonel)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              String not = notController.text.isEmpty ? "Manuel Kayıt" : notController.text;
              RezervasyonServisi.rezervasyonYap(widget.saha.id, _seciliTarih, saat, not);
              setState(() {});
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saha Başarıyla Rezerve Edildi! ✅"), backgroundColor: Colors.green));
            },
            child: const Text("Rezervle"),
          )
        ],
      ),
    );
  }

  void _iptalEtDialog(String saat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$saat İptal Edilsin mi?"),
        content: const Text("Bu rezervasyon silinecek ve saat tekrar boşa çıkacak."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              RezervasyonServisi.rezervasyonIptal(widget.saha.id, _seciliTarih, saat);
              setState(() {
                _seciliSaatIndex = null;
              }); 
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rezervasyon silindi!"), backgroundColor: Colors.red));
            },
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
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
      MaterialPageRoute(builder: (context) => OyuncuSecimEkrani(suankiSecimler: _eklenenOyuncular)),
    );
    if (sonuc != null && sonuc is List<OyuncuModeli>) {
      setState(() => _eklenenOyuncular = sonuc);
    }
  }

  void _odemeEkraninaGit() {
    if (_seciliSaatIndex == null) return;
    String secilenSaat = _saatListesi[_seciliSaatIndex!];
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OdemeEkrani(
          saha: widget.saha,
          tarih: _seciliTarih,
          saat: secilenSaat,
          sonTutar: _toplamFiyatiHesapla(), 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color kartRengi = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color yaziRengi = isDark ? Colors.white : Colors.black;
    Color altYaziRengi = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200, pinned: true, backgroundColor: const Color(0xFF22C55E),
            flexibleSpace: FlexibleSpaceBar(background: Image.asset(widget.saha.resimYolu, fit: BoxFit.cover)),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(color: kartRengi, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.saha.isim, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: yaziRengi)),
                  Text("📍 ${widget.saha.tamKonum}", style: TextStyle(color: altYaziRengi)),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Saat Seçimi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: yaziRengi)),
                      if (yetkiliMi) 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                          child: const Text("Yönetici Modu", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_saatListesi.length, (index) {
                      String saat = _saatListesi[index];
                      String durum = RezervasyonServisi.saatDurumuGetir(widget.saha.id, _seciliTarih, saat);
                      bool dolu = durum != "bos";
                      bool secili = _seciliSaatIndex == index;

                      return GestureDetector(
                        onTap: () {
                          if (yetkiliMi) {
                            if (dolu) {
                              _iptalEtDialog(saat);
                            } else {
                              _manuelEkleDialog(saat);
                            }
                          } else {
                            if (!dolu) {
                              setState(() => _seciliSaatIndex = index);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: dolu 
                                ? (yetkiliMi ? Colors.red.withOpacity(0.1) : Colors.grey[300]) 
                                : (secili ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF334155) : Colors.grey[100])),
                            
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dolu 
                                  ? (yetkiliMi ? Colors.red : Colors.transparent) 
                                  : (secili ? const Color(0xFF22C55E) : Colors.transparent),
                              width: 2
                            ),
                          ),
                          child: Text(
                            saat,
                            style: TextStyle(
                              color: dolu 
                                  ? (yetkiliMi ? Colors.red : Colors.grey) 
                                  : (secili ? Colors.white : yaziRengi),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),
                  Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  
                  const SizedBox(height: 10),
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
                        style: ElevatedButton.styleFrom(backgroundColor: isDark ? const Color(0xFF334155) : Colors.black, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                        icon: const Icon(Icons.group_add, color: Colors.white, size: 18),
                        label: const Text("Oyuncu Bul", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  if (_eklenenOyuncular.isNotEmpty)
                    Column(
                      children: _eklenenOyuncular.map((oyuncu) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundImage: NetworkImage(oyuncu.resimUrl), radius: 20),
                              const SizedBox(width: 10),
                              Expanded(child: Text(oyuncu.isim, style: TextStyle(fontWeight: FontWeight.bold, color: yaziRengi))),
                              Text("+${oyuncu.ucret.toStringAsFixed(0)}₺", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
                              IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => setState(() => _eklenenOyuncular.remove(oyuncu)))
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

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: kartRengi, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Toplam Tutar", style: TextStyle(color: altYaziRengi)),
                Text("${_toplamFiyatiHesapla().toStringAsFixed(0)}₺", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
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