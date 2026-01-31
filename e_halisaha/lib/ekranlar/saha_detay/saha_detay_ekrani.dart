import 'dart:async';
import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../anasayfa/anasayfa_ekrani.dart';

class SahaDetayEkrani extends StatefulWidget {
  final SahaModeli saha;

  const SahaDetayEkrani({super.key, required this.saha});

  @override
  State<SahaDetayEkrani> createState() => _SahaDetayEkraniState();
}

class _SahaDetayEkraniState extends State<SahaDetayEkrani> {
  bool _yukleniyor = false;
  
  // --- TARİH VE SAAT YÖNETİMİ ---
  DateTime _seciliTarih = DateTime.now(); // Başlangıçta bugün seçili
  int? _seciliSaatIndex;
  
  Timer? _zamanlayici;
  int _kalanSure = 300; 

  // Abonelik Simülasyonu: 
  // Çarşamba günleri 22:00-23:00 arası "Abone" olduğu için hep dolu olsun.
  // Cumartesi günleri 19:00-20:00 arası "Abone".
  
  // Dinamik Saat Listesi (Seçilen güne göre değişir)
  List<Map<String, dynamic>> _guncelSaatler = [];

  @override
  void initState() {
    super.initState();
    _saatleriYenile(); // Sayfa açılınca bugünün saatlerini yükle
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  // --- MANTIK: GÜNE GÖRE SAATLERİ OLUŞTUR ---
  void _saatleriYenile() {
    // Önce seçimi sıfırla
    _seciliSaatIndex = null;
    _zamanlayici?.cancel();
    
    // Sabit saat listesi şablonu
    List<String> saatAraliklari = [
      "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"
    ];

    List<Map<String, dynamic>> yeniListe = [];

    // Hangi gün seçili? (1: Pzt, ... 7: Paz)
    int gun = _seciliTarih.weekday; 

    for (var saat in saatAraliklari) {
      String durum = "bos"; // Varsayılan boş

      // 1. ABONE KONTROLÜ (Senaryo Gereği)
      if (gun == 3 && saat == "22:00") { 
        durum = "dolu"; // Çarşamba 22:00 Abone var
      } 
      else if (gun == 6 && saat == "19:00") {
        durum = "dolu"; // Cumartesi 19:00 Abone var
      }
      // 2. RASTGELE DOLULUK (Gerçekçilik için)
      else if ((gun + saat.length) % 5 == 0) {
        durum = "dolu";
      }
      else if ((gun + saat.length) % 7 == 0) {
        durum = "beklemede"; // Sarı renk
      }

      yeniListe.add({"saat": saat, "durum": durum});
    }

    setState(() {
      _guncelSaatler = yeniListe;
    });
  }

  // --- SAYAÇ FONKSİYONLARI ---
  void _sayaciBaslat() {
    _zamanlayici?.cancel();
    setState(() => _kalanSure = 300); // 5 dakika

    _zamanlayici = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_kalanSure > 0) {
          _kalanSure--;
        } else {
          timer.cancel();
          _sureDolduIslemi();
        }
      });
    });
  }

  void _sureDolduIslemi() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Süre Doldu! ⏳"),
        content: const Text("İşlem süreniz doldu. Ana sayfaya yönlendiriliyorsunuz."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()), (route) => false);
            },
            child: const Text("Tamam"),
          )
        ],
      ),
    );
  }

  String _sureyiFormatla(int saniye) {
    int dakika = saniye ~/ 60;
    int kSaniye = saniye % 60;
    return "${dakika.toString().padLeft(2, '0')}:${kSaniye.toString().padLeft(2, '0')}";
  }

  void _rezervasyonYap() async {
    setState(() => _yukleniyor = true);
    _zamanlayici?.cancel();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_guncelSaatler[_seciliSaatIndex!]['saat']} için rezervasyon tamam! 🎉"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()), (route) => false);
  }

  // Tarihi Türkçe Gün Adına Çevir
  String _gunAdiGetir(DateTime tarih) {
    List<String> gunler = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
    return gunler[tarih.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: CustomScrollView(
        slivers: [
          // --- ÜST RESİM ---
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF22C55E),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(widget.saha.resimYolu, fit: BoxFit.cover),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.saha.isim, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("📍 ${widget.saha.tamKonum}", style: const TextStyle(color: Colors.grey)),
                  
                  const SizedBox(height: 24),

                  // --- TARİH SEÇİMİ (HAFTALIK TAKVİM) ---
                  const Text("Tarih Seçiniz", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7, // Bir haftalık takvim
                      itemBuilder: (context, index) {
                        DateTime tarih = DateTime.now().add(Duration(days: index));
                        bool secili = _seciliTarih.day == tarih.day;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _seciliTarih = tarih;
                              _saatleriYenile(); // Günü değiştirince saatleri güncelle
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: secili ? const Color(0xFF22C55E) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: secili ? Colors.transparent : Colors.grey.shade300),
                              boxShadow: secili ? [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _gunAdiGetir(tarih), 
                                  style: TextStyle(color: secili ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${tarih.day}", 
                                  style: TextStyle(color: secili ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // --- SAATLER GRID ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Müsait Saatler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_seciliSaatIndex != null)
                        Text("Süre: ${_sureyiFormatla(_kalanSure)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _guncelSaatler.length,
                    itemBuilder: (context, index) {
                      final saatVerisi = _guncelSaatler[index];
                      String durum = saatVerisi['durum'];
                      bool secili = _seciliSaatIndex == index;

                      Color kutuRengi;
                      Color yaziRengi = Colors.white;

                      if (secili) {
                        kutuRengi = const Color(0xFF22C55E);
                      } else if (durum == "dolu") {
                        kutuRengi = Colors.red.shade400;
                      } else if (durum == "beklemede") {
                        kutuRengi = Colors.amber;
                        yaziRengi = Colors.black;
                      } else {
                        kutuRengi = Colors.green.shade100;
                        yaziRengi = Colors.green.shade900;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (durum == "bos" || secili) {
                            setState(() {
                              if (secili) {
                                _seciliSaatIndex = null;
                                _zamanlayici?.cancel();
                              } else {
                                _seciliSaatIndex = index;
                                _sayaciBaslat();
                              }
                            });
                          } else if (durum == "dolu") {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu saat dolu! (Abone veya Rezervasyon)"), duration: Duration(milliseconds: 500)));
                          } else if (durum == "beklemede") {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu saat şu an inceleniyor."), duration: Duration(milliseconds: 500)));
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: kutuRengi,
                            borderRadius: BorderRadius.circular(8),
                            border: secili ? Border.all(color: Colors.black, width: 2) : null,
                          ),
                          child: Text(
                            saatVerisi['saat'],
                            style: TextStyle(color: yaziRengi, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _renkAciklama(Colors.green.shade100, "Boş"),
                      _renkAciklama(Colors.amber, "İnceleniyor"),
                      _renkAciklama(Colors.red.shade400, "Dolu/Abone"),
                    ],
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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Toplam Ücret", style: TextStyle(color: Colors.grey)),
                Text(
                  "${widget.saha.fiyat.toStringAsFixed(0)}₺",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
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
                  onPressed: (_yukleniyor || _seciliSaatIndex == null) ? null : _rezervasyonYap,
                  child: _yukleniyor 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Ödeme Yap", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renkAciklama(Color renk, String metin) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: renk, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(metin, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}