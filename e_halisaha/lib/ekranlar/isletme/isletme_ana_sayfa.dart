import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../giris/giris_ekrani.dart';

class IsletmeAnaSayfa extends StatefulWidget {
  final Map<String, dynamic> kullanici; // Giriş yapan kullanıcı bilgisi

  const IsletmeAnaSayfa({super.key, required this.kullanici});

  @override
  State<IsletmeAnaSayfa> createState() => _IsletmeAnaSayfaState();
}

class _IsletmeAnaSayfaState extends State<IsletmeAnaSayfa> {
  final ApiServisi _apiServisi = ApiServisi();
  Map<String, dynamic>? _benimSaham;
  List<dynamic> _randevular = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _sahaBilgileriniGetir();
  }

  // İşletmeye ait sahayı ve randevuları bulur
  void _sahaBilgileriniGetir() async {
    var tumSahalar = await _apiServisi.tumSahalariGetir();
    
    try {
      // Benim userId'me sahip sahayı bul
      var saham = tumSahalar.firstWhere(
        (saha) => saha['userId'] == widget.kullanici['userId'] || saha['userId'] == widget.kullanici['id'],
        orElse: () => null,
      );

      if (saham != null) {
        // Saha bulundu, şimdi bu sahanın randevularını çek
        var randevular = await _apiServisi.sahaRandevulariniGetir(saham['pitchId'].toString());
        
        if (mounted) {
          setState(() {
            _benimSaham = saham;
            _randevular = List.from(randevular.reversed); // En yeni en üstte
            _yukleniyor = false;
          });
        }
      } else {
        if (mounted) setState(() => _yukleniyor = false);
      }
    } catch (e) {
      print("Saha Getirme Hatası: $e");
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
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.stadium, size: 40, color: Colors.orange),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_benimSaham!['name'] ?? "Saha Adı", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text(_benimSaham!['location'] ?? "Konum", style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 5),
                                  Text("${_benimSaham!['pricePerHour']}₺ / Saat", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
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