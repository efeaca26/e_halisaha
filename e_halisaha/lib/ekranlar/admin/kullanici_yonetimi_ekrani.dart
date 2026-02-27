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
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    setState(() => _yukleniyor = true);
    try {
      final veriler = await _apiServisi.tumKullanicilariGetir();
      if (mounted) {
        setState(() {
          _kullanicilar = veriler;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      debugPrint("Yükleme hatası: $e");
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  void _rolDegistir(dynamic user) {
    // ID tespiti: Hangisi doluysa onu al
    final int userId = user['userId'] ?? user['id'] ?? 0;
    final String mevcutRol = user['role'] ?? "oyuncu";
    final String ad = user['fullName'] ?? "Kullanıcı";
    
    String secilenRol = mevcutRol;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("$ad - Rolü Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _rolRadio("Oyuncu", "oyuncu", secilenRol, (v) => setDialogState(() => secilenRol = v!)),
              _rolRadio("İşletme", "isletme", secilenRol, (v) => setDialogState(() => secilenRol = v!)),
              _rolRadio("Admin", "Admin", secilenRol, (v) => setDialogState(() => secilenRol = v!)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
              onPressed: () async {
                Navigator.pop(ctx);
                bool basarili = await _apiServisi.kullaniciRoluGuncelle(userId, secilenRol);
                if (basarili) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncellendi")));
                  _verileriYukle();
                }
              },
              child: const Text("KAYDET", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _rolRadio(String title, String val, String group, Function(String?) onChange) {
    return RadioListTile<String>(title: Text(title), value: val, groupValue: group, onChanged: onChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text("Kullanıcılar"), backgroundColor: Colors.white, elevation: 0),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
          : _kullanicilar.isEmpty
              ? const Center(child: Text("Kullanıcı listesi boş veya alınamadı."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _kullanicilar.length,
                  itemBuilder: (context, index) {
                    final u = _kullanicilar[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF16A34A).withOpacity(0.1),
                          child: Text((u['fullName'] ?? "?")[0].toUpperCase()),
                        ),
                        title: Text(u['fullName'] ?? "İsimsiz"),
                        subtitle: Text("${u['email']}\nRol: ${u['role']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _rolDegistir(u),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}