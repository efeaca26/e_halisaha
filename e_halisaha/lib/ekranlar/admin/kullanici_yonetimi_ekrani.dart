import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart'; // KimlikServisi yerine bunu kullanıyoruz

class KullaniciYonetimiEkrani extends StatefulWidget {
  const KullaniciYonetimiEkrani({super.key});

  @override
  State<KullaniciYonetimiEkrani> createState() => _KullaniciYonetimiEkraniState();
}

class _KullaniciYonetimiEkraniState extends State<KullaniciYonetimiEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  List<dynamic> kullanicilar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() async {
    var gelenListe = await _apiServisi.tumKullanicilariGetir();
    if (mounted) {
      setState(() {
        kullanicilar = gelenListe;
        _yukleniyor = false;
      });
    }
  }

  void _rolDegistirDialog(Map<String, dynamic> kullanici) {
    String secilenRol = kullanici['role'] ?? "oyuncu"; // Varsayılan rol

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${kullanici['fullName']} Rolünü Değiştir"),
        content: StatefulBuilder(
          builder: (context, setStateSB) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _rolSecenek(
                  baslik: "Oyuncu (Normal)", 
                  deger: "oyuncu", 
                  grupDegeri: secilenRol, 
                  onChanged: (val) => setStateSB(() => secilenRol = val)
                ),
                _rolSecenek(
                  baslik: "İşletme Sahibi", 
                  deger: "isletme", 
                  grupDegeri: secilenRol, 
                  onChanged: (val) => setStateSB(() => secilenRol = val)
                ),
                _rolSecenek(
                  baslik: "Yönetici (Admin)", 
                  deger: "admin", 
                  grupDegeri: secilenRol, 
                  onChanged: (val) => setStateSB(() => secilenRol = val)
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              // API'ye Güncelleme İsteği At
              bool basarili = await _apiServisi.rolGuncelle(kullanici['userId'], kullanici, secilenRol);
              
              if (basarili) {
                _verileriYukle(); // Listeyi yenile
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${kullanici['fullName']} artık $secilenRol!"), backgroundColor: Colors.green)
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Güncelleme başarısız!"), backgroundColor: Colors.red)
                );
              }
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  Widget _rolSecenek({required String baslik, required String deger, required String grupDegeri, required Function(String) onChanged}) {
    return RadioListTile<String>(
      title: Text(baslik),
      value: deger,
      groupValue: grupDegeri,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Yönetimi")),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator())
        : kullanicilar.isEmpty
          ? const Center(child: Text("Kayıtlı kullanıcı yok."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kullanicilar.length,
              itemBuilder: (context, index) {
                final user = kullanicilar[index];
                final role = (user['role'] ?? "oyuncu").toString().toLowerCase();

                Color rolRengi;
                IconData rolIkonu;

                if (role == 'admin') {
                   rolRengi = Colors.red;
                   rolIkonu = Icons.admin_panel_settings;
                } else if (role == 'isletme') {
                   rolRengi = Colors.orange;
                   rolIkonu = Icons.store;
                } else {
                   rolRengi = Colors.green;
                   rolIkonu = Icons.person;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: rolRengi,
                      child: Icon(rolIkonu, color: Colors.white),
                    ),
                    title: Text(user['fullName'] ?? "İsimsiz", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${user['email']}\nRol: ${role.toUpperCase()}"),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _rolDegistirDialog(user),
                    ),
                  ),
                );
              },
            ),
    );
  }
}