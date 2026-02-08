import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';

// --- 1. GEÇMİŞ REZERVASYONLAR (API BAĞLANTILI) ---
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
    // Giriş yapan kullanıcının ID'sini alıyoruz (Yoksa 1 varsayıyoruz)
    int userId = KimlikServisi.aktifKullanici?['id'] ?? 1;
    
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
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF22C55E),
                        child: Icon(Icons.sports_soccer, color: Colors.white),
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

// --- 2. HESAP BİLGİLERİ ---
class HesapBilgileriEkrani extends StatelessWidget {
  const HesapBilgileriEkrani({super.key});

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
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
            child: const Text("Bilgileri Güncelle", style: TextStyle(color: Colors.white))
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

// --- 3. DİĞER SAYFALAR (Şimdilik Taslak) ---

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

class AyarlarEkrani extends StatelessWidget {
  const AyarlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications), 
            title: Text("Bildirimler"), 
            trailing: Switch(value: true, onChanged: null)
          ),
          ListTile(
            leading: Icon(Icons.dark_mode), 
            title: Text("Karanlık Mod"), 
            trailing: Switch(value: false, onChanged: null)
          ),
          ListTile(
            leading: Icon(Icons.language), 
            title: Text("Dil"), 
            trailing: Text("Türkçe")
          ),
        ],
      ),
    );
  }
}