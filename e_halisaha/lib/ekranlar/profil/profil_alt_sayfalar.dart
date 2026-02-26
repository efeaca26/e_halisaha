import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';

// AYARLAR SAYFASI
class AyarlarSayfasi extends StatefulWidget {
  const AyarlarSayfasi({super.key});

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  // Ayarlar kodları (Önceki mesajdaki gibi...)
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Ayarlar")), body: const Center(child: Text("Ayarlar İçeriği")));
  }
}

// RANDEVULARIM (GEÇMİŞ REZERVASYONLAR) SAYFASI
class RandevularimSayfasi extends StatefulWidget {
  const RandevularimSayfasi({super.key});

  @override
  State<RandevularimSayfasi> createState() => _RandevularimSayfasiState();
}

class _RandevularimSayfasiState extends State<RandevularimSayfasi> {
  final ApiServisi _apiServisi = ApiServisi();
  List<dynamic> _randevular = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final user = await KimlikServisi.kullaniciGetir();
    if (user != null) {
      final liste = await _apiServisi.randevularimiGetir(int.parse(user['id'].toString()));
      setState(() {
        _randevular = liste;
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rezervasyonlarım")),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator()) 
        : _randevular.isEmpty 
          ? const Center(child: Text("Henüz bir randevunuz bulunmuyor."))
          : ListView.builder(
              itemCount: _randevular.length,
              itemBuilder: (context, index) {
                final r = _randevular[index];
                return ListTile(
                  title: Text("Saha: ${r['pitchName'] ?? 'Bilinmiyor'}"),
                  subtitle: Text("Tarih: ${r['startTime']}"),
                );
              },
            ),
    );
  }
}