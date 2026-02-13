import 'package:flutter/material.dart';
import '../../main.dart'; // Tema Yöneticisi için
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../../bilesenler/gizli_musti.dart'; // Gizli video için
import '../giris/giris_ekrani.dart'; // Çıkış yönlendirmesi için

// ---------------------------------------------------------------------------
// 1. HESAP BİLGİLERİ EKRANI
// ---------------------------------------------------------------------------
class HesapBilgileriEkrani extends StatefulWidget {
  const HesapBilgileriEkrani({super.key});

  @override
  State<HesapBilgileriEkrani> createState() => _HesapBilgileriEkraniState();
}

class _HesapBilgileriEkraniState extends State<HesapBilgileriEkrani> {
  @override
  Widget build(BuildContext context) {
    final kullanici = KimlikServisi.aktifKullanici;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Hesap Bilgileri")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _bilgiSatiri("Ad Soyad", kullanici?['isim'] ?? "-"),
          _bilgiSatiri("E-Posta", kullanici?['email'] ?? "-"),
          _bilgiSatiri("Telefon", kullanici?['telefon'] ?? "-"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bilgileri güncelleme yakında aktif olacak.")));
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text("Bilgileri Güncelle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(deger, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. GEÇMİŞ REZERVASYONLAR (API BAĞLANTILI)
// ---------------------------------------------------------------------------
class GecmisRezervasyonlarEkrani extends StatefulWidget {
  const GecmisRezervasyonlarEkrani({super.key});

  @override
  State<GecmisRezervasyonlarEkrani> createState() => _GecmisRezervasyonlarEkraniState();
}

class _GecmisRezervasyonlarEkraniState extends State<GecmisRezervasyonlarEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  List<dynamic> _liste = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  void _verileriCek() async {
    int userId = KimlikServisi.aktifKullanici?['id'] ?? 0;
    // API'den randevuları çekiyoruz
    var gelenVeri = await _apiServisi.randevularimiGetir(userId);
    
    if (mounted) {
      setState(() {
        _liste = List.from(gelenVeri.reversed); // En yeni en üstte
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geçmiş Maçlarım")),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator())
        : _liste.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    const Text("Henüz maç yapmadınız.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _liste.length,
                itemBuilder: (context, index) {
                  var mac = _liste[index];
                  
                  // Tarih parse (API'den 2026-02-08T00:00:00 geliyor)
                  String tarih = mac['rezDate'].toString().split('T')[0];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.sports_soccer, color: Color(0xFF22C55E)),
                      ),
                      title: Text(mac['pitchName'] ?? "Halı Saha", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("$tarih | Saat: ${mac['rezHour']}:00"),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  );
                },
              ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. AYARLAR EKRANI (Gizli Özellik ve Hesap Silme Eklendi)
// ---------------------------------------------------------------------------
class AyarlarEkrani extends StatelessWidget {
  const AyarlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: [
          // Karanlık Mod
          ValueListenableBuilder<ThemeMode>(
            valueListenable: temaYoneticisi,
            builder: (context, currentMode, child) {
              return SwitchListTile(
                title: const Text("Karanlık Mod"),
                secondary: const Icon(Icons.dark_mode),
                value: currentMode == ThemeMode.dark,
                activeColor: const Color(0xFF22C55E),
                onChanged: (bool value) {
                  temaYoneticisi.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
          
          const Divider(),

          // Versiyon ve Gizli Özellik
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Uygulama Sürümü"),
            // GİZLİ VİDEO TETİKLEYİCİSİ BURADA
            trailing: GizliVideoTetikleyici(
              videoYolu: 'assets/video.mp4', 
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Text("v1.0.0", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
              ),
            ),
          ),

          const Divider(),

          // HESABI SİL BUTONU
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Hesabımı Sil", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Hesabı Sil?"),
                  content: const Text("Bu işlem geri alınamaz. Hesabınız ve tüm verileriniz kalıcı olarak silinecektir."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        // API'den sil
                        int userId = KimlikServisi.aktifKullanici?['id'] ?? 0;
                        bool sonuc = await ApiServisi().hesabiSil(userId);
                        
                        if (sonuc) {
                          KimlikServisi.cikisYap();
                          // Giriş ekranına at
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const GirisEkrani()), (route) => false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hesabınız silindi.")));
                        } else {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hata oluştu, silinemedi.")));
                        }
                      },
                      child: const Text("SİL", style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. DİĞER EKRANLAR (Taslak)
// ---------------------------------------------------------------------------

class GecmisDetayEkrani extends StatelessWidget {
  final String baslik;
  final bool rakipMi;
  const GecmisDetayEkrani({super.key, required this.baslik, required this.rakipMi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 50, color: Colors.orange),
            const SizedBox(height: 10),
            Text("$baslik özelliği yakında eklenecek!", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class OdemeYontemleriEkrani extends StatelessWidget {
  const OdemeYontemleriEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ödeme Yöntemleri")),
      body: const Center(child: Text("Kayıtlı kartınız bulunmuyor.")),
    );
  }
}