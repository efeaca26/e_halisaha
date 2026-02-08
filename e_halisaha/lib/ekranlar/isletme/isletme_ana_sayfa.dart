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
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _sahaBilgileriniGetir();
  }

  // İşletmeye ait sahayı bulur
  void _sahaBilgileriniGetir() async {
    // Tüm sahaları çekip, userId'si benimkiyle eşleşeni bulacağız
    // (İleride backend'e "GetMyPitch" fonksiyonu ekleyerek bunu iyileştirebiliriz)
    var tumSahalar = await _apiServisi.tumSahalariGetir();
    
    try {
      var saham = tumSahalar.firstWhere(
        (saha) => saha['userId'] == widget.kullanici['userId'] || saha['userId'] == widget.kullanici['id'],
        orElse: () => null
      );
      
      if (mounted) {
        setState(() {
          _benimSaham = saham;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kullanici['fullName'] ?? "İşletme Paneli"),
        backgroundColor: Colors.orange[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              KimlikServisi.cikisYap();
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const GirisEkrani()), 
                (route) => false
              );
            },
          )
        ],
      ),
      body: _yukleniyor 
          ? const Center(child: CircularProgressIndicator())
          : _benimSaham == null 
              ? const Center(child: Text("Saha bilgisi bulunamadı!"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // SAHA KARTI
                      Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(Icons.stadium, size: 50, color: Colors.orange),
                              const SizedBox(height: 10),
                              Text(_benimSaham!['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(_benimSaham!['location'], style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 10),
                              Text("Saatlik Ücret: ${_benimSaham!['pricePerHour']} TL", 
                                  style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft, 
                        child: Text("📅 Randevular (Yakında)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      ),
                      // Buraya ileride rezervasyon listesi gelecek
                      Expanded(
                        child: Center(
                          child: Text("Henüz randevu sistemini panele bağlamadık.", style: TextStyle(color: Colors.grey[400])),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}