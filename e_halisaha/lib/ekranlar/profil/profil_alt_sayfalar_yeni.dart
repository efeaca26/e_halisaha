import 'package:flutter/material.dart';
import '../../main.dart';
import '../../cekirdek/servisler/rezervasyon_servisi.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/odeme_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';

// --- 1. GENEL "YAPIM AŞAMASINDA" SAYFASI (Yedek) ---
class GenelAltSayfa extends StatelessWidget {
  final String baslik;
  final IconData ikon;

  const GenelAltSayfa({super.key, required this.baslik, required this.ikon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text("$baslik Burada Olacak", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Bu özellik geliştirme aşamasındadır.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// --- 2. HESAP BİLGİLERİ EKRANI (Doğum Tarihi Seçmeli) ---
class HesapBilgileriEkrani extends StatefulWidget {
  const HesapBilgileriEkrani({super.key});

  @override
  State<HesapBilgileriEkrani> createState() => _HesapBilgileriEkraniState();
}

class _HesapBilgileriEkraniState extends State<HesapBilgileriEkrani> {
  final Map<String, dynamic> kullanici = KimlikServisi.aktifKullanici ?? {}; 
  
  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilenTarih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (secilenTarih != null) {
      setState(() {
        String formatliTarih = "${secilenTarih.day}.${secilenTarih.month}.${secilenTarih.year}";
        kullanici['dogumTarihi'] = formatliTarih;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doğum tarihi güncellendi!"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (KimlikServisi.aktifKullanici == null) {
      return const Scaffold(body: Center(child: Text("Lütfen tekrar giriş yapınız.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Hesap Bilgileri")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _saltOkunurSatir("Ad Soyad", kullanici['isim']),
            _saltOkunurSatir("E-Posta", kullanici['email']),
            _saltOkunurSatir("Telefon", kullanici['telefon']),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _tarihSec(context),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Doğum Tarihi"),
                    Row(
                      children: [
                        Text(
                          kullanici['dogumTarihi'] ?? "Seçiniz", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D))
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit_calendar, size: 20, color: Color(0xFF15803D)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saltOkunurSatir(String baslik, String? deger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey)),
          Text(deger ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- 3. GEÇMİŞ REZERVASYONLAR VE PUANLAMA ---
class GecmisRezervasyonlarEkrani extends StatelessWidget {
  const GecmisRezervasyonlarEkrani({super.key});

  void _puanla(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sahayı Puanla"),
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.star, color: Colors.amber), Icon(Icons.star, color: Colors.amber), Icon(Icons.star, color: Colors.amber), Icon(Icons.star, color: Colors.amber), Icon(Icons.star_border)],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tamam"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liste = RezervasyonServisi.kullaniciRezervasyonlari;
    return Scaffold(
      appBar: AppBar(title: const Text("Geçmiş Maçlar")),
      body: liste.isEmpty 
          ? const Center(child: Text("Henüz maç geçmişiniz yok."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: liste.length,
              itemBuilder: (context, index) {
                final kayit = liste[index];
                final SahaModeli saha = kayit['saha'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(saha.resimYolu, width: 50, height: 50, fit: BoxFit.cover)),
                    title: Text(saha.isim),
                    subtitle: Text(kayit['tarih'].toString().substring(0, 10)),
                    trailing: ElevatedButton(
                      onPressed: () => _puanla(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                      child: const Text("Puanla", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- 4. GEÇMİŞ RAKİPLER VE OYUNCULAR ---
class GecmisDetayEkrani extends StatelessWidget {
  final String baslik;
  final bool rakipMi; // True ise rakip, False ise oyuncu
  const GecmisDetayEkrani({super.key, required this.baslik, required this.rakipMi});

  @override
  Widget build(BuildContext context) {
    // Sahte veri
    final veriler = rakipMi 
        ? ["Gebze Gücü", "Yıldızlar FC", "Körfez SK"] 
        : ["Muslera Ahmet", "Hızlı Kemal", "Panter Sinan"];

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

// --- 5. ÖDEME YÖNTEMLERİ (Kart Ekle/Sil) ---
class OdemeYontemleriEkrani extends StatefulWidget {
  const OdemeYontemleriEkrani({super.key});
  @override
  State<OdemeYontemleriEkrani> createState() => _OdemeYontemleriEkraniState();
}

class _OdemeYontemleriEkraniState extends State<OdemeYontemleriEkrani> {
  
  @override
  void initState() {
    super.initState();
    setState(() {}); 
  }

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
              decoration: const InputDecoration(hintText: "Kart Numarası (Sadece son 4 hane alınır)"),
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
                elevation: 2,
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

// --- 6. AYARLAR (Tema Değiştirme) ---
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