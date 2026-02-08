import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../giris/giris_ekrani.dart';

class AdminAnaSayfa extends StatefulWidget {
  // Key parametresi eklendi (Hata: use_key_in_widget_constructors)
  const AdminAnaSayfa({super.key});

  @override
  State<AdminAnaSayfa> createState() => _AdminAnaSayfaState();
}

class _AdminAnaSayfaState extends State<AdminAnaSayfa> {
  final ApiServisi _apiServisi = ApiServisi();
  Key _refreshKey = UniqueKey();

  void _sayfayiYenile() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _refreshKey,
      appBar: AppBar(
        title: const Text("SÜPER ADMİN PANELİ", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _sayfayiYenile,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              KimlikServisi.cikisYap();
              Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const GirisEkrani()), 
                  (route) => false);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _OzetKarti(
              baslik: "Yönetim Merkezi", 
              aciklama: "Tam yetkilisin.", 
              ikon: Icons.security, 
              renk: Colors.blueGrey),
          const SizedBox(height: 20),
          const _Baslik(text: "👤 Kullanıcı İşlemleri"),
          _kullaniciListesiKart(),
          const SizedBox(height: 20),
          const _Baslik(text: "🏟️ Saha Listesi (Canlı)"),
          _sahaListesiKart(),
        ],
      ),
    );
  }

  Widget _kullaniciListesiKart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300), 
          borderRadius: BorderRadius.circular(12)),
      child: FutureBuilder<List<dynamic>>(
        future: _apiServisi.tumKullanicilariGetir(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("Kullanıcı yok."));

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              var user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _rolRengi(user['role']),
                  child: Text(user['fullName'] != null ? user['fullName'][0].toUpperCase() : "?", 
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user['fullName'] ?? 'İsimsiz', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${user['email']}\n${user['role']?.toString().toUpperCase()}"),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _kullaniciDuzenleDialog(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _silmeOnayi(user),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _sahaListesiKart() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300), 
          borderRadius: BorderRadius.circular(12)),
      child: FutureBuilder<List<dynamic>>(
        future: _apiServisi.tumSahalariGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Henüz kayıtlı saha yok."));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var saha = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.green[50],
                child: ListTile(
                  leading: Icon(Icons.stadium, color: Colors.green[800], size: 30),
                  title: Text(saha['name'] ?? 'Saha Adı Yok', 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Fiyat: ${saha['pricePerHour']} TL / Saat\nKonum: ${saha['location'] ?? 'Belirtilmemiş'}"),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () => _sahaSilmeOnayi(saha),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _kullaniciDuzenleDialog(dynamic user) {
    // Alt çizgili yerel değişkenler düzeltildi (no_leading_underscores_for_local_identifiers)
    final isimController = TextEditingController(text: user['fullName']);
    final emailController = TextEditingController(text: user['email']);
    final telController = TextEditingController(text: user['phoneNumber']);
    String secilenRol = user['role'] ?? 'oyuncu';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Kullanıcıyı Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: isimController, decoration: const InputDecoration(labelText: "Ad Soyad", icon: Icon(Icons.person))),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: "E-Posta", icon: Icon(Icons.email))),
                TextField(controller: telController, decoration: const InputDecoration(labelText: "Telefon", icon: Icon(Icons.phone))),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: secilenRol, // Deprecated 'value' yerine 'initialValue' (Hata: deprecated_member_use)
                  decoration: const InputDecoration(labelText: "Rolü Seç", border: OutlineInputBorder()),
                  items: ['oyuncu', 'sahasahibi', 'admin'].map((rol) {
                    return DropdownMenuItem(value: rol, child: Text(rol.toUpperCase()));
                  }).toList(),
                  onChanged: (val) => secilenRol = val!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                Map<String, dynamic> guncelVeri = {
                  "fullName": isimController.text,
                  "email": emailController.text,
                  "phoneNumber": telController.text,
                  "role": secilenRol
                };

                Navigator.pop(ctx);
                bool sonuc = await _apiServisi.kullaniciBilgileriniGuncelle(user['userId'] ?? user['id'], guncelVeri);
                
                // mounted kontrolü eklendi (Hata: use_build_context_synchronously)
                if (!mounted) return;
                
                if (sonuc) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı güncellendi! ✅")));
                  _sayfayiYenile();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncelleme başarısız! ❌"), backgroundColor: Colors.red));
                }
              },
              child: const Text("KAYDET", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  void _sahaSilmeOnayi(dynamic saha) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sahayı Sil"),
        content: Text("${saha['name']} veritabanından tamamen silinecek. Emin misin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              bool silindi = await _apiServisi.sahaSil(saha['pitchId'] ?? saha['id']);
              
              if (!mounted) return; // Async sonrası mounted kontrolü

              if (silindi) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saha silindi!")));
                _sayfayiYenile();
              }
            }, 
            child: const Text("SİL", style: TextStyle(color: Colors.white))
          ),
        ],
      )
    );
  }

  void _silmeOnayi(dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Silmek İstiyor musun?"),
        content: Text("${user['fullName']} silinecek. Bu işlem geri alınamaz."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              bool silindi = await _apiServisi.kullaniciSil(user['userId'] ?? user['id']);
              
              if (!mounted) return;

              if (silindi) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı silindi.")));
                _sayfayiYenile();
              }
            },
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  Color _rolRengi(String? rol) {
    switch (rol) {
      case 'admin': return Colors.red;
      case 'sahasahibi': return Colors.orange;
      default: return Colors.blue;
    }
  }
}

// Alt sınıflar const kullanımı için ayrı widgetlara bölündü
class _Baslik extends StatelessWidget {
  final String text;
  const _Baslik({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}

class _OzetKarti extends StatelessWidget {
  final String baslik;
  final String aciklama;
  final IconData ikon;
  final Color renk;

  const _OzetKarti({
    required this.baslik,
    required this.aciklama,
    required this.ikon,
    required this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: renk,
      child: ListTile(
        leading: Icon(ikon, color: Colors.white, size: 40),
        title: Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(aciklama, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}