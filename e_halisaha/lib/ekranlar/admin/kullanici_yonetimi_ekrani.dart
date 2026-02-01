import 'package:flutter/material.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';

class KullaniciYonetimiEkrani extends StatefulWidget {
  const KullaniciYonetimiEkrani({super.key});

  @override
  State<KullaniciYonetimiEkrani> createState() => _KullaniciYonetimiEkraniState();
}

class _KullaniciYonetimiEkraniState extends State<KullaniciYonetimiEkrani> {
  List<Map<String, dynamic>> kullanicilar = [];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    setState(() {
      kullanicilar = List.from(KimlikServisi.tumKullanicilar);
    });
  }

  void _rolDegistirDialog(Map<String, dynamic> kullanici) {
    String secilenRol = kullanici['rol'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${kullanici['isim']} Rolünü Değiştir"),
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
            onPressed: () {
              KimlikServisi.rolDegistir(kullanici['email'], secilenRol);
              _verileriYukle(); // Listeyi yenile
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${kullanici['isim']} artık $secilenRol!"), backgroundColor: Colors.green)
              );
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }

  // Yardımcı Widget (RadioListTile Karmaşasını Çözmek İçin)
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kullanicilar.length,
        itemBuilder: (context, index) {
          final user = kullanicilar[index];
          
          Color rolRengi;
          IconData rolIkonu;

          switch (user['rol']) {
            case 'admin':
              rolRengi = Colors.red;
              rolIkonu = Icons.admin_panel_settings;
              break;
            case 'isletme':
              rolRengi = Colors.orange;
              rolIkonu = Icons.store;
              break;
            default:
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
              title: Text(user['isim'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${user['email']}\nRol: ${user['rol'].toString().toUpperCase()}"),
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