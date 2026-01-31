import 'package:flutter/material.dart';
import '../../main.dart'; // Tema yöneticisi için
import '../../cekirdek/servisler/rezervasyon_servisi.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/odeme_servisi.dart';

// 1. GEÇMİŞ REZERVASYONLAR VE PUANLAMA
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
      body: ListView.builder(
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

// 2. GEÇMİŞ RAKİPLER VE OYUNCULAR (Tablolu Yapı)
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

// 3. ÖDEME YÖNTEMLERİ (Kart Ekleme)
// 3. ÖDEME YÖNTEMLERİ (Artık Gerçekten Çalışıyor)
class OdemeYontemleriEkrani extends StatefulWidget {
  const OdemeYontemleriEkrani({super.key});
  @override
  State<OdemeYontemleriEkrani> createState() => _OdemeYontemleriEkraniState();
}

class _OdemeYontemleriEkraniState extends State<OdemeYontemleriEkrani> {
  
  // Kart Ekleme Penceresi
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
                setState(() {
                  OdemeServisi.kartEkle(girilenNo, girilenIsim.isEmpty ? "Kartım" : girilenIsim);
                });
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
    final kartlar = OdemeServisi.kartlar; // Servisten çekiyoruz

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
                      setState(() {
                        OdemeServisi.kartSil(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
    );
  }
}

// 4. AYARLAR (Tema Değiştirme)
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