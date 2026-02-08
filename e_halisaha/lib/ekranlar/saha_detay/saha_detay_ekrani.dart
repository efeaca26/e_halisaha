import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../modeller/oyuncu_modeli.dart';
import '../../cekirdek/servisler/api_servisi.dart'; // YENİ SERVİS
// import '../../cekirdek/servisler/kimlik_servisi.dart'; // Gerekirse aç
import '../../ekranlar/odeme/odeme_ekrani.dart';
import 'oyuncu_secim_ekrani.dart';

class SahaDetayEkrani extends StatefulWidget {
  final SahaModeli saha;
  const SahaDetayEkrani({super.key, required this.saha});

  @override
  State<SahaDetayEkrani> createState() => _SahaDetayEkraniState();
}

class _SahaDetayEkraniState extends State<SahaDetayEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  
  DateTime _seciliTarih = DateTime.now();
  int? _seciliSaatIndex;
  List<int> _doluSaatler = []; // API'den gelen dolu saatler (Örn: [19, 20])
  bool _yukleniyor = true;

  final List<String> _saatListesi = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00"];
  List<OyuncuModeli> _eklenenOyuncular = [];

  // Yetki Kontrolü (Şimdilik basit)
  bool get yetkiliMi => false; // Admin testi yapacaksan burayı true yap

  @override
  void initState() {
    super.initState();
    _dolulukDurumunuGuncelle();
  }

  // API'den Bu Sahanın Dolu Saatlerini Çek
  void _dolulukDurumunuGuncelle() async {
    setState(() => _yukleniyor = true);
    
    // Saha ID string geliyor ama API int istiyor, çeviriyoruz
    int sahaId = int.tryParse(widget.saha.id) ?? 0;
    
    // Servisten saatleri al
    List<int> gelenDoluSaatler = await _apiServisi.doluSaatleriGetir(sahaId, _seciliTarih);

    if (mounted) {
      setState(() {
        _doluSaatler = gelenDoluSaatler;
        _yukleniyor = false;
        _seciliSaatIndex = null; // Listeyi yenileyince seçimi kaldır
      });
    }
  }

  double _oyuncuUcretiToplami() {
    double toplam = 0;
    for (var oyuncu in _eklenenOyuncular) {
      toplam += oyuncu.ucret;
    }
    return toplam;
  }

  // --- YÖNETİCİ İÇİN MANUEL EKLEME ---
  void _manuelEkleDialog(String saatStr) {
    TextEditingController notController = TextEditingController();
    int saatInt = int.parse(saatStr.split(":")[0]); // "19:00" -> 19

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$saatStr Rezervasyonu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bu saati telefon/elden manuel kapatıyorsunuz."),
            const SizedBox(height: 15),
            TextField(
              controller: notController,
              decoration: const InputDecoration(
                labelText: "Müşteri Adı / Not",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx); // Dialogu kapat
              
              // API'ye Kayıt At
              int sahaId = int.tryParse(widget.saha.id) ?? 0;
              bool basarili = await _apiServisi.rezervasyonYap(
                sahaId, 
                1, // Admin User ID (Şimdilik 1 varsayıyoruz)
                _seciliTarih, 
                saatInt, 
                notController.text
              );

              if (basarili) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saat Kapatıldı! ✅"), backgroundColor: Colors.green));
                _dolulukDurumunuGuncelle(); // Listeyi yenile
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hata oluştu!"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Kapat (Rezervle)"),
          )
        ],
      ),
    );
  }

  void _oyuncuSecimEkraniniAc() async {
    final sonuc = await Navigator.push(context, MaterialPageRoute(builder: (context) => OyuncuSecimEkrani(suankiSecimler: _eklenenOyuncular)));
    if (sonuc != null && sonuc is List<OyuncuModeli>) {
      setState(() => _eklenenOyuncular = sonuc);
    }
  }

  void _odemeEkraninaGit() {
    if (_seciliSaatIndex == null) return;
    String secilenSaat = _saatListesi[_seciliSaatIndex!];
    
    // Ödeme ekranına git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OdemeEkrani(
          saha: widget.saha,
          tarih: _seciliTarih,
          saat: secilenSaat,
          sonTutar: widget.saha.fiyat,
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

    double oyuncuParasi = _oyuncuUcretiToplami();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200, pinned: true, backgroundColor: const Color(0xFF22C55E),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(widget.saha.resimYolu, fit: BoxFit.cover)
            ),
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

                  // TARİH SEÇİCİ (BASİT)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tarih: ${_seciliTarih.toString().substring(0, 10)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: yaziRengi)),
                      TextButton.icon(
                        onPressed: () async {
                           DateTime? yeniTarih = await showDatePicker(
                             context: context, 
                             initialDate: _seciliTarih, 
                             firstDate: DateTime.now(), 
                             lastDate: DateTime.now().add(const Duration(days: 30))
                           );
                           if (yeniTarih != null) {
                             setState(() => _seciliTarih = yeniTarih);
                             _dolulukDurumunuGuncelle(); // Tarih değişince API'ye tekrar sor
                           }
                        }, 
                        icon: const Icon(Icons.calendar_month), 
                        label: const Text("Değiştir")
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // SAAT SEÇİMİ
                  _yukleniyor 
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 10, runSpacing: 10,
                        children: List.generate(_saatListesi.length, (index) {
                          String saatStr = _saatListesi[index];
                          int saatInt = int.parse(saatStr.split(":")[0]); // "19:00" -> 19
                          
                          // API'den gelen listede bu saat var mı?
                          bool dolu = _doluSaatler.contains(saatInt);
                          bool secili = _seciliSaatIndex == index;

                          Color kutuRengi = dolu 
                              ? Colors.grey[300]! 
                              : (secili ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF334155) : Colors.grey[100]!));
                          Color yaziRengiKutu = dolu 
                              ? Colors.grey 
                              : (secili ? Colors.white : (isDark ? Colors.white : Colors.black));

                          return GestureDetector(
                            onTap: () {
                              if (yetkiliMi) {
                                // Yönetici dolu saate tıklarsa detay/iptal açabilir (İleride)
                                if (!dolu) _manuelEkleDialog(saatStr);
                              } else {
                                // Normal kullanıcı sadece boş saate tıklayabilir
                                if (!dolu) setState(() => _seciliSaatIndex = index);
                              }
                            },
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: kutuRengi,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: secili ? const Color(0xFF22C55E) : Colors.transparent, width: 2)
                              ),
                              child: Column(
                                children: [
                                  Text(saatStr, style: TextStyle(color: yaziRengiKutu, fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (dolu) 
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text("DOLU", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                    ),
                                ],
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
                  
                  if (_eklenenOyuncular.isNotEmpty)
                    Column(
                      children: _eklenenOyuncular.map((oyuncu) {
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundImage: NetworkImage(oyuncu.resimUrl), radius: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(oyuncu.isim, style: TextStyle(fontWeight: FontWeight.bold, color: yaziRengi)),
                              ),
                              Text("+${oyuncu.ucret.toStringAsFixed(0)}₺", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
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
        decoration: BoxDecoration(color: kartRengi, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ödenecek Tutar", style: TextStyle(color: altYaziRengi, fontSize: 12)),
                Text(
                  "${widget.saha.fiyat.toStringAsFixed(0)}₺",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
                if (oyuncuParasi > 0)
                  Text(
                    "+ ${oyuncuParasi.toStringAsFixed(0)}₺ Oyuncular (Elden)",
                    style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
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