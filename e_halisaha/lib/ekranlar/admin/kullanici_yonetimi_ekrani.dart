import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart'; // ApiServisi kullanıyoruz

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
    String secilenRol = kullanici['role'] ?? "oyuncu";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${kullanici['fullName']} Rolünü Değiştir"),
        content: StatefulBuilder(
          builder: (context, setStateSB) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _rolSecenek(baslik: "Oyuncu", deger: "oyuncu", grupDegeri: secilenRol, onChanged: (v) => setStateSB(() => secilenRol = v)),
                _rolSecenek(baslik: "İşletme", deger: "isletme", grupDegeri: secilenRol, onChanged: (v) => setStateSB(() => secilenRol = v)),
                _rolSecenek(baslik: "Admin", deger: "admin", grupDegeri: secilenRol, onChanged: (v) => setStateSB(() => secilenRol = v)),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            onPressed: () async {
              bool basarili = await _apiServisi.rolGuncelle(kullanici['userId'], kullanici, secilenRol);
              if (basarili) {
                _verileriYukle();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rol güncellendi!"), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hata oluştu!"), backgroundColor: Colors.red));
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
      onChanged: (val) { if (val != null) onChanged(val); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Yönetimi")),
      body: _yukleniyor ? const Center(child: CircularProgressIndicator()) : kullanicilar.isEmpty ? const Center(child: Text("Kullanıcı yok.")) : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kullanicilar.length,
        itemBuilder: (context, index) {
          final user = kullanicilar[index];
          final role = (user['role'] ?? "oyuncu").toString().toLowerCase();
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(role == 'admin' ? Icons.admin_panel_settings : Icons.person)),
              title: Text(user['fullName'] ?? "İsimsiz"),
              subtitle: Text("${user['email']}\nRol: $role"),
              trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _rolDegistirDialog(user)),
            ),
          );
        },
      ),
    );
  }
}