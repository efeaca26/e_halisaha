import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../giris/giris_ekrani.dart';
import 'kullanici_yonetimi_ekrani.dart';

class AdminAnaSayfa extends StatefulWidget {
  const AdminAnaSayfa({super.key});

  @override
  State<AdminAnaSayfa> createState() => _AdminAnaSayfaState();
}

class _AdminAnaSayfaState extends State<AdminAnaSayfa> {
  final ApiServisi _apiServisi = ApiServisi();
  Key _refreshKey = UniqueKey();
  
  int _toplamSaha = 0;
  int _toplamKullanici = 0;
  bool _sayaclarYukleniyor = true;

  @override
  void initState() {
    super.initState();
    _istatistikleriYukle();
  }

  void _istatistikleriYukle() async {
    if (!mounted) return;
    setState(() => _sayaclarYukleniyor = true);
    try {
      var sahalar = await _apiServisi.tumSahalariGetir();
      var kullanicilar = await _apiServisi.tumKullanicilariGetir();
      if (mounted) {
        setState(() {
          _toplamSaha = sahalar.length;
          _toplamKullanici = kullanicilar.length;
          _sayaclarYukleniyor = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _sayaclarYukleniyor = false);
    }
  }

  void _sayfayiYenile() {
    setState(() {
      _refreshKey = UniqueKey();
    });
    _istatistikleriYukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _refreshKey,
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Yönetim Paneli", style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: _sayfayiYenile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await KimlikServisi.cikisYap();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const GirisEkrani()), 
                  (route) => false
                );
              }
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _sayfayiYenile(),
        color: const Color(0xFFEF4444),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: _IstatistikKarti(
                    baslik: "Toplam Saha",
                    deger: _sayaclarYukleniyor ? "..." : _toplamSaha.toString(),
                    ikon: Icons.stadium,
                    renk: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _IstatistikKarti(
                    baslik: "Kullanıcılar",
                    deger: _sayaclarYukleniyor ? "..." : _toplamKullanici.toString(),
                    ikon: Icons.people_alt,
                    renk: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _onayBekleyenlerListesi(),
            const SizedBox(height: 24),
            const Text("Hızlı Erişim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            const SizedBox(height: 16),
            _MenuButonu(
              ikon: Icons.manage_accounts,
              baslik: "Kullanıcı ve Rol Yönetimi",
              altBaslik: "Kullanıcıları sil, düzenle veya admin yap",
              renk: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const KullaniciYonetimiEkrani()));
              },
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.list_alt, color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(width: 12),
                      const Text("Kayıtlı Sahalar (Canlı)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sahaListesi(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onayBekleyenlerListesi() {
    return FutureBuilder<List<dynamic>>(
      future: _apiServisi.tumKullanicilariGetir(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var bekleyenler = snapshot.data!.where((u) => u['isApproved'] == false && (u['role'] == 'isletme' || u['role'] == 'sahasahibi' || u['role'] == 'SahaSahibi' || u['role'] == 'Admin')).toList();
        if (bekleyenler.isEmpty) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            border: Border.all(color: const Color(0xFFFDE68A)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Text("Onay Bekleyen İşletmeler", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF92400E), fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              ...bekleyenler.map((user) => Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['fullName'] ?? 'İsimsiz', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                          Text(user['phoneNumber'] ?? 'Tel Yok', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () async {
                        bool sonuc = await _apiServisi.kullaniciBilgileriniGuncelle(
                          user['userId'] ?? user['id'], 
                          {
                            "role": user['role'], 
                            "isApproved": true,
                            "fullName": user['fullName'],
                            "email": user['email'],
                            "phoneNumber": user['phoneNumber']
                          } 
                        );
                        if (!mounted) return;
                        if (sonuc) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Onaylandı!"), backgroundColor: Colors.green));
                           _sayfayiYenile();
                        }
                      }, 
                      child: const Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                    ),
                  ],
                ),
              )).toList()
            ],
          ),
        );
      },
    );
  }

  Widget _sahaListesi() {
    return FutureBuilder<List<dynamic>>(
      future: _apiServisi.tumSahalariGetir(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Saha yok.");
        var sahalar = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sahalar.length > 5 ? 5 : sahalar.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            var saha = sahalar[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(saha.isim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("${saha.fiyat.toInt()} ₺", style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _sahaSilmeOnayi(saha),
              ),
            );
          },
        );
      },
    );
  }

  void _sahaSilmeOnayi(dynamic saha) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sahayı Sil"),
        content: const Text("Bu işlem geri alınamaz."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              bool silindi = await _apiServisi.sahaSil(int.parse(saha.id));
              if (mounted && silindi) _sayfayiYenile();
            }, 
            child: const Text("SİL"),
          ),
        ],
      )
    );
  }
}

class _IstatistikKarti extends StatelessWidget {
  final String baslik;
  final String deger;
  final IconData ikon;
  final Color renk;
  const _IstatistikKarti({required this.baslik, required this.deger, required this.ikon, required this.renk});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk),
          const SizedBox(height: 12),
          Text(deger, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(baslik, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _MenuButonu extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String altBaslik;
  final Color renk;
  final VoidCallback onTap;
  const _MenuButonu({required this.ikon, required this.baslik, required this.altBaslik, required this.renk, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(ikon, color: renk),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(altBaslik, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ],
        ),
      ),
    );
  }
}