import 'dart:async'; // Zamanlayıcı için gerekli
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
  
  // --- SAAT YÖNETİMİ ---
  // Hangi saat seçildi?
  int? _seciliSaatIndex;
  
  // 5 Dakikalık (300 saniye) Sayaç
  Timer? _zamanlayici;
  int _kalanSure = 300; 

  // SAHTE SAAT VERİLERİ (17:00 - 23:00 arası)
  // Durumlar: "bos" (Yeşil), "dolu" (Kırmızı), "beklemede" (Sarı - Başkası bakıyor)
  final List<Map<String, dynamic>> _saatler = [
    {"saat": "17:00", "durum": "dolu"},      // Kırmızı
    {"saat": "18:00", "durum": "bos"},       // Yeşil
    {"saat": "19:00", "durum": "beklemede"}, // Sarı (Başkası bakıyor)
    {"saat": "20:00", "durum": "bos"},       // Yeşil
    {"saat": "21:00", "durum": "bos"},       // Yeşil
    {"saat": "22:00", "durum": "dolu"},      // Kırmızı
    {"saat": "23:00", "durum": "bos"},       // Yeşil
  ];

  @override
  void dispose() {
    _zamanlayici?.cancel(); // Sayfadan çıkarsa sayacı durdur
    super.dispose();
  }

  // --- SAYAÇ FONKSİYONLARI ---
  void _sayaciBaslat() {
    // Varsa eski sayacı durdur ve süreyi sıfırla
    _zamanlayici?.cancel();
    setState(() => _kalanSure = 300); // 300 saniye = 5 dakika

    _zamanlayici = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_kalanSure > 0) {
          _kalanSure--;
        } else {
          // SÜRE BİTTİ!
          timer.cancel();
          _sureDolduIslemi();
        }
      });
    });
  }

  void _sureDolduIslemi() {
    // Kullanıcıya uyarı ver ve ana sayfaya at
    showDialog(
      context: context,
      barrierDismissible: false, // Boşluğa tıklayıp kapatamasın
      builder: (context) => AlertDialog(
        title: const Text("Süre Doldu! ⏳"),
        content: const Text("Seçtiğiniz saat için işlem süreniz (5 dakika) doldu. Ana sayfaya yönlendiriliyorsunuz."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AnasayfaEkrani()),
                (route) => false,
              );
            },
            child: const Text("Tamam"),
          )
        ],
      ),
    );
  }

  // Saniyeyi Dakika:Saniye formatına çevirir (Örn: 04:59)
  String _sureyiFormatla(int saniye) {
    int dakika = saniye ~/ 60;
    int kSaniye = saniye % 60;
    return "${dakika.toString().padLeft(2, '0')}:${kSaniye.toString().padLeft(2, '0')}";
  }

  void _rezervasyonYap() async {
    if (_seciliSaatIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen boş bir saat seçiniz!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _yukleniyor = true);
    _zamanlayici?.cancel(); // Rezervasyon yapılırken sayacı durdur

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Saat ${_saatler[_seciliSaatIndex!]['saat']} için rezervasyon alındı! 🎉"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AnasayfaEkrani()),
      (route) => false,
    );
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

          // --- İÇERİK ---
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
                  
                  // --- SAAT SEÇİM GRID'İ ---
                  const Text("Saat Seçimi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (_seciliSaatIndex != null)
                    Text("Kalan Süre: ${_sureyiFormatla(_kalanSure)}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true, // ScrollView içinde olduğu için şart
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Yan yana 4 kutu
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _saatler.length,
                    itemBuilder: (context, index) {
                      final saatVerisi = _saatler[index];
                      String durum = saatVerisi['durum'];
                      bool secili = _seciliSaatIndex == index;

                      // Renk Mantığı
                      Color kutuRengi;
                      Color yaziRengi = Colors.white;

                      if (secili) {
                        kutuRengi = const Color(0xFF22C55E); // Seçtiğim (Koyu Yeşil)
                      } else if (durum == "dolu") {
                        kutuRengi = Colors.red.shade400; // Dolu
                      } else if (durum == "beklemede") {
                        kutuRengi = Colors.amber; // Başkası inceliyor
                        yaziRengi = Colors.black;
                      } else {
                        kutuRengi = Colors.green.shade100; // Boş (Açık Yeşil)
                        yaziRengi = Colors.green.shade900;
                      }

                      return GestureDetector(
                        onTap: () {
                          // Sadece "bos" olanlar veya zaten "kendi seçtiğim" tıklanabilir
                          if (durum == "bos" || secili) {
                            setState(() {
                              if (secili) {
                                // Seçimi kaldır
                                _seciliSaatIndex = null;
                                _zamanlayici?.cancel(); // Sayacı durdur
                              } else {
                                // Yeni seçim yap
                                _seciliSaatIndex = index;
                                _sayaciBaslat(); // Sayacı başlat (5 dk)
                              }
                            });
                          } else if (durum == "dolu") {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu saat dolu!"), duration: Duration(milliseconds: 500)));
                          } else if (durum == "beklemede") {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu saati şu an başkası inceliyor."), duration: Duration(milliseconds: 500)));
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
                  
                  // Renk Açıklamaları (Legend)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _renkAciklama(Colors.green.shade100, "Boş"),
                      _renkAciklama(Colors.amber, "İnceleniyor"),
                      _renkAciklama(Colors.red.shade400, "Dolu"),
                    ],
                  ),
                  
                  const SizedBox(height: 80), // Alttaki buton için boşluk
                ],
              ),
            ),
          ),
        ],
      ),

      // --- REZERVASYON BUTONU ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
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
                    backgroundColor: _seciliSaatIndex != null ? const Color(0xFF22C55E) : Colors.grey, // Seçim yoksa gri
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