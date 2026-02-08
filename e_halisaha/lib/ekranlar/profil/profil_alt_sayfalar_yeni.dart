import 'package:flutter/material.dart';
import '../../main.dart'; // Tema yöneticisi için
import '../../cekirdek/servisler/api_servisi.dart'; // API Servisi
import '../../cekirdek/servisler/kimlik_servisi.dart'; // Kullanıcı bilgisi için
import '../../cekirdek/servisler/odeme_servisi.dart'; // Kart işlemleri için

// --- 1. HESAP BİLGİLERİ (API İLE GÜNCELLENEBİLİR) ---
class HesapBilgileriEkrani extends StatefulWidget {
  const HesapBilgileriEkrani({super.key});

  @override
  State<HesapBilgileriEkrani> createState() => _HesapBilgileriEkraniState();
}

class _HesapBilgileriEkraniState extends State<HesapBilgileriEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  
  late TextEditingController _adController;
  late TextEditingController _emailController;
  late TextEditingController _telefonController;
  late TextEditingController _sifreController;

  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    final k = KimlikServisi.aktifKullanici;
    _adController = TextEditingController(text: k?['isim'] ?? "");
    _emailController = TextEditingController(text: k?['email'] ?? "");
    _telefonController = TextEditingController(text: k?['telefon'] ?? "");
    _sifreController = TextEditingController(text: "mevcutsifre"); 
  }

  void _kaydet() async {
    setState(() => _yukleniyor = true);

    int userId = KimlikServisi.aktifKullanici?['id'] ?? 1;

    // API'ye güncelleme isteği atıyoruz
    bool basarili = await _apiServisi.bilgileriGuncelle(
      userId,
      _adController.text,
      _emailController.text,
      _telefonController.text,
      _sifreController.text
    );

    setState(() => _yukleniyor = false);

    if (basarili) {
      // Başarılıysa telefondaki bilgiyi de güncelle
      KimlikServisi.aktifKullanici?['isim'] = _adController.text;
      KimlikServisi.aktifKullanici?['email'] = _emailController.text;
      KimlikServisi.aktifKullanici?['telefon'] = _telefonController.text;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bilgiler Güncellendi! ✅"), backgroundColor: Colors.green));
        Navigator.pop(context); // Profil sayfasına dön
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncelleme Başarısız!"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bilgilerimi Düzenle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF22C55E),
              child: Icon(Icons.edit, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 20),
            
            _inputKutusu("Ad Soyad", Icons.person, _adController),
            const SizedBox(height: 15),
            _inputKutusu("E-Posta", Icons.email, _emailController),
            const SizedBox(height: 15),
            _inputKutusu("Telefon", Icons.phone, _telefonController),
            const SizedBox(height: 15),
            _inputKutusu("Şifre", Icons.lock, _sifreController, gizli: true),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _yukleniyor ? null : _kaydet, 
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _yukleniyor 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Değişiklikleri Kaydet", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _inputKutusu(String baslik, IconData ikon, TextEditingController controller, {bool gizli = false}) {
    return TextField(
      controller: controller,
      obscureText: gizli,
      decoration: InputDecoration(
        labelText: baslik,
        prefixIcon: Icon(ikon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor
      ),
    );
  }
}

// --- 2. GEÇMİŞ REZERVASYONLAR (API BAĞLANTILI) ---
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
    int userId = KimlikServisi.aktifKullanici?['id'] ?? 1;
    var gelenVeri = await _apiServisi.randevularimiGetir(userId);
    
    if (mounted) {
      setState(() {
        _liste = List.from(gelenVeri.reversed);
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
                      title: Text("Saha #${mac['pitchId']} - Maç", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("$tarih | Saat: ${mac['rezHour']}:00"),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  );
                },
              ),
    );
  }
}

// --- 3. GEÇMİŞ DETAY (Rakip/Oyuncu) ---
class GecmisDetayEkrani extends StatelessWidget {
  final String baslik;
  final bool rakipMi;
  const GecmisDetayEkrani({super.key, required this.baslik, required this.rakipMi});

  @override
  Widget build(BuildContext context) {
    final veriler = rakipMi 
        ? ["Gebze Gücü", "Yıldızlar FC", "Körfez SK"] 
        : ["Ahmet Yılmaz", "Mehmet Demir", "Ali Kaya"];

    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: ListView.builder(
        itemCount: veriler.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Icon(rakipMi ? Icons.shield : Icons.person)),
            title: Text(veriler[index]),
            subtitle: Text(rakipMi ? "3-2 Kazanıldı" : "Defans - 4.5 Puan"),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}

// --- 4. ÖDEME YÖNTEMLERİ (Kart Ekle/Sil) ---
class OdemeYontemleriEkrani extends StatefulWidget {
  const OdemeYontemleriEkrani({super.key});
  @override
  State<OdemeYontemleriEkrani> createState() => _OdemeYontemleriEkraniState();
}

class _OdemeYontemleriEkraniState extends State<OdemeYontemleriEkrani> {
  void _kartEkleDialog() {
    String girilenNo = "";
    String girilenIsim = "";
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Yeni Kart Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "Kart İsmi (Örn: İş Bankası)"),
              onChanged: (val) => girilenIsim = val,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(hintText: "Kart Numarası (Son 4 hane)"),
              keyboardType: TextInputType.number,
              maxLength: 16,
              onChanged: (val) => girilenNo = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () {
              if (girilenNo.length >= 4) {
                OdemeServisi.kartEkle(girilenNo, girilenIsim.isEmpty ? "Kartım" : girilenIsim);
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kartlar = OdemeServisi.kartlar;

    return Scaffold(
      appBar: AppBar(title: const Text("Kayıtlı Kartlarım")),
      floatingActionButton: FloatingActionButton(
        onPressed: _kartEkleDialog,
        backgroundColor: const Color(0xFF22C55E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: kartlar.isEmpty 
        ? const Center(child: Text("Kayıtlı kartınız yok.")) 
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kartlar.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.credit_card, color: Colors.blue),
                  ),
                  title: Text(kartlar[index]['isim']!),
                  subtitle: Text(kartlar[index]['no']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      OdemeServisi.kartSil(index);
                      setState(() {}); 
                    },
                  ),
                ),
              );
            },
          ),
    );
  }
}

// --- 5. AYARLAR (Tema Değiştirme) ---
class AyarlarEkrani extends StatelessWidget {
  const AyarlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Karanlık Mod"),
            subtitle: const Text("Uygulamayı koyu temaya çevir"),
            value: temaYoneticisi.value == ThemeMode.dark,
            onChanged: (val) {
              temaYoneticisi.value = val ? ThemeMode.dark : ThemeMode.light;
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Bildirimler"),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text("Hakkında"),
            subtitle: Text("v1.0.0"),
          ),
        ],
      ),
    );
  }
}