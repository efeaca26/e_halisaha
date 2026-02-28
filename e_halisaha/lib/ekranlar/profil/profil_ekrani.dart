import 'package:flutter/material.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../giris/giris_ekrani.dart';
import 'profil_alt_sayfalar.dart'; 
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
            'name': 'Futbolsever',
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

  // ROLÜ TÜRKÇELEŞTİREN YARDIMCI FONKSİYON
  String _roluTurkceyeCevir(String? rol) {
    final r = rol?.toLowerCase() ?? 'oyuncu';
    if (r == 'admin') return 'ADMIN';
    if (r == 'isletme' || r == 'sahasahibi' || r == 'owner') return 'İŞLETMECİ';
    return 'OYUNCU';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String ad = _kullanici?['fullName'] ?? _kullanici?['name'] ?? "Futbolsever";
    String email = _kullanici?['email'] ?? "Email yükleniyor...";
    String rolRaw = _kullanici?['role']?.toString().toLowerCase() ?? "oyuncu";
    String basHarf = ad.isNotEmpty ? ad[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Profilim", 
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111827), 
            fontWeight: FontWeight.bold
          )
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        centerTitle: true,
      ),
      body: _kullanici == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- PROFİL ÜST KISMI ---
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE8F5E9),
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
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: isDark ? Colors.white : const Color(0xFF111827)
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 12),
                        // --- DİNAMİK ROL ETİKETİ (USER YERİNE BURASI GELDİ) ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: rolRaw == 'admin' 
                                ? Colors.red.withValues(alpha: 0.15) 
                                : (rolRaw == 'isletme' || rolRaw == 'sahasahibi' || rolRaw == 'owner')
                                    ? Colors.orange.withValues(alpha: 0.15)
                                    : const Color(0xFF16A34A).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _roluTurkceyeCevir(rolRaw),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: rolRaw == 'admin' 
                                  ? Colors.red 
                                  : (rolRaw == 'isletme' || rolRaw == 'sahasahibi' || rolRaw == 'owner')
                                      ? Colors.orange
                                      : const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- ROL BAZLI BUTONLAR ---
                  if (rolRaw == 'admin' || rolRaw == 'isletme' || rolRaw == 'sahasahibi' || rolRaw == 'owner') ...[
                    _ProfilMenusuOgesi(
                      ikon: rolRaw == 'admin' ? Icons.security : Icons.stadium,
                      ikonRengi: Colors.white,
                      ikonArkaPlan: rolRaw == 'admin' ? Colors.red : Colors.orange,
                      baslik: rolRaw == 'admin' ? "Admin Paneline Git" : "İşletme Paneline Git",
                      altBaslik: "Yönetim ekranını açar",
                      onTap: () {
                        if (rolRaw == 'admin') {
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
                      color: Theme.of(context).cardColor, 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
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
                            backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                            title: Text("Çıkış Yap", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                            content: Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
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

class _ProfilMenusuOgesi extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String? altBaslik;
  final VoidCallback onTap;
  final Color ikonRengi;
  final Color ikonArkaPlan;
  final Color? metinRengi;
  final bool okuGizle;

  const _ProfilMenusuOgesi({
    required this.ikon,
    required this.baslik,
    this.altBaslik,
    required this.onTap,
    this.ikonRengi = const Color(0xFF16A34A),
    this.ikonArkaPlan = const Color(0xFFE8F5E9),
    this.metinRengi,
    this.okuGizle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? ikonRengi.withOpacity(0.1) : ikonArkaPlan,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(ikon, color: ikonRengi, size: 24),
      ),
      title: Text(
        baslik,
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: metinRengi ?? (isDark ? Colors.white : const Color(0xFF111827))
        ),
      ),
      subtitle: altBaslik != null 
          ? Text(altBaslik!, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280))) 
          : null,
      trailing: okuGizle ? null : Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }
}

class _Ayrac extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1, 
      thickness: 1, 
      color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1), 
      indent: 70, 
      endIndent: 20
    );
  }
}