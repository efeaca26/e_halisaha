import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../../modeller/saha_modeli.dart';
import '../giris/giris_ekrani.dart';

class IsletmeAnaSayfa extends StatefulWidget {
  final Map<String, dynamic> kullanici;

  const IsletmeAnaSayfa({super.key, required this.kullanici});

  @override
  State<IsletmeAnaSayfa> createState() => _IsletmeAnaSayfaState();
}

class _IsletmeAnaSayfaState extends State<IsletmeAnaSayfa> {
  final ApiServisi _apiServisi = ApiServisi();
  // Artık Map değil, SahaModeli kullanıyoruz
  SahaModeli? _benimSaham;
  List<dynamic> _randevular = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _sahaBilgileriniGetir();
  }

  void _sahaBilgileriniGetir() async {
    try {
      var tumSahalar = await _apiServisi.tumSahalariGetir();
      
      // Kullanıcının idsini string veya int olarak al
      String myId = (widget.kullanici['userId'] ?? widget.kullanici['id']).toString();

      // Sahalar arasında ownerId'si veya email'i kullanıcınınkiyle eşleşeni bul
      var saham = tumSahalar.where((saha) => 
        (saha.isletmeSahibiEmail == widget.kullanici['email']) || 
        // Eğer backend ownerId yolluyorsa burada yakalayacağız (modelden eklenebilir)
        saha.id.isNotEmpty // Geçici fallback
      ).firstOrNull;

      // Eğer liste boş değilse ilk sahayı göster (Test için)
      saham ??= tumSahalar.isNotEmpty ? tumSahalar.first : null;

      if (saham != null) {
        var randevular = await _apiServisi.sahaRandevulariniGetir(saham.id);
        
        if (mounted) {
          setState(() {
            _benimSaham = saham;
            _randevular = List.from(randevular.reversed);
            _yukleniyor = false;
          });
        }
      } else {
        if (mounted) setState(() => _yukleniyor = false);
      }
    } catch (e) {
      debugPrint("Saha Getirme Hatası: $e");
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İşletme Paneli"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              KimlikServisi.cikisYap();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GirisEkrani()));
            },
          )
        ],
      ),
      body: _yukleniyor 
          ? const Center(child: CircularProgressIndicator())
          : _benimSaham == null 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.error_outline, size: 60, color: Colors.orange),
                      SizedBox(height: 10),
                      Text("Size tanımlı bir saha bulunamadı.", style: TextStyle(fontSize: 18)),
                      Text("Lütfen yönetici ile iletişime geçin.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Saha Bilgi Kartı
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.stadium, size: 40, color: Colors.orange),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Map [] operatörü yerine obje dot notation (.) kullanıyoruz
                                    Text(_benimSaham!.isim, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    Text(_benimSaham!.ilce, style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 5),
                                    Text("${_benimSaham!.fiyat.toInt()} ₺ / Saat", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      const Align(
                        alignment: Alignment.centerLeft, 
                        child: Text("📅 Gelen Randevular", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      ),
                      const SizedBox(height: 10),

                      // Randevu Listesi
                      Expanded(
                        child: _randevular.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, size: 50, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  Text("Henüz randevu yok.", style: TextStyle(color: Colors.grey[500])),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _randevular.length,
                              itemBuilder: (context, index) {
                                var randevu = _randevular[index];
                                String tarih = randevu['rezDate'].toString().split('T')[0];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
                                    title: Text("Saat: ${randevu['rezHour']}:00"),
                                    subtitle: Text("Tarih: $tarih\nNot: ${randevu['note'] ?? 'Not yok'}"),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                      )
                    ],
                  ),
                ),
    );
  }
}