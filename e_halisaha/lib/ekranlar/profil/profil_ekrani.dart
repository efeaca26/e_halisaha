import 'package:flutter/material.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../giris/giris_ekrani.dart';
import 'profil_alt_sayfalar.dart'; // Randevularım, Ayarlar, Profil Düzenle sayfalarının olduğu dosya
import '../isletme/isletme_ana_sayfa.dart';
import '../admin/admin_ana_sayfa.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  Map<String, dynamic>? _kullanici;

  @override
  void initState() {
    super.initState();
    _kullaniciYuke();
  }

  Future<void> _kullaniciYuke() async {
    try {
      final user = await KimlikServisi.kullaniciGetir();
      
      if (mounted) {
        setState(() {
          _kullanici = user ?? {
            'name': 'Misafir Kullanıcı',
            'email': 'Bilgi bulunamadı',
            'role': 'oyuncu'
          };
        });
      }
    } catch (e) {
      debugPrint("Profil yükleme hatası: $e");
      if (mounted) {
        setState(() {
          _kullanici = {
            'name': 'Hata Oluştu',
            'email': 'Lütfen tekrar giriş yapın',
            'role': 'oyuncu'
          };
        });
      }
    }
  }

  void _cikisYap() async {
    await KimlikServisi.cikisYap();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GirisEkrani()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String ad = _kullanici?['name'] ?? "Kullanıcı";
    String email = _kullanici?['email'] ?? "Email yükleniyor...";
    String rol = _kullanici?['role']?.toString().toLowerCase() ?? "oyuncu";
    String basHarf = ad.isNotEmpty ? ad[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profilim", style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _kullanici == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- PROFİL ÜST KISMI (AVATAR VE BİLGİLER) ---
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9), // Açık yeşil arka plan
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF16A34A), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              basHarf,
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ad,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: rol == 'admin' 
                                ? Colors.red.withValues(alpha: 0.1) 
                                : rol == 'isletme' || rol == 'sahasahibi'
                                    ? Colors.orange.withValues(alpha: 0.1)
                                    : const Color(0xFF16A34A).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rol.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: rol == 'admin' 
                                  ? Colors.red 
                                  : rol == 'isletme' || rol == 'sahasahibi'
                                      ? Colors.orange
                                      : const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- ROL BAZLI ÖZEL BUTONLAR (Sadece Admin veya İşletme görür) ---
                  if (rol == 'admin' || rol == 'isletme' || rol == 'sahasahibi') ...[
                    _ProfilMenusuOgesi(
                      ikon: rol == 'admin' ? Icons.security : Icons.stadium,
                      ikonRengi: Colors.white,
                      ikonArkaPlan: rol == 'admin' ? Colors.red : Colors.orange,
                      baslik: rol == 'admin' ? "Admin Paneline Git" : "İşletme Paneline Git",
                      altBaslik: "Yönetim ekranını açar",
                      onTap: () {
                        if (rol == 'admin') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnaSayfa()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => IsletmeAnaSayfa(kullanici: _kullanici!)));
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // --- GENEL KULLANICI MENÜSÜ ---
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
                    child: Column(
                      children: [
                        _ProfilMenusuOgesi(
                          ikon: Icons.person_outline,
                          baslik: "Profili Düzenle",
                          altBaslik: "Kişisel bilgilerinizi güncelleyin",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilDuzenleSayfasi())).then((_) => _kullaniciYuke()),
                        ),
                        _Ayrac(),
                        _ProfilMenusuOgesi(
                          ikon: Icons.calendar_month_outlined,
                          baslik: "Rezervasyonlarım",
                          altBaslik: "Geçmiş ve gelecek maçlarınız",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RandevularimSayfasi())),
                        ),
                        _Ayrac(),
                        _ProfilMenusuOgesi(
                          ikon: Icons.settings_outlined,
                          baslik: "Ayarlar",
                          altBaslik: "Uygulama tercihleri ve bildirimler",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AyarlarSayfasi())),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- ÇIKIŞ YAP BUTONU ---
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
                    child: _ProfilMenusuOgesi(
                      ikon: Icons.logout,
                      ikonRengi: Colors.red,
                      ikonArkaPlan: Colors.red.withValues(alpha: 0.1),
                      baslik: "Çıkış Yap",
                      metinRengi: Colors.red,
                      okuGizle: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Çıkış Yap"),
                            content: const Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _cikisYap();
                                },
                                child: const Text("Çıkış Yap", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}

// Menüdeki her bir satırı (ListTile) temsil eden özel widget
class _ProfilMenusuOgesi extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String? altBaslik;
  final VoidCallback onTap;
  final Color ikonRengi;
  final Color ikonArkaPlan;
  final Color metinRengi;
  final bool okuGizle;

  const _ProfilMenusuOgesi({
    required this.ikon,
    required this.baslik,
    this.altBaslik,
    required this.onTap,
    this.ikonRengi = const Color(0xFF16A34A),
    this.ikonArkaPlan = const Color(0xFFE8F5E9),
    this.metinRengi = const Color(0xFF111827),
    this.okuGizle = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ikonArkaPlan,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(ikon, color: ikonRengi, size: 24),
      ),
      title: Text(
        baslik,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: metinRengi),
      ),
      subtitle: altBaslik != null 
          ? Text(altBaslik!, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))) 
          : null,
      trailing: okuGizle ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
}

// Menü öğeleri arasındaki ince gri çizgi
class _Ayrac extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 70, endIndent: 20);
  }
}