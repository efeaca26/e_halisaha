import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';

class KullaniciYonetimiEkrani extends StatefulWidget {
  const KullaniciYonetimiEkrani({super.key});

  @override
  State<KullaniciYonetimiEkrani> createState() => _KullaniciYonetimiEkraniState();
}

class _KullaniciYonetimiEkraniState extends State<KullaniciYonetimiEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  List<dynamic> _kullanicilar = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _kullanicilariGetir();
  }

  void _kullanicilariGetir() async {
    var veriler = await _apiServisi.tumKullanicilariGetir();
    if (mounted) {
      setState(() {
        _kullanicilar = veriler;
        _yukleniyor = false;
      });
    }
  }

  void _rolDegistir(int userId, String mevcutRol, String kullaniciAdi) {
    String yeniRol = mevcutRol;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Rol Değiştir: $kullaniciAdi"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text("Oyuncu"),
                    value: "oyuncu",
                    groupValue: yeniRol,
                    onChanged: (val) => setDialogState(() => yeniRol = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text("İşletme"),
                    value: "isletme",
                    groupValue: yeniRol,
                    onChanged: (val) => setDialogState(() => yeniRol = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text("Admin"),
                    value: "admin",
                    groupValue: yeniRol,
                    onChanged: (val) => setDialogState(() => yeniRol = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Dialogu kapat
                    
                    bool sonuc = await _apiServisi.kullaniciRoluGuncelle(userId, yeniRol);
                    
                    // --- DÜZELTME: EKRAN KAPANDIYSA DUR ---
                    if (!mounted) return;

                    if (sonuc) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Rol güncellendi!"), backgroundColor: Colors.green)
                      );
                      _kullanicilariGetir(); // Listeyi yenile
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Hata oluştu."), backgroundColor: Colors.red)
                      );
                    }
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _kullaniciSil(int userId) async {
    bool onayla = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kullanıcıyı Sil"),
        content: const Text("Bu işlem geri alınamaz. Emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("İptal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("SİL", style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (onayla) {
      bool sonuc = await _apiServisi.kullaniciSil(userId);
      
      if (!mounted) return;

      if (sonuc) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı silindi.")));
        _kullanicilariGetir();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hata oluştu.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Yönetimi")),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : _kullanicilar.isEmpty
              ? const Center(child: Text("Kayıtlı kullanıcı yok."))
              : ListView.builder(
                  itemCount: _kullanicilar.length,
                  itemBuilder: (context, index) {
                    var kullanici = _kullanicilar[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(kullanici['fullName'] != null ? kullanici['fullName'][0] : "?"),
                        ),
                        title: Text(kullanici['fullName'] ?? "İsimsiz"),
                        subtitle: Text("${kullanici['email']}\nRol: ${kullanici['role']}"),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _rolDegistir(
                                kullanici['userId'] ?? kullanici['id'], 
                                kullanici['role'] ?? "oyuncu",
                                kullanici['fullName'] ?? "Kullanıcı"
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _kullaniciSil(kullanici['userId'] ?? kullanici['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}