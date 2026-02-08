import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../giris/giris_ekrani.dart';

class AdminAnaSayfa extends StatefulWidget {
  @override
  _AdminAnaSayfaState createState() => _AdminAnaSayfaState();
}

class _AdminAnaSayfaState extends State<AdminAnaSayfa> {
  final ApiServisi _apiServisi = ApiServisi();

  // Sayfa yenilemek için kullanılan key
  Key _refreshKey = UniqueKey();

  void _sayfayiYenile() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _refreshKey, // Sayfayı yeniden çizmek için
      appBar: AppBar(
        title: Text("SÜPER ADMİN PANELİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[800],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _sayfayiYenile, // Manuel yenileme butonu
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              KimlikServisi.cikisYap();
              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => GirisEkrani()), (route) => false);
            },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _ozetKarti("Yönetim Merkezi", "Tam yetkilisin.", Icons.security, Colors.blueGrey),
          SizedBox(height: 20),
          _baslik("👤 Kullanıcı İşlemleri"),
          _kullaniciListesiKart(),
          SizedBox(height: 20),
          _baslik("🏟️ Saha Listesi (Canlı)"),
          _sahaListesiKart(),
        ],
      ),
    );
  }

  // --- KULLANICI LİSTESİ BÖLÜMÜ ---
  Widget _kullaniciListesiKart() {
    return Container(
      height: 300, // Listeye sabit yükseklik verelim
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: FutureBuilder<List<dynamic>>(
        future: _apiServisi.tumKullanicilariGetir(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return Center(child: Text("Kullanıcı yok."));

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (ctx, i) => Divider(height: 1),
            itemBuilder: (context, index) {
              var user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _rolRengi(user['role']),
                  child: Text(user['fullName'] != null ? user['fullName'][0].toUpperCase() : "?", style: TextStyle(color: Colors.white)),
                ),
                title: Text(user['fullName'] ?? 'İsimsiz', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${user['email']}\n${user['role']?.toString().toUpperCase()}"),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _kullaniciDuzenleDialog(user),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
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

  // --- SAHA LİSTESİ BÖLÜMÜ (PITCHES) ---
  Widget _sahaListesiKart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300), 
        borderRadius: BorderRadius.circular(12)
      ),
      child: FutureBuilder<List<dynamic>>(
        future: _apiServisi.tumSahalariGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("Henüz kayıtlı saha yok."));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var saha = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.stadium, color: Colors.green),
                  title: Text(saha['name'] ?? 'Saha Adı Yok'),
                  subtitle: Text("${saha['location'] ?? 'Konum yok'} - ${saha['pricePerHour']} TL"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.red),
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

  // --- SAHA SİLME ONAYI ---
  void _sahaSilmeOnayi(dynamic saha) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Sahayı Sil"),
        content: Text("${saha['name']} veritabanından tamamen silinecek. Emin misin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              bool silindi = await _apiServisi.sahaSil(saha['pitchId'] ?? saha['id']);
              if (silindi) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saha silindi!")));
                _sayfayiYenile(); // Ekranı tazele
              }
            }, 
            child: Text("SİL")
          ),
        ],
      )
    );
  }

  // --- GELİŞMİŞ DÜZENLEME PENCERESİ (FULL YETKİ) ---
  void _kullaniciDuzenleDialog(dynamic user) {
    // Controllerları mevcut verilerle doldur
    final _isimController = TextEditingController(text: user['fullName']);
    final _emailController = TextEditingController(text: user['email']);
    final _telController = TextEditingController(text: user['phoneNumber']);
    String secilenRol = user['role'] ?? 'oyuncu';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Kullanıcıyı Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _isimController, decoration: InputDecoration(labelText: "Ad Soyad", icon: Icon(Icons.person))),
                TextField(controller: _emailController, decoration: InputDecoration(labelText: "E-Posta", icon: Icon(Icons.email))),
                TextField(controller: _telController, decoration: InputDecoration(labelText: "Telefon", icon: Icon(Icons.phone))),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: secilenRol,
                  decoration: InputDecoration(labelText: "Rolü Seç", border: OutlineInputBorder()),
                  items: ['oyuncu', 'sahasahibi', 'admin'].map((rol) {
                    return DropdownMenuItem(value: rol, child: Text(rol.toUpperCase()));
                  }).toList(),
                  onChanged: (val) => secilenRol = val!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("İptal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                // Güncelleme İsteği Gönder
                Map<String, dynamic> guncelVeri = {
                  "fullName": _isimController.text,
                  "email": _emailController.text,
                  "phoneNumber": _telController.text,
                  "role": secilenRol
                };

                Navigator.pop(ctx); // Pencereyi kapat
                bool sonuc = await _apiServisi.kullaniciBilgileriniGuncelle(user['userId'] ?? user['id'], guncelVeri);
                
                if (sonuc) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kullanıcı güncellendi! ✅")));
                  _sayfayiYenile(); // Listeyi yenile
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Güncelleme başarısız! ❌"), backgroundColor: Colors.red));
                }
              },
              child: Text("KAYDET", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  void _silmeOnayi(dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Silmek İstiyor musun?"),
        content: Text("${user['fullName']} silinecek. Bu işlem geri alınamaz."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              bool silindi = await _apiServisi.kullaniciSil(user['userId'] ?? user['id']);
              if (silindi) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kullanıcı silindi.")));
                _sayfayiYenile();
              }
            },
            child: Text("SİL", style: TextStyle(color: Colors.white)),
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

  Widget _baslik(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _ozetKarti(String baslik, String aciklama, IconData ikon, Color renk) {
    return Card(
      color: renk,
      child: ListTile(
        leading: Icon(ikon, color: Colors.white, size: 40),
        title: Text(baslik, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(aciklama, style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}